#!/usr/bin/env bash
# Show the status of every Appliceo repo (this dev-stack + siblings):
# branch, clean/dirty, ahead/behind origin. Fetches each repo first so the
# ahead/behind counts reflect the latest remote tips.
# Usage:  bash bin/status.sh [--with-mobile] [--no-fetch]
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

WITH_MOBILE=0
DO_FETCH=1
for a in "$@"; do
  case "$a" in
    --with-mobile) WITH_MOBILE=1 ;;
    --no-fetch)    DO_FETCH=0 ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

# Colors (only when stdout is a tty)
if [ -t 1 ]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_BLUE=$'\033[34m'
  C_CYAN=$'\033[36m'
else
  C_RESET= C_BOLD= C_DIM= C_GREEN= C_YELLOW= C_RED= C_BLUE= C_CYAN=
fi

core_dirs="
.
api
ui
lease-config
docuceo
appliceo-php
"

mobile_dirs="
EtatDesLieux
"

dirs="$core_dirs"
[ "$WITH_MOBILE" = 1 ] && dirs="$dirs$mobile_dirs"

# Header
printf "${C_BOLD}%-22s %-12s %-30s %s${C_RESET}\n" "repo" "branch" "remote" "working tree"
printf "${C_DIM}%s${C_RESET}\n" "──────────────────────────────────────────────────────────────────────────────────"

status_one() {
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
    printf "  %-20s ${C_DIM}—${C_RESET}            ${C_DIM}—${C_RESET}                              ${C_DIM}❓ not cloned${C_RESET}\n" "$label"
    return 0
  fi

  local branch
  branch="$(git -C "$target" branch --show-current 2>/dev/null || true)"
  if [ -z "$branch" ]; then
    branch="(detached)"
  fi

  # Fetch quietly so ahead/behind is current
  if [ "$DO_FETCH" = 1 ]; then
    git -C "$target" fetch --quiet 2>/dev/null || true
  fi

  # Working tree state
  local dirty_count
  dirty_count=$(git -C "$target" status --porcelain | wc -l | tr -d ' ')
  local tree_str
  if [ "$dirty_count" = "0" ]; then
    tree_str="${C_GREEN}✅ clean${C_RESET}"
  else
    tree_str="${C_RED}📝 ${dirty_count} change(s)${C_RESET}"
  fi

  # Remote sync
  local remote_str
  if ! git -C "$target" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    remote_str="${C_DIM}❓ no upstream${C_RESET}"
  else
    local ahead behind counts
    counts=$(git -C "$target" rev-list --left-right --count "HEAD...@{u}" 2>/dev/null || echo "0	0")
    ahead=$(echo "$counts" | awk '{print $1}')
    behind=$(echo "$counts" | awk '{print $2}')
    if [ "$ahead" = "0" ] && [ "$behind" = "0" ]; then
      remote_str="${C_GREEN}✅ in sync${C_RESET}"
    elif [ "$behind" -gt 0 ] && [ "$ahead" = "0" ]; then
      remote_str="${C_YELLOW}⬇️  ${behind} to pull${C_RESET}"
    elif [ "$ahead" -gt 0 ] && [ "$behind" = "0" ]; then
      remote_str="${C_BLUE}⬆️  ${ahead} to push${C_RESET}"
    else
      remote_str="${C_RED}🔀 diverged (${ahead}↑ ${behind}↓)${C_RESET}"
    fi
  fi

  printf "  ${C_CYAN}%-20s${C_RESET} ${C_BOLD}%-12s${C_RESET} %-30b %b\n" "$label" "$branch" "$remote_str" "$tree_str"
}

while IFS= read -r d; do
  [ -z "$d" ] && continue
  status_one "$d"
done <<EOF
$dirs
EOF
