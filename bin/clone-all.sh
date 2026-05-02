#!/usr/bin/env bash
# Clone every Appliceo repo as a sibling of this dev-stack repo.
# Idempotent: skips repos that already exist; copies .env.example -> .env if missing.
# For repos with a non-default working branch (appliceo-php uses `develop`),
# the script also ensures the branch is checked out on existing clones.
# Usage:  bash bin/clone-all.sh [--with-mobile] [--ssh|--https]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

WITH_MOBILE=0
PROTO=ssh
for a in "$@"; do
  case "$a" in
    --with-mobile) WITH_MOBILE=1 ;;
    --ssh)         PROTO=ssh ;;
    --https)       PROTO=https ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

# Repos: one per line "<dir-name> <github-repo-name> [branch]"
# Empty branch = use the remote's default. appliceo-php tracks `develop`.
core_repos="api api
ui ui
lease-config lease-config
docuceo docuceo
appliceo-php appliceo-php develop"

mobile_repos="EtatDesLieux etat-des-lieux"

repos="$core_repos"
if [ "$WITH_MOBILE" = 1 ]; then
  repos="$repos
$mobile_repos"
fi

repo_url() {
  local name="$1"
  if [ "$PROTO" = ssh ]; then
    echo "git@github.com:appliceo/${name}.git"
  else
    echo "https://github.com/appliceo/${name}.git"
  fi
}

clone_one() {
  local dir="$1" repo="$2" branch="${3:-}"
  local target="$ROOT/$dir"
  if [ -d "$target/.git" ]; then
    echo "[skip] $dir already cloned"
    if [ -n "$branch" ]; then
      local current
      current="$(git -C "$target" branch --show-current 2>/dev/null || true)"
      if [ "$current" != "$branch" ]; then
        echo "[branch] $dir: $current -> $branch"
        git -C "$target" fetch origin "$branch":"$branch" 2>/dev/null || git -C "$target" fetch origin "$branch"
        git -C "$target" checkout "$branch"
      fi
    fi
    return 0
  fi
  echo "[clone] $dir <- $(repo_url "$repo")${branch:+ (branch: $branch)}"
  if [ -n "$branch" ]; then
    git clone --branch "$branch" "$(repo_url "$repo")" "$target"
  else
    git clone "$(repo_url "$repo")" "$target"
  fi
}

seed_env() {
  local dir="$1"
  local target="$ROOT/$dir"
  local example="$target/.env.example"
  local env="$target/.env"
  if [ -f "$example" ] && [ ! -f "$env" ]; then
    cp "$example" "$env"
    echo "[env] $dir/.env <- .env.example"
  fi
}

echo "$repos" | while IFS=' ' read -r dir repo branch; do
  [ -z "$dir" ] && continue
  clone_one "$dir" "$repo" "$branch"
  seed_env "$dir"
done

# Root .env (compose-only)
if [ -f "$ROOT/.env.docker.example" ] && [ ! -f "$ROOT/.env" ]; then
  cp "$ROOT/.env.docker.example" "$ROOT/.env"
  echo "[env] .env <- .env.docker.example"
fi

# Render per-project config from the central templates (idempotent).
if [ -x "$SCRIPT_DIR/configure.sh" ]; then
  echo
  bash "$SCRIPT_DIR/configure.sh" || echo "[warn] configure.sh failed; you may need to run it manually" >&2
fi

echo
echo "Done. Next:"
echo "  cd $ROOT"
echo "  docker compose up --build"
