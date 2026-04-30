#!/usr/bin/env bash
# Pull every Appliceo repo (this dev-stack + all sibling projects).
# Skips repos with uncommitted changes or detached HEAD; reports them.
# Uses --ff-only so divergent histories don't get merged/rebased silently.
# Usage:  bash bin/pull-all.sh [--with-mobile]
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

WITH_MOBILE=0
for a in "$@"; do
  case "$a" in
    --with-mobile) WITH_MOBILE=1 ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

# Same dir list as bin/clone-all.sh. Dev-stack itself listed first.
core_dirs="
.
api
ui
lease-config
lease-editor
docuceo
appliceo-php
"

mobile_dirs="
lease-editor-native
EtatDesLieux
"

dirs="$core_dirs"
[ "$WITH_MOBILE" = 1 ] && dirs="$dirs$mobile_dirs"

failed=""

pull_one() {
  local rel="$1"
  local target
  if [ "$rel" = "." ]; then
    target="$ROOT"
  else
    target="$ROOT/$rel"
  fi
  local label="$rel"
  [ "$rel" = "." ] && label="(dev-stack)"

  if [ ! -d "$target/.git" ]; then
    echo "[skip] $label  — not a git repo"
    return 0
  fi

  local branch
  branch="$(git -C "$target" branch --show-current 2>/dev/null || true)"
  if [ -z "$branch" ]; then
    echo "[skip] $label  — detached HEAD"
    failed="$failed $label"
    return 0
  fi

  if ! git -C "$target" diff --quiet || ! git -C "$target" diff --cached --quiet; then
    echo "[skip] $label  — uncommitted changes (branch: $branch)"
    failed="$failed $label"
    return 0
  fi

  echo "[pull] $label  ($branch)"
  if ! git -C "$target" pull --ff-only --quiet; then
    echo "[fail] $label  — pull rejected (diverged or no upstream?)"
    failed="$failed $label"
  fi
}

# Avoid `echo "$dirs" | while …` — that runs the loop in a subshell and
# clobbers updates to `failed`.
while IFS= read -r d; do
  [ -z "$d" ] && continue
  pull_one "$d"
done <<EOF
$dirs
EOF

if [ -n "$failed" ]; then
  echo
  echo "Some repos need attention:$failed"
  exit 1
fi
echo
echo "All in sync."
