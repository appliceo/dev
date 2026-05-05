#!/usr/bin/env bash
# Ensure every profile in config/profiles/ declares the same set of variable
# KEYS (values may differ — empty is fine when a key doesn't apply to the
# environment). Catches "fix CC, break docker" / "fix docker, break CC" bugs
# at config-rendering time.
#
# Wired into bin/configure.sh — runs before rendering any .env file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
PROFILES_DIR="$ROOT/config/profiles"

if [ ! -d "$PROFILES_DIR" ]; then
  echo "❌ $PROFILES_DIR does not exist" >&2
  exit 2
fi

# Build the set of keys defined per profile.
declare -A keys_per_profile
for f in "$PROFILES_DIR"/*.env; do
  [ -f "$f" ] || continue
  name="$(basename "$f" .env)"
  k="$(grep -oE '^[A-Z_][A-Z0-9_]*=' "$f" | sed 's/=$//' | sort -u | tr '\n' ' ')"
  keys_per_profile[$name]=" $k"
done

# Union of all keys across all profiles.
all_keys="$(for f in "$PROFILES_DIR"/*.env; do
  [ -f "$f" ] || continue
  grep -oE '^[A-Z_][A-Z0-9_]*=' "$f" | sed 's/=$//'
done | sort -u)"

drift=0
for key in $all_keys; do
  for profile in "${!keys_per_profile[@]}"; do
    if [[ "${keys_per_profile[$profile]}" != *" $key "* ]]; then
      echo "❌ $profile.env is missing $key (set to empty if not applicable)" >&2
      drift=1
    fi
  done
done

if [ "$drift" = 0 ]; then
  echo "✓ profiles in sync (${#keys_per_profile[@]} profiles, $(echo "$all_keys" | wc -l | tr -d ' ') keys)"
fi
exit $drift
