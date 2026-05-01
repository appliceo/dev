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

# Source defaults → profile → local (if present). set -a auto-exports.
set -a
# shellcheck source=/dev/null
. "$CONFIG/defaults.env"
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
  rendered="$(envsubst < "$src")"
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
