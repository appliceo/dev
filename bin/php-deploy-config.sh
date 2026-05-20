#!/usr/bin/env bash
# Render gestion-config.php for an OVH target (dev|prod) into an ignored
# staging dir, then optionally rsync it to the OVH server. Mirrors the
# pattern in appliceo-php/tools/deploy.sh (dry-run by default, --confirm
# to push, backup-before-overwrite via rsync --backup-dir).
#
# Usage:
#   bash bin/php-deploy-config.sh dev|prod              # generate only
#   bash bin/php-deploy-config.sh dev --upload          # generate + rsync dry-run
#   bash bin/php-deploy-config.sh dev --confirm         # generate + rsync for real
#   bash bin/php-deploy-config.sh prod --confirm        # prod typed-gate
#
# Flags:
#   --upload       generate + show rsync dry-run (no transfer)
#   --confirm      generate + rsync for real (implies --upload, prompts confirm)
#   --verbose      pass through to rsync
#   --ssh-key PATH override default SSH key (~/.ssh/ovh_rsa)
#
# The staging dir lives at appliceo-php/.deploy-config/<env>/ (gitignored)
# so a rendered config can be inspected before upload.
set -euo pipefail

# ── ANSI colors ───────────────────────────────────────────
RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
BLUE=$'\033[34m'; GRAY=$'\033[90m'; BOLD=$'\033[1m'; RST=$'\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
PHP_ROOT="$ROOT/appliceo-php"

# ── Parse args ────────────────────────────────────────────
ENV_TARGET=""
DO_UPLOAD=0
DO_CONFIRM=0
VERBOSE=0
SSH_KEY=""
SSH_KEY_EXPLICIT=0
while [ $# -gt 0 ]; do
  case "$1" in
    dev|prod)     ENV_TARGET="$1"; shift ;;
    --upload)     DO_UPLOAD=1; shift ;;
    --confirm)    DO_CONFIRM=1; DO_UPLOAD=1; shift ;;
    --verbose|-v) VERBOSE=1; shift ;;
    --ssh-key|-k)
      [ -z "${2:-}" ] && { echo "${RED}--ssh-key needs a path${RST}" >&2; exit 2; }
      SSH_KEY="$2"; SSH_KEY_EXPLICIT=1; shift 2 ;;
    -h|--help) sed -n '2,22p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) echo "${RED}unknown flag: $1${RST}" >&2; exit 2 ;;
  esac
done

if [ -z "$ENV_TARGET" ]; then
  echo "${RED}positional dev|prod required${RST}" >&2; exit 2
fi

# ── Profile + paths ───────────────────────────────────────
PROFILE="php-ovh-$ENV_TARGET"
PROFILE_FILE="$ROOT/config/profiles/$PROFILE.env"
SECRETS_FILE="$ROOT/config/secrets.$ENV_TARGET.sops.yaml"
STAGE_DIR="$PHP_ROOT/.deploy-config/$ENV_TARGET/gestion"
STAGE_FILE="$STAGE_DIR/config.php"

# Remote layout — matches appliceo-php/tools/deploy.sh REMOTE_PATH conventions.
REMOTE_USER="appliceopj"
REMOTE_HOST="ssh.cluster011.hosting.ovh.net"
case "$ENV_TARGET" in
  dev)  REMOTE_BASE="dev" ;;
  prod) REMOTE_BASE="www" ;;
esac
REMOTE_CONFIG_PATH="$REMOTE_BASE/gestion/config.php"

# ── Pre-flight ───────────────────────────────────────────
if [ ! -f "$PROFILE_FILE" ]; then
  echo "${RED}❌ Missing profile: $PROFILE_FILE${RST}" >&2
  exit 4
fi

if [ "$ENV_TARGET" = "prod" ] && [ ! -f "$SECRETS_FILE" ]; then
  echo "${RED}❌ Missing $SECRETS_FILE${RST}" >&2
  echo "${RED}   Run: bin/secret.sh seed-prod   # then bin/secret.sh edit prod${RST}" >&2
  exit 4
fi

# Reject the prod profile if its FIXME placeholders still survive. Cheap
# check — better here than catching a broken config in production.
if [ "$ENV_TARGET" = "prod" ]; then
  if grep -q '__fill_before_first_prod_render__' "$PROFILE_FILE"; then
    echo "${RED}❌ $PROFILE_FILE still has __fill_before_first_prod_render__ placeholders.${RST}" >&2
    echo "${RED}   Fill them in before rendering prod config.${RST}" >&2
    exit 4
  fi
fi

# ── Render via configure.sh --render-only ────────────────
echo "${BOLD}🔧 php-deploy-config — env=${ENV_TARGET}${RST}"
echo "  Profile:  $PROFILE_FILE"
echo "  Secrets:  $SECRETS_FILE"
echo "  Stage:    $STAGE_FILE"
echo

mkdir -p "$STAGE_DIR"
bash "$ROOT/bin/configure.sh" \
  --profile="$PROFILE" \
  --secrets-env="$ENV_TARGET" \
  --render-only=gestion-config.php.tmpl \
  --out="$STAGE_FILE"

# Double-check no surviving placeholders (configure.sh already does this,
# but the FIXME marker isn't a ${VAR} so let's re-grep for it post-render).
if grep -q '__fill_before_first_prod_render__' "$STAGE_FILE"; then
  echo "${RED}❌ rendered file still contains __fill_before_first_prod_render__${RST}" >&2
  rm -f "$STAGE_FILE"
  exit 4
fi

if [ "$DO_UPLOAD" = 0 ]; then
  echo
  echo "${GREEN}✓ Rendered: $STAGE_FILE${RST}"
  echo "${GRAY}  Inspect, then re-run with --upload (dry-run rsync) or --confirm (push).${RST}"
  exit 0
fi

# ── SSH key selection (mirrors deploy.sh) ────────────────
if [ "$SSH_KEY_EXPLICIT" = 0 ]; then
  if [ -f "$HOME/.ssh/ovh_rsa" ]; then
    SSH_KEY="$HOME/.ssh/ovh_rsa"
    echo "${GRAY}  SSH key: $SSH_KEY${RST}"
  else
    echo "${YELLOW}  SSH key: none — falling back to password auth${RST}"
  fi
fi

# ── Prod typed-gate ──────────────────────────────────────
if [ "$DO_CONFIRM" = 1 ] && [ "$ENV_TARGET" = "prod" ]; then
  echo
  echo "${RED}${BOLD}⚠  About to overwrite ~/${REMOTE_CONFIG_PATH} on $REMOTE_HOST.${RST}"
  echo "${RED}   This is PRODUCTION (appliceo.com).${RST}"
  read -r -p "Type 'prod' to confirm: " _ok
  if [ "$_ok" != "prod" ]; then
    echo "aborted."; exit 0
  fi
fi

# ── Build rsync command ──────────────────────────────────
COMMIT_HASH="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
BACKUP_DIR="~/backups/config_${ENV_TARGET}_$(date +%Y%m%d_%H%M%S)_${COMMIT_HASH}"

# Single-file rsync. --backup + --backup-dir snapshots the existing
# config.php to ~/backups/... so a broken render is reverted with:
#   ssh <host> "mv ~/backups/config_<env>_<TS>_<HASH>/gestion/config.php ~/<env>/gestion/config.php"
RSYNC_CMD=(rsync -avz --progress
           --backup --backup-dir="$BACKUP_DIR"
           --relative)
[ -n "$SSH_KEY" ] && RSYNC_CMD+=(-e "ssh -i $SSH_KEY")
[ "$VERBOSE" = 1 ] && RSYNC_CMD+=(--verbose)
[ "$DO_CONFIRM" = 0 ] && RSYNC_CMD+=(--dry-run)

# Use --relative with a path-prefixed src so the trailing component lands
# at $REMOTE_BASE/gestion/config.php exactly. cd into stage_root, pass the
# relative path; that keeps the remote target deterministic.
STAGE_ROOT="$PHP_ROOT/.deploy-config/$ENV_TARGET"
RSYNC_CMD+=("./gestion/config.php")
RSYNC_CMD+=("$REMOTE_USER@$REMOTE_HOST:$REMOTE_BASE/")

echo
echo "${BLUE}━━━ rsync $([ "$DO_CONFIRM" = 0 ] && echo '(dry-run)' || echo '(APPLY)') ━━━${RST}"
echo "  cd $STAGE_ROOT"
echo "  ${RSYNC_CMD[*]}"
echo

# Execute from the stage root so --relative computes the right path.
(cd "$STAGE_ROOT" && "${RSYNC_CMD[@]}")

if [ "$DO_CONFIRM" = 0 ]; then
  echo
  echo "${GREEN}✓ Dry-run complete. Re-run with --confirm to actually push.${RST}"
  exit 0
fi

# ── Post-sync php -l on remote ───────────────────────────
echo
echo "${BLUE}━━━ Remote syntax check ━━━${RST}"
SSH_CMD=(ssh)
[ -n "$SSH_KEY" ] && SSH_CMD+=(-i "$SSH_KEY")
SSH_CMD+=("$REMOTE_USER@$REMOTE_HOST" "php -d short_open_tag=On -l ~/$REMOTE_CONFIG_PATH")
if "${SSH_CMD[@]}"; then
  echo "${GREEN}✓ Remote php -l: OK${RST}"
  echo "${GREEN}✓ Backup at ~/$BACKUP_DIR/gestion/config.php on $REMOTE_HOST${RST}"
else
  echo "${RED}❌ Remote php -l FAILED.${RST}" >&2
  echo "${YELLOW}   Rollback:${RST}" >&2
  echo "${YELLOW}     ssh $REMOTE_USER@$REMOTE_HOST 'mv ~/$BACKUP_DIR/gestion/config.php ~/$REMOTE_CONFIG_PATH'${RST}" >&2
  exit 5
fi
