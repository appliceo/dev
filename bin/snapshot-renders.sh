#!/usr/bin/env bash
# Snapshot every file rendered by bin/configure.sh into a sibling `.back/`
# directory with a timestamp suffix. Optionally re-run configure.sh and
# byte-compare the new output against the snapshot — a determinism check.
#
# Snapshots NEVER overwrite each other (timestamp in filename).
# `.back/` is gitignored globally.
#
# Usage:
#   bin/snapshot-renders.sh             # snapshot only
#   bin/snapshot-renders.sh --verify    # snapshot, regenerate, diff
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

VERIFY=0
for a in "$@"; do
  case "$a" in
    --verify) VERIFY=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

# Files that configure.sh writes. Keep this list in sync with configure.sh.
FILES=(
  ".env"
  "api/.env"
  "docuceo/.env"
  "appliceo-php/.env"
  "docker/php/gestion-config.php"
  "api/keys/docusign_private.key"
  "api/keys/docusign_public.key"
)

STAMP="$(date +%Y%m%d-%H%M%S)"

echo "═══ snapshot (timestamp: $STAMP) ═══"
for f in "${FILES[@]}"; do
  if [ -f "$f" ]; then
    dir=$(dirname "$f")
    base=$(basename "$f")
    mkdir -p "$dir/.back"
    cp -p "$f" "$dir/.back/$base.$STAMP"
    echo "  ✓ $dir/.back/$base.$STAMP"
  else
    echo "  ⚠ $f does not exist — skipping"
  fi
done

if [ "$VERIFY" = 0 ]; then
  echo ""
  echo "Done. Use --verify to also re-run configure.sh and compare."
  exit 0
fi

echo ""
echo "═══ re-running bin/configure.sh ═══"
bin/configure.sh 2>&1 | sed 's/^/  /'

echo ""
echo "═══ byte-compare against this run's snapshot ═══"
all_ok=1
for f in "${FILES[@]}"; do
  dir=$(dirname "$f")
  base=$(basename "$f")
  snap="$dir/.back/$base.$STAMP"
  if [ ! -f "$snap" ]; then
    echo "  ⚠  $f → no snapshot (was missing before regen)"
    continue
  fi
  if cmp -s "$f" "$snap"; then
    echo "  ✓  $f"
  else
    echo "  ✗  $f DIFFERS from snapshot"
    all_ok=0
    diff -u "$snap" "$f" 2>&1 | head -20 | sed 's/^/       /'
  fi
done

echo ""
if [ "$all_ok" = 1 ]; then
  echo "✅ configure.sh is deterministic — every render matched its snapshot."
else
  echo "⚠ Some renders changed since the snapshot. Review diffs above."
  exit 1
fi
