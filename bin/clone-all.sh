#!/usr/bin/env bash
# Clone every Appliceo repo as a sibling of this dev-stack repo.
# Idempotent: skips repos that already exist; copies .env.example -> .env if missing.
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

# Repos: one per line "<dir-name> <github-repo-name>"
# Repos that should retain the appliceo- prefix list it explicitly.
core_repos="api api
ui ui
lease-config lease-config
lease-editor lease-editor
docuceo docuceo
appliceo-php appliceo-php"

mobile_repos="lease-editor-native lease-editor-native
EtatDesLieux etat-des-lieux"

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
  local dir="$1" repo="$2"
  local target="$ROOT/$dir"
  if [ -d "$target/.git" ]; then
    echo "[skip] $dir already cloned"
    return 0
  fi
  echo "[clone] $dir <- $(repo_url "$repo")"
  git clone "$(repo_url "$repo")" "$target"
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

echo "$repos" | while IFS=' ' read -r dir repo; do
  [ -z "$dir" ] && continue
  clone_one "$dir" "$repo"
  seed_env "$dir"
done

# Root .env (compose-only)
if [ -f "$ROOT/.env.docker.example" ] && [ ! -f "$ROOT/.env" ]; then
  cp "$ROOT/.env.docker.example" "$ROOT/.env"
  echo "[env] .env <- .env.docker.example"
fi

echo
echo "Done. Next:"
echo "  cd $ROOT"
echo "  docker compose up --build"
