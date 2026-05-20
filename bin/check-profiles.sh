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

# Profiles split into groups by purpose. Cross-group parity isn't useful —
# different groups configure different stacks:
#   stack:   full Docker-compose dev stack (api + docuceo + PHP all in one)
#   ovh-php: just the gestion-config.php render for OVH dev/prod
#   cc:      Clever Cloud Node app env (api + docuceo on CC)
# Parity WITHIN each group catches the real bug: "added a key for one env,
# forgot the other".
declare -A PROFILE_GROUPS=(
  [stack]="full-local"
  [ovh-php]="php-ovh-dev php-ovh-prod"
  [cc]="clever-dev clever-prod"
)

# Build the set of keys defined per profile.
declare -A keys_per_profile
for f in "$PROFILES_DIR"/*.env; do
  [ -f "$f" ] || continue
  name="$(basename "$f" .env)"
  k="$(grep -oE '^[A-Z_][A-Z0-9_]*=' "$f" | sed 's/=$//' | sort -u | tr '\n' ' ')"
  keys_per_profile[$name]=" $k"
done

drift=0
for group in "${!PROFILE_GROUPS[@]}"; do
  members=(${PROFILE_GROUPS[$group]})
  # Per-group union: only keys declared in *this* group's profiles.
  group_keys=""
  group_present_count=0
  for p in "${members[@]}"; do
    f="$PROFILES_DIR/$p.env"
    [ -f "$f" ] || continue
    group_present_count=$(( group_present_count + 1 ))
    group_keys="$group_keys"$'\n'"$(grep -oE '^[A-Z_][A-Z0-9_]*=' "$f" | sed 's/=$//')"
  done
  if [ "$group_present_count" -le 1 ]; then
    # Single-member group can't drift against itself — skip.
    [ "$group_present_count" = 1 ] && echo "✓ $group group: 1 profile (nothing to compare)"
    continue
  fi
  group_keys="$(printf '%s' "$group_keys" | sort -u | grep -v '^$' || true)"
  group_drift=0
  for key in $group_keys; do
    for p in "${members[@]}"; do
      [ -f "$PROFILES_DIR/$p.env" ] || continue
      if [[ "${keys_per_profile[$p]:-}" != *" $key "* ]]; then
        echo "❌ [$group] $p.env is missing $key (set to empty if not applicable)" >&2
        group_drift=1
      fi
    done
  done
  drift=$(( drift + group_drift ))
  if [ "$group_drift" = 0 ]; then
    printf '✓ %s group: %d profiles, %d keys in sync\n' \
      "$group" "$group_present_count" "$(echo "$group_keys" | wc -l | tr -d ' ')"
  fi
done

# ----------------------------------------------------------------------------
# SOPS secret-file parity check.
# Compares declared keys across config/secrets.{dev,prod}.sops.yaml.
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
for env in dev prod; do
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

# Tier-namespaced keys are exclusive by design — OVH_DEV_* live only in
# dev SOPS, OVH_PROD_* only in prod. Skip them in the cross-env parity check
# (they're documentation-shaped: same purpose, different value-target).
is_tier_namespaced() {
  case "$1" in
    OVH_DEV_*|OVH_PROD_*) return 0 ;;
    *) return 1 ;;
  esac
}

for key in $sops_all; do
  is_tier_namespaced "$key" && continue
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
