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

# ----------------------------------------------------------------------------
# SOPS secret-file parity check.
# Compares declared keys across config/secrets.{dev,staging,prod}.sops.yaml.
# Skipped silently when sops binary is missing or the user has no decrypt
# access (fresh clone before bootstrap).
# ----------------------------------------------------------------------------
SECRETS_DIR="$ROOT/config"
AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

if ! command -v sops >/dev/null 2>&1 || [ ! -r "$AGE_KEY_FILE" ]; then
  # No sops or no key — silent skip.
  exit $drift
fi

declare -A keys_per_sops
sops_files=0
for env in dev staging prod; do
  f="$SECRETS_DIR/secrets.$env.sops.yaml"
  [ -f "$f" ] || continue
  decoded=$(SOPS_AGE_KEY_FILE="$AGE_KEY_FILE" sops -d --output-type=dotenv "$f" 2>/dev/null || true)
  [ -n "$decoded" ] || continue  # missing decrypt access — skip silently
  k=$(printf '%s\n' "$decoded" | grep -oE '^[A-Z_][A-Z0-9_]*=' | sed 's/=$//' | sort -u | tr '\n' ' ')
  keys_per_sops[$env]=" $k"
  sops_files=$((sops_files + 1))
done

if [ "$sops_files" -lt 2 ]; then
  exit $drift  # nothing to compare
fi

sops_all=$(for env in "${!keys_per_sops[@]}"; do
  printf '%s' "${keys_per_sops[$env]}"
done | tr ' ' '\n' | sort -u | grep -v '^$')

for key in $sops_all; do
  for env in "${!keys_per_sops[@]}"; do
    if [[ "${keys_per_sops[$env]}" != *" $key "* ]]; then
      echo "❌ secrets.$env.sops.yaml is missing $key (add via: bin/secret.sh edit $env)" >&2
      drift=1
    fi
  done
done

if [ "$drift" = 0 ] && [ "$sops_files" -ge 2 ]; then
  echo "✓ SOPS secret files in sync ($sops_files env, $(echo "$sops_all" | wc -l | tr -d ' ') keys)"
fi

exit $drift
