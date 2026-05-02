#!/usr/bin/env bash
# Builds shared sibling packages once so docuceo can resolve them at startup.
# Idempotent — skips work when artefacts already exist.
set -euo pipefail

# Note: when a named volume is mounted onto $dir/node_modules, the directory
# exists but is empty on first run. So we check for a real install marker
# (.package-lock.json, written by npm install) rather than dir existence.
needs_install() {
  local dir="$1"
  [ ! -f "$dir/node_modules/.package-lock.json" ]
}

build_if_missing() {
  local dir="$1"
  local marker="$2"
  if needs_install "$dir"; then
    echo "[siblings-init] $dir: npm install"
    (cd "$dir" && npm install --no-audit --no-fund --include=dev)
  else
    echo "[siblings-init] $dir node_modules populated — skip install"
  fi
  if [ -f "$dir/$marker" ]; then
    echo "[siblings-init] $dir already built ($marker present) — skip build"
    return 0
  fi
  echo "[siblings-init] $dir: npm run build"
  (cd "$dir" && npm run build)
}

install_only() {
  local dir="$1"
  if needs_install "$dir"; then
    echo "[siblings-init] $dir: npm install"
    (cd "$dir" && npm install --no-audit --no-fund --include=dev)
  else
    echo "[siblings-init] $dir node_modules populated — skip install"
  fi
}

build_if_missing /workspace/ui dist/index.js
install_only /workspace/lease-config

echo "[siblings-init] done"
