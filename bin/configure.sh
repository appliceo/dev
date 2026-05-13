#!/usr/bin/env bash
# Render every per-project .env file + gestion/config.php from the dev-stack's
# central config (defaults + active profile + local.env).
# Idempotent — re-run any time. Overwrites the rendered files in place.
# Usage:  bash bin/configure.sh [--profile=full-local|frontends-only|staging] [--check]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG="$ROOT/config"
TEMPLATES="$CONFIG/templates"

# Self-install the committed git hooks (idempotent — sets core.hooksPath once).
if [ -d "$ROOT/hooks" ] && [ -x "$ROOT/hooks/pre-commit" ]; then
  current_hooks=$(git -C "$ROOT" config --get core.hooksPath 2>/dev/null || true)
  if [ "$current_hooks" != "hooks" ]; then
    git -C "$ROOT" config core.hooksPath hooks
    echo "[hooks] core.hooksPath set to hooks/ (pre-commit guardrails active)"
  fi
fi

PROFILE=full-local
CHECK=0
for a in "$@"; do
  case "$a" in
    --profile=*) PROFILE="${a#--profile=}" ;;
    --check)     CHECK=1 ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

PROFILE_FILE="$CONFIG/profiles/$PROFILE.env"
if [ ! -f "$PROFILE_FILE" ]; then
  echo "no such profile: $PROFILE_FILE" >&2
  echo "available:" >&2
  ls "$CONFIG/profiles/" | sed 's/\.env$//; s/^/  /' >&2
  exit 2
fi

# Source defaults → profile → SOPS-encrypted dev secrets → local.env override.
# set -a auto-exports each sourced file's KEY=VALUE assignments.
set -a
# shellcheck source=/dev/null
. "$CONFIG/defaults.env"
# shellcheck source=/dev/null
. "$PROFILE_FILE"

# Inject SOPS-decrypted dev secrets, if available. Skipped gracefully when:
#   - sops binary not installed (fresh clone)
#   - user has no age key yet (pre-bootstrap)
#   - secrets file missing
# That keeps a fresh clone runnable up to the warning at the bottom.
SECRETS_FILE="$CONFIG/secrets.dev.sops.yaml"
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

if [ -f "$CONFIG/local.env" ]; then
  # shellcheck source=/dev/null
  . "$CONFIG/local.env"
fi
set +a

if ! command -v envsubst >/dev/null 2>&1; then
  echo "envsubst not found. Install gettext (macOS: brew install gettext)." >&2
  exit 3
fi

# (template, destination)
mappings=(
  "$TEMPLATES/dev-stack.env.tmpl|$ROOT/.env"
  "$TEMPLATES/api.env.tmpl|$ROOT/api/.env"
  "$TEMPLATES/docuceo.env.tmpl|$ROOT/docuceo/.env"
  "$TEMPLATES/appliceo-php.env.tmpl|$ROOT/appliceo-php/.env"
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
    mkdir -p "$(dirname "$dst")"
    printf '%s\n' "$rendered" > "$dst"
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
# Picks "dev" by default (matches the SOPS file currently sourced above).
# Per-profile env mapping comes in Phase 5 (prod cutover).
# ---------------------------------------------------------------------------
SECRETS_ENV=dev
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
