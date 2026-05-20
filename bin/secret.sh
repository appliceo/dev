#!/usr/bin/env bash
# Wrapper around SOPS + age for the Appliceo monorepo.
#
# Hybrid storage:
#   config/secrets.dev.sops.yaml   — committed, encrypted
#   config/secrets.prod.sops.yaml  — gitignored HARD; refuses to be tracked
#
# Subcommands:
#   bootstrap                 install age (if missing) + generate user's age key
#   status                    show key + which envs are accessible
#   edit <env>                open encrypted file in $EDITOR (Windows: --no-fifo)
#   view <env>                decrypt to stdout (read-only)
#   seed-prod                 create config/secrets.prod.sops.yaml with the dev keyset
#                             (empty values + OVH_PROD_DB_* added), ready for `edit prod`
#   rotate <KEY> <env>        move KEY -> KEY_PREVIOUS, generate new, save
#   grant <name> <pubkey> <env>   add recipient to .sops.yaml + re-encrypt
#   revoke <name> <env>       remove recipient from .sops.yaml + re-encrypt
#
# Prod safety:
#   - `edit prod` refuses if config/secrets.prod.sops.yaml is tracked by git
#   - prod values must be pushed via `bin/clever-sync.sh --env prod --apply`
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
SOPS_YAML="$ROOT/.sops.yaml"
AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

is_windows() {
  [[ "${OSTYPE:-}" == msys* ]] || [[ "$(uname -s 2>/dev/null)" == MINGW* ]]
}

# On Windows, SOPS edit cannot use FIFOs — fall back to temp file in a
# local-only path that never lives in OneDrive / Dropbox.
configure_windows_runtime() {
  if is_windows; then
    SOPS_EDIT_FLAGS=(--no-fifo)
    if [[ -n "${USERPROFILE:-}" ]]; then
      TMPDIR="$USERPROFILE/AppData/Local/sops-tmp"
    else
      TMPDIR="$HOME/.sops-tmp"
    fi
    mkdir -p "$TMPDIR"
    chmod 700 "$TMPDIR" 2>/dev/null || true
    export TMPDIR
    # Make sure transient plaintext files are cleared even on crash.
    trap 'find "$TMPDIR" -type f -mmin -60 -delete 2>/dev/null || true' EXIT
  else
    SOPS_EDIT_FLAGS=()
  fi
}

env_file() {
  case "$1" in
    dev|prod) printf '%s/config/secrets.%s.sops.yaml' "$ROOT" "$1" ;;
    *) echo "❌ unknown env '$1' (expected dev|prod)" >&2; exit 2 ;;
  esac
}

require_tools() {
  command -v age >/dev/null     || { echo "❌ age not installed — run: $0 bootstrap" >&2; exit 2; }
  command -v age-keygen >/dev/null || { echo "❌ age-keygen not installed — run: $0 bootstrap" >&2; exit 2; }
  command -v sops >/dev/null    || { echo "❌ sops not installed — install via brew/winget/scoop/choco" >&2; exit 2; }
}

require_age_key() {
  if [[ ! -r "$AGE_KEY_FILE" ]]; then
    echo "❌ no age key at $AGE_KEY_FILE — run: $0 bootstrap" >&2
    exit 2
  fi
}

assert_prod_not_tracked() {
  local file="$ROOT/config/secrets.prod.sops.yaml"
  if git -C "$ROOT" ls-files --error-unmatch "config/secrets.prod.sops.yaml" >/dev/null 2>&1; then
    echo "🛑 config/secrets.prod.sops.yaml is tracked by git — that's a HARD-rule violation." >&2
    echo "   Untrack it: git rm --cached config/secrets.prod.sops.yaml" >&2
    exit 1
  fi
}

cmd_bootstrap() {
  if ! command -v age >/dev/null || ! command -v age-keygen >/dev/null; then
    if command -v brew >/dev/null;        then brew install age
    elif command -v apt-get >/dev/null;    then sudo apt-get install -y age
    elif command -v winget >/dev/null;     then winget install FiloSottile.age
    elif command -v scoop >/dev/null;      then scoop install age
    elif command -v choco >/dev/null;      then choco install age -y
    else
      echo "❌ no supported package manager found — install age manually from https://github.com/FiloSottile/age/releases" >&2
      exit 2
    fi
  fi

  if [[ -f "$AGE_KEY_FILE" ]]; then
    echo "✓ age key already exists at $AGE_KEY_FILE"
  else
    mkdir -p "$(dirname "$AGE_KEY_FILE")"
    chmod 700 "$(dirname "$AGE_KEY_FILE")" 2>/dev/null || true
    age-keygen -o "$AGE_KEY_FILE"
    chmod 600 "$AGE_KEY_FILE" 2>/dev/null || true
  fi

  echo ""
  echo "Your age public key (share with the person who grants you access):"
  grep -E '^# public key:' "$AGE_KEY_FILE" | sed 's/^# public key: //'
}

cmd_status() {
  echo "Repo:       $ROOT"
  echo "Sops yaml:  $SOPS_YAML"
  echo "Age key:    $AGE_KEY_FILE"
  if [[ -r "$AGE_KEY_FILE" ]]; then
    echo "Your pubkey: $(grep -E '^# public key:' "$AGE_KEY_FILE" | sed 's/^# public key: //')"
  else
    echo "Your pubkey: (no key — run: $0 bootstrap)"
  fi
  echo ""
  for env in dev prod; do
    local f; f=$(env_file "$env")
    if [[ -f "$f" ]]; then
      if SOPS_AGE_KEY_FILE="$AGE_KEY_FILE" sops -d "$f" >/dev/null 2>&1; then
        printf "  %-8s  ✓ decryptable\n" "$env"
      else
        printf "  %-8s  ✗ no decrypt access\n" "$env"
      fi
    else
      printf "  %-8s  — not present\n" "$env"
    fi
  done
}

cmd_edit() {
  local env="${1:?usage: secret.sh edit <env>}"
  require_tools
  require_age_key
  configure_windows_runtime
  [[ "$env" == prod ]] && assert_prod_not_tracked

  local f; f=$(env_file "$env")
  if [[ ! -f "$f" ]]; then
    echo "Creating new $f"
    # Seed with an empty mapping so sops has something to encrypt.
    printf '# Appliceo %s secrets — managed by bin/secret.sh\n' "$env" > "$f"
    SOPS_AGE_KEY_FILE="$AGE_KEY_FILE" sops --encrypt --in-place "$f"
  fi

  SOPS_AGE_KEY_FILE="$AGE_KEY_FILE" sops "${SOPS_EDIT_FLAGS[@]}" "$f"
}

cmd_view() {
  local env="${1:?usage: secret.sh view <env>}"
  require_tools
  require_age_key
  local f; f=$(env_file "$env")
  [[ -f "$f" ]] || { echo "❌ $f does not exist" >&2; exit 1; }
  SOPS_AGE_KEY_FILE="$AGE_KEY_FILE" sops -d "$f"
}

cmd_seed_prod() {
  require_tools
  require_age_key
  configure_windows_runtime
  assert_prod_not_tracked

  local dev_f prod_f
  dev_f=$(env_file dev)
  prod_f=$(env_file prod)

  if [[ -f "$prod_f" ]]; then
    echo "🛑 $prod_f already exists." >&2
    echo "   To re-seed: delete it first (rm $prod_f), then re-run seed-prod." >&2
    exit 1
  fi
  if [[ ! -f "$dev_f" ]]; then
    echo "❌ $dev_f missing — nothing to template the keyset from." >&2
    exit 1
  fi

  # Sectioned skeleton — mirror of the dev SOPS layout so a cross-env
  # `diff <(secret.sh view dev) <(secret.sh view prod)` stays readable.
  # The dev file is the canonical structure; if you reorganize it, update
  # this function to match.
  # macOS mktemp puts the random suffix at the END regardless of template,
  # so build the .yaml-suffixed path in two steps (sops needs the extension
  # to pick the YAML codec).
  local tmp_base tmp
  tmp_base=$(mktemp -t appliceo-prod-seed.XXXXXX)
  tmp="$tmp_base.yaml"
  mv "$tmp_base" "$tmp"

  cat > "$tmp" <<'SKELETON'
# Appliceo PROD secrets — encrypted with SOPS+age (managed by bin/secret.sh)
#
# This file is gitignored hard. Source of truth for prod values lives in
# Clever Cloud (api/docuceo apps) + OVH (gestion-config.php).
# Decrypt:  bin/secret.sh view prod
# Edit:     bin/secret.sh edit prod
#
# Section order mirrors secrets.dev.sops.yaml — keep them aligned so a
# `diff <(bin/secret.sh view dev) <(bin/secret.sh view prod)` stays readable.

# ─── Internal bridge secrets (api ↔ appliceo-php) ───
# JWT_SECRET must match the value compiled into gestion-config.php so JWTs
# issued by api validate in PHP. V1_AUTH_API_KEY is the static shared secret
# for the PHP→api auth-fallback bridge. *_PREVIOUS slots hold the prior
# value during a rotation overlap window (empty when not rotating).
JWT_SECRET: ""
JWT_SECRET_PREVIOUS: ""
V1_AUTH_API_KEY: ""
V1_AUTH_API_KEY_PREVIOUS: ""

# ─── HTTP Basic Auth gates ───
# PHP_BASIC_AUTH:  user:pass that api uses to reach appliceo-php behind the
#                  .htaccess gate (dev.appliceo.com — prod is open).
# DEV_BASIC_AUTH:  docuceo dev-host guard (middleware skips on docuceo.com).
PHP_BASIC_AUTH: ""
DEV_BASIC_AUTH: ""

# ─── DocuSign (e-signature provider) ───
# JWT app-grant credentials + webhook HMAC.
# DOCUSIGN_PRIVATE_KEY is a multi-line RSA PEM; configure.sh extracts it to
# api/keys/docusign_private.key at render time.
DOCUSIGN_ACCOUNT_ID: ""
DOCUSIGN_INTEGRATION_KEY: ""
DOCUSIGN_USER_ID: ""
DOCUSIGN_PRIVATE_KEY: ""
DOCUSIGN_WEBHOOK_SECRET: ""

# ─── Stripe (subscriptions + payments) ───
# Dev: pk_test_* / sk_test_* / whsec_test_*  (STRIPE_MOCK_MODE bypasses in CI)
# Prod: pk_live_* / sk_live_* / whsec_live_*
STRIPE_PUBLIC_KEY: ""
STRIPE_SECRET_KEY: ""
STRIPE_WEBHOOK_SECRET: ""

# ─── Mailgun (transactional email) ───
# Dev historically empty (stub mailer drops to logs). Real domain-scoped
# key gets minted on rotation day; same domain (mg.appliceo.com) for both
# envs unless we split MX later (parked decision).
MAILGUN_API_KEY: ""

# ─── OVH MySQL credentials (TIER-NAMESPACED — exclusive per env) ───
# Dev SOPS gets OVH_DEV_DB_*; prod SOPS gets OVH_PROD_DB_*. The split is
# intentional: bin/check-profiles.sh skips OVH_(DEV|PROD)_* in the cross-env
# SOPS parity check. Consumed by config/profiles/php-ovh-prod.env at
# render time via ${OVH_PROD_DB_*} references.
OVH_PROD_DB_HOST: ""
OVH_PROD_DB_NAME: ""
OVH_PROD_DB_USER: ""
OVH_PROD_DB_PASSWORD: ""
SKELETON

  # Encrypt. sops-from-the-repo-root picks the recipient via .sops.yaml's
  # `config/secrets.prod.sops.yaml$` rule once we move into place. But we
  # encrypt in /tmp first to avoid leaving plaintext at the SOPS path if
  # encryption fails — so pass --age explicitly + --config /dev/null to skip
  # the rule lookup that wouldn't match our temp path.
  local age_recipient
  age_recipient=$(grep -oE 'age1[a-z0-9]+' "$SOPS_YAML" | head -1)
  if [[ -z "$age_recipient" ]]; then
    echo "❌ no age recipient found in $SOPS_YAML — bootstrap first" >&2
    rm -f "$tmp"
    exit 1
  fi

  if ! SOPS_AGE_KEY_FILE="$AGE_KEY_FILE" sops --encrypt --config /dev/null \
         --age "$age_recipient" --in-place "$tmp"; then
    echo "❌ sops encrypt failed; cleaning up plaintext skeleton" >&2
    rm -f "$tmp"
    exit 1
  fi

  mv "$tmp" "$prod_f"

  echo "✓ created $prod_f (encrypted, sectioned skeleton mirroring dev)"
  echo
  echo "Next steps:"
  echo "  1. bin/secret.sh edit prod   # fill values"
  echo "  2. bin/check-profiles.sh     # verify SOPS dev/prod parity"
  echo "  3. bin/clever-sync.sh --env=prod   # diff against Clever Cloud apps"
}

cmd_rotate() {
  local key="${1:?usage: secret.sh rotate <KEY> <env>}"
  local env="${2:?usage: secret.sh rotate <KEY> <env>}"
  require_tools
  require_age_key
  configure_windows_runtime
  [[ "$env" == prod ]] && assert_prod_not_tracked

  local f; f=$(env_file "$env")
  [[ -f "$f" ]] || { echo "❌ $f does not exist" >&2; exit 1; }

  # Confirmation prompt — rotation is destructive in spirit (old becomes _PREVIOUS).
  read -r -p "About to rotate $key in $env. Continue? [y/N] " ok
  [[ "$ok" =~ ^[yY]$ ]] || { echo "aborted"; exit 0; }

  local new_value
  new_value=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 64)

  # Read current value, write _PREVIOUS, then set new value.
  local current
  current=$(SOPS_AGE_KEY_FILE="$AGE_KEY_FILE" sops -d --extract "[\"$key\"]" "$f" 2>/dev/null || echo "")

  if [[ -n "$current" ]]; then
    SOPS_AGE_KEY_FILE="$AGE_KEY_FILE" sops --set "[\"${key}_PREVIOUS\"] \"$current\"" "$f"
  fi
  SOPS_AGE_KEY_FILE="$AGE_KEY_FILE" sops --set "[\"$key\"] \"$new_value\"" "$f"

  echo "✓ rotated $key in $env ($key_PREVIOUS retained for overlap window)"
  echo "  Next: bin/configure.sh && bin/clever-sync.sh --env $env --apply"
}

cmd_grant() {
  local name="${1:?usage: secret.sh grant <name> <pubkey> <env>}"
  local pubkey="${2:?usage: secret.sh grant <name> <pubkey> <env>}"
  local env="${3:?usage: secret.sh grant <name> <pubkey> <env>}"
  require_tools
  require_age_key
  [[ "$env" == prod ]] && assert_prod_not_tracked

  echo "TODO: append $name ($pubkey) to .sops.yaml recipients for $env, then re-encrypt."
  echo "      Manual path for now: edit .sops.yaml, then run:"
  echo "        sops updatekeys $(env_file "$env")"
  # NOTE: full automation is Phase-1-step-N follow-up. The .sops.yaml editing
  # is yaml-aware; we'll add yq dependency or hand-roll later. For now this
  # documents the operation so the workflow is clear.
}

cmd_revoke() {
  local name="${1:?usage: secret.sh revoke <name> <env>}"
  local env="${2:?usage: secret.sh revoke <name> <env>}"
  echo "TODO: remove $name from .sops.yaml recipients for $env, re-encrypt."
  echo "      Manual path: edit .sops.yaml, then sops updatekeys $(env_file "$env")"
  echo "      ⚠ also rotate every secret the revoked user could read — they may have copies."
}

usage() {
  cat <<EOF
Usage: bin/secret.sh <command> [args]

Commands:
  bootstrap                    install age + generate your keypair
  status                       show key + decrypt access per env
  edit <env>                   edit encrypted file in \$EDITOR
  view <env>                   decrypt to stdout (read-only)
  seed-prod                    create encrypted prod SOPS with dev keyset + OVH_PROD_DB_*
  rotate <KEY> <env>           move KEY -> KEY_PREVIOUS + generate new
  grant <name> <pubkey> <env>  add recipient (see TODO inside)
  revoke <name> <env>          remove recipient (see TODO inside)

env = dev | staging | prod
EOF
}

main() {
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
    bootstrap) cmd_bootstrap "$@" ;;
    status)    cmd_status "$@" ;;
    edit)      cmd_edit "$@" ;;
    view)      cmd_view "$@" ;;
    seed-prod) cmd_seed_prod "$@" ;;
    rotate)    cmd_rotate "$@" ;;
    grant)     cmd_grant "$@" ;;
    revoke)    cmd_revoke "$@" ;;
    ""|-h|--help|help) usage ;;
    *) echo "❌ unknown command: $cmd" >&2; usage; exit 2 ;;
  esac
}

main "$@"
