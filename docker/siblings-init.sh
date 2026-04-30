#!/usr/bin/env bash
# Builds shared sibling packages once so lease-editor and docuceo can resolve
# them at startup. Idempotent — skips work when artefacts already exist.
set -euo pipefail

build_if_missing() {
  local dir="$1"
  local marker="$2"
  if [ -f "$dir/$marker" ]; then
    echo "[siblings-init] $dir already built ($marker present) — skip"
    return 0
  fi
  echo "[siblings-init] $dir: npm install"
  (cd "$dir" && npm install --no-audit --no-fund)
  echo "[siblings-init] $dir: npm run build"
  (cd "$dir" && npm run build)
}

install_only() {
  local dir="$1"
  if [ -d "$dir/node_modules" ]; then
    echo "[siblings-init] $dir node_modules present — skip install"
    return 0
  fi
  echo "[siblings-init] $dir: npm install"
  (cd "$dir" && npm install --no-audit --no-fund)
}

build_if_missing /workspace/appliceo-ui dist/index.js
install_only /workspace/appliceo-lease-config
install_only /workspace/appliceo-lease-editor

echo "[siblings-init] done"
