#!/usr/bin/env bash
# Orchestrator — sync PHP code + render and push gestion-config.php to OVH.
# Wraps two existing scripts in deterministic order:
#   1. appliceo-php/tools/deploy.sh <env>          # code (excludes config)
#   2. bin/php-deploy-config.sh <env> --upload     # config
#
# Usage:
#   bash bin/php-deploy.sh dev|prod                 # both dry-runs
#   bash bin/php-deploy.sh dev --confirm            # both apply
#   bash bin/php-deploy.sh dev --code-only          # skip config step
#   bash bin/php-deploy.sh dev --config-only        # skip code step
#
# Flags propagate to children: --confirm, --verbose, --ssh-key.
# CC env vars are NOT touched — that's bin/clever-sync.sh.
set -euo pipefail

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
BLUE=$'\033[34m'; BOLD=$'\033[1m'; RST=$'\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

ENV_TARGET=""
DO_CONFIRM=0
DO_CODE=1
DO_CONFIG=1
VERBOSE=0
SSH_KEY=""
SSH_KEY_EXPLICIT=0
while [ $# -gt 0 ]; do
  case "$1" in
    dev|prod)      ENV_TARGET="$1"; shift ;;
    --confirm)     DO_CONFIRM=1; shift ;;
    --code-only)   DO_CONFIG=0; shift ;;
    --config-only) DO_CODE=0; shift ;;
    --verbose|-v)  VERBOSE=1; shift ;;
    --ssh-key|-k)
      [ -z "${2:-}" ] && { echo "${RED}--ssh-key needs a path${RST}" >&2; exit 2; }
      SSH_KEY="$2"; SSH_KEY_EXPLICIT=1; shift 2 ;;
    -h|--help) sed -n '2,16p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) echo "${RED}unknown flag: $1${RST}" >&2; exit 2 ;;
  esac
done

if [ -z "$ENV_TARGET" ]; then
  echo "${RED}positional dev|prod required${RST}" >&2; exit 2
fi
if [ "$DO_CODE" = 0 ] && [ "$DO_CONFIG" = 0 ]; then
  echo "${RED}--code-only and --config-only are mutually exclusive${RST}" >&2; exit 2
fi

mode="dry-run"
[ "$DO_CONFIRM" = 1 ] && mode="${BOLD}${GREEN}APPLY${RST}"
env_color="$BLUE"
[ "$ENV_TARGET" = "prod" ] && env_color="$RED"

echo "${BOLD}🚚 php-deploy — env=${env_color}${ENV_TARGET}${RST}${BOLD}  mode=${mode}${RST}"
echo "  Code:   $([ "$DO_CODE" = 1 ] && echo yes || echo SKIP)"
echo "  Config: $([ "$DO_CONFIG" = 1 ] && echo yes || echo SKIP)"
echo

# Pass-through args common to both children.
common=()
[ "$DO_CONFIRM" = 1 ] && common+=(--confirm)
[ "$VERBOSE" = 1 ] && common+=(--verbose)
[ "$SSH_KEY_EXPLICIT" = 1 ] && common+=(--ssh-key "$SSH_KEY")

# ── 1. Code rsync ─────────────────────────────────────────
if [ "$DO_CODE" = 1 ]; then
  echo "${BOLD}${BLUE}━━━ 1/2 code rsync (appliceo-php/tools/deploy.sh) ━━━${RST}"
  if [ ! -x "$ROOT/appliceo-php/tools/deploy.sh" ]; then
    echo "${RED}❌ $ROOT/appliceo-php/tools/deploy.sh not found / not executable${RST}" >&2
    exit 4
  fi
  bash "$ROOT/appliceo-php/tools/deploy.sh" "$ENV_TARGET" "${common[@]}"
  echo
fi

# ── 2. Config render + rsync ─────────────────────────────
if [ "$DO_CONFIG" = 1 ]; then
  echo "${BOLD}${BLUE}━━━ 2/2 config render + rsync (bin/php-deploy-config.sh) ━━━${RST}"
  bash "$SCRIPT_DIR/php-deploy-config.sh" "$ENV_TARGET" --upload "${common[@]}"
fi

echo
echo "${GREEN}✓ php-deploy complete (mode: $([ "$DO_CONFIRM" = 1 ] && echo APPLY || echo dry-run))${RST}"
