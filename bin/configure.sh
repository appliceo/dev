#!/usr/bin/env bash
# Render every per-project .env file + gestion/config.php from the dev-stack's
# central config (defaults + active profile + local.env).
# Idempotent — re-run any time. Overwrites the rendered files in place.
#
# Usage:
#   bash bin/configure.sh [--profile=full-local] [--check]
#
# Render a single template (used by bin/php-deploy-config.sh):
#   bash bin/configure.sh --profile=php-ovh-dev \
#        --secrets-env=dev \
#        --render-only=gestion-config.php.tmpl \
#        --out=path/to/config.php
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG="$ROOT/config"
TEMPLATES="$CONFIG/templates"

PROFILE=full-local
CHECK=0
RENDER_ONLY=""    # when set, render only this single template basename
OUT=""            # explicit output path (used with --render-only)
SECRETS_ENV=dev   # which SOPS file to source (dev|prod)
for a in "$@"; do
  case "$a" in
    --profile=*)       PROFILE="${a#--profile=}" ;;
    --check)           CHECK=1 ;;
    --render-only=*)   RENDER_ONLY="${a#--render-only=}" ;;
    --out=*)           OUT="${a#--out=}" ;;
    --secrets-env=*)   SECRETS_ENV="${a#--secrets-env=}" ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

case "$SECRETS_ENV" in
  dev|prod) ;;
  *) echo "--secrets-env must be dev or prod (got: $SECRETS_ENV)" >&2; exit 2 ;;
esac

if [ -n "$RENDER_ONLY" ] && [ -z "$OUT" ]; then
  echo "--render-only requires --out=<path>" >&2
  exit 2
fi

# Self-install the committed git hooks (idempotent — sets core.hooksPath once).
# Skipped in render-only mode — that path is meant for narrow, scriptable use
# (e.g. bin/php-deploy-config.sh) and shouldn't mutate repo state as a side
# effect.
if [ -z "$RENDER_ONLY" ] && [ -d "$ROOT/hooks" ] && [ -x "$ROOT/hooks/pre-commit" ]; then
  current_hooks=$(git -C "$ROOT" config --get core.hooksPath 2>/dev/null || true)
  if [ "$current_hooks" != "hooks" ]; then
    git -C "$ROOT" config core.hooksPath hooks
    echo "[hooks] core.hooksPath set to hooks/ (pre-commit guardrails active)"
  fi
fi

PROFILE_FILE="$CONFIG/profiles/$PROFILE.env"
if [ ! -f "$PROFILE_FILE" ]; then
  echo "no such profile: $PROFILE_FILE" >&2
  echo "available:" >&2
  ls "$CONFIG/profiles/" | sed 's/\.env$//; s/^/  /' >&2
  exit 2
fi

# Source defaults → SOPS-encrypted dev secrets → profile → local.env override.
# SOPS sourced BEFORE profile so profile assignments can reference SOPS-injected
# vars (e.g. php-ovh-dev.env: MYSQL_USER=${OVH_DEV_DB_USER}). Trade-off: profile
# values now win over SOPS for the same key — that pattern isn't used today.
# set -a auto-exports each sourced file's KEY=VALUE assignments.
set -a
# shellcheck source=/dev/null
. "$CONFIG/defaults.env"

# Inject SOPS-decrypted secrets for the chosen env, if available. Skipped
# gracefully when:
#   - sops binary not installed (fresh clone)
#   - user has no age key yet (pre-bootstrap)
#   - secrets file missing (default --secrets-env=dev; prod is gitignored
#     until `bin/secret.sh seed-prod` is run)
# That keeps a fresh clone runnable up to the warning at the bottom.
SECRETS_FILE="$CONFIG/secrets.$SECRETS_ENV.sops.yaml"
if [ -f "$SECRETS_FILE" ] && command -v sops >/dev/null 2>&1 \
    && [ -r "${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" ]; then
  # Decrypt to dotenv, then export each KEY=value line directly via `export`.
  # We do NOT `source` because sops emits unquoted values; a value containing
  # spaces (e.g. "-----BEGIN RSA PRIVATE KEY-----") would make bash try to run
  # "RSA" as a command. `export "KEY=val"` is space-safe.
  # Multi-line YAML values (PEMs, certs) come out with literal `\n` escapes in
  # the dotenv format — we skip them; they get rendered to files below via
  # `sops --extract` which preserves real newlines.
  while IFS= read -r line; do
    case "$line" in
      [A-Z_]*=*)
        key="${line%%=*}"
        val="${line#*=}"
        case "$val" in
          *'\n'*) continue ;;   # multi-line value — handled by file render
        esac
        export "$key=$val"
        ;;
    esac
  done < <(SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" \
             sops -d --output-type=dotenv "$SECRETS_FILE" 2>/dev/null)
fi

# shellcheck source=/dev/null
. "$PROFILE_FILE"

if [ -f "$CONFIG/local.env" ]; then
  # shellcheck source=/dev/null
  . "$CONFIG/local.env"
fi
set +a

if ! command -v envsubst >/dev/null 2>&1; then
  echo "envsubst not found. Install gettext (macOS: brew install gettext)." >&2
  exit 3
fi

# Reject a rendered file before it can replace the live one.
#   1. No surviving ${ident} placeholders. envsubst is given an uppercase-only
#      allowlist (see grep below), so a typo like ${database_name} silently
#      survives rendering — catch any leftover ${...} regardless of case.
#      Caveat: envsubst replaces *unset* uppercase vars with "" (no leftover),
#      so this check won't flag empty-substitution; the `warn` loop at the end
#      of the script handles the must-be-set keys.
#   2. For .php.tmpl outputs, run `php -l` against the temp. Force
#      short_open_tag=On because the templates use `<?` and the container has
#      it On — otherwise `php -l` parses the file as plain HTML on hosts with
#      short_open_tag=Off and silently green-lights broken PHP.
verify_rendered() {
  local src="$1" tmp="$2"
  local stray
  stray="$(grep -nE '\$\{[A-Za-z_][A-Za-z0-9_]*\}' "$tmp" || true)"
  if [ -n "$stray" ]; then
    echo "  [fail]  $(basename "$src"): unsubstituted placeholders" >&2
    printf '          %s\n' "$stray" >&2
    return 1
  fi
  case "$src" in
    *.php.tmpl)
      if ! command -v php >/dev/null 2>&1; then
        echo "  [warn]  php not in PATH — skipping syntax check on $(basename "$src")" >&2
      else
        local out
        if ! out="$(php -d short_open_tag=On -l "$tmp" 2>&1)"; then
          echo "  [fail]  $(basename "$src"): php -l rejected the rendered file" >&2
          printf '          %s\n' "$out" >&2
          return 1
        fi
      fi
      ;;
  esac
  return 0
}

# Single-template short-circuit. Used by bin/php-deploy-config.sh to render
# just gestion-config.php.tmpl into a staging dir for OVH rsync. Skips the
# full mappings loop, the multi-line key extraction, the public-key copy,
# and the final warning banner — all of which are dev-stack concerns.
if [ -n "$RENDER_ONLY" ]; then
  src="$TEMPLATES/$RENDER_ONLY"
  if [ ! -f "$src" ]; then
    echo "render-only: template not found: $src" >&2
    exit 4
  fi
  vars="$(grep -oE '\$\{[A-Z_][A-Z0-9_]*\}' "$src" | sort -u | tr '\n' ' ')"
  rendered="$(envsubst "$vars" < "$src")"
  mkdir -p "$(dirname "$OUT")"
  tmp="$(mktemp "$(dirname "$OUT")/.$(basename "$OUT").XXXXXX")"
  printf '%s\n' "$rendered" > "$tmp"
  if ! verify_rendered "$src" "$tmp"; then
    rm -f "$tmp"
    echo "render-only: verification failed; $OUT left untouched" >&2
    exit 4
  fi
  chmod 644 "$tmp"
  mv "$tmp" "$OUT"
  echo "  [write] $OUT  (profile=$PROFILE, secrets-env=$SECRETS_ENV)"
  exit 0
fi

# (template, destination)
mappings=(
  "$TEMPLATES/dev-stack.env.tmpl|$ROOT/.env"
  "$TEMPLATES/api.env.tmpl|$ROOT/api/.env"
  "$TEMPLATES/docuceo.env.tmpl|$ROOT/docuceo/.env"
  "$TEMPLATES/gestion-config.php.tmpl|$ROOT/docker/php/gestion-config.php"
)

drift=0
echo "profile: $PROFILE"
for m in "${mappings[@]}"; do
  src="${m%%|*}"
  dst="${m##*|}"
  if [ ! -f "$src" ]; then
    echo "  [miss] $src — template missing, skip" >&2
    continue
  fi
  # Restrict envsubst to ${VAR} placeholders explicitly used in this template.
  # Without an allowlist, envsubst also eats `$host`, `$_SERVER`, etc. — fatal
  # for the PHP config template, which contains real PHP variables.
  vars="$(grep -oE '\$\{[A-Z_][A-Z0-9_]*\}' "$src" | sort -u | tr '\n' ' ')"
  rendered="$(envsubst "$vars" < "$src")"
  if [ "$CHECK" = 1 ]; then
    if [ -f "$dst" ] && [ "$(cat "$dst")" = "$rendered" ]; then
      echo "  [ok]    $dst"
    else
      echo "  [drift] $dst" >&2
      drift=1
    fi
  else
    # Render to a hidden sibling, verify, then atomic-rename onto $dst. Same-dir
    # mktemp keeps the final `mv` on one filesystem — POSIX rename(2) is atomic,
    # so a Docker bind mount snapshots either the old file or the new one,
    # never a half-written intermediate.
    mkdir -p "$(dirname "$dst")"
    tmp="$(mktemp "$(dirname "$dst")/.$(basename "$dst").XXXXXX")"
    printf '%s\n' "$rendered" > "$tmp"
    if ! verify_rendered "$src" "$tmp"; then
      rm -f "$tmp"
      echo "  [skip]  $dst left untouched" >&2
      exit 4
    fi
    # mktemp creates 0600; promote to world-readable so non-root container
    # users (www-data, etc.) can read the rendered config.
    chmod 644 "$tmp"
    mv "$tmp" "$dst"
    echo "  [write] $dst"
  fi
done

# ---------------------------------------------------------------------------
# Multi-line key material — rendered as raw files (no envsubst, no escaping).
# Sources values directly from SOPS via `sops --extract` so PEM newlines
# survive intact. Silently skips any key not present in SOPS yet.
# ---------------------------------------------------------------------------
render_sops_key_to_file() {
  local var="$1" dest="$2" mode="$3"
  [ -f "$SECRETS_FILE" ] || return 0
  [ -r "${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" ] || return 0
  local tmp; tmp="$(mktemp -t appliceo-key.XXXXXX)"
  if SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" \
       sops -d --extract "[\"$var\"]" "$SECRETS_FILE" > "$tmp" 2>/dev/null \
     && [ -s "$tmp" ]; then
    if [ "$CHECK" = 1 ]; then
      if [ -f "$dest" ] && cmp -s "$tmp" "$dest"; then
        echo "  [ok]    $dest"
      else
        echo "  [drift] $dest" >&2
        drift=1
      fi
    else
      mkdir -p "$(dirname "$dest")"
      mv "$tmp" "$dest"
      chmod "$mode" "$dest" 2>/dev/null || true
      echo "  [write] $dest ($var)"
    fi
  fi
  rm -f "$tmp"
}

render_sops_key_to_file DOCUSIGN_PRIVATE_KEY "$ROOT/api/keys/docusign_private.key" 600

# ---------------------------------------------------------------------------
# Public keys — not secret, kept plaintext per env at config/keys/<env>/.
# Tracks $SECRETS_ENV (the --secrets-env flag, dev by default) so dev/prod
# profiles pull their matching keys.
# ---------------------------------------------------------------------------
copy_public_key() {
  local name="$1" dest="$2"
  local src="$CONFIG/keys/$SECRETS_ENV/$name"
  if [ ! -f "$src" ]; then
    return 0
  fi
  if [ "$CHECK" = 1 ]; then
    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
      echo "  [ok]    $dest"
    else
      echo "  [drift] $dest" >&2
      drift=1
    fi
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    chmod 644 "$dest" 2>/dev/null || true
    echo "  [write] $dest (← $src)"
  fi
}

copy_public_key docusign_public.key "$ROOT/api/keys/docusign_public.key"

if [ "$CHECK" = 1 ]; then
  [ "$drift" = 0 ] && echo "in sync" || { echo "drift detected" >&2; exit 1; }
  exit 0
fi

# Warn about empty required vars (only those that matter for full-local boot).
warn=""
for k in JWT_SECRET V1_AUTH_API_KEY POSTGRES_USER MYSQL_USER PUBLIC_API_URL PUBLIC_PHP_API_URL; do
  if [ -z "${!k:-}" ]; then warn="$warn $k"; fi
done
if [ -n "$warn" ]; then
  echo
  echo "WARNING: empty required vars:$warn" >&2
fi

echo
echo "Done. Run \`docker compose up --build\` to apply."
