#!/usr/bin/env bash
# Orchestrate test runs across the monorepo and render a static dashboard at
# test-results/index.html. Each suite stays the source of truth for its own
# reporter format; this script just runs them, captures JSON summaries, and
# stitches together a navigable index page.
#
# Usage:
#   bin/run-tests.sh                       # all suites, no coverage
#   bin/run-tests.sh --api                 # only api
#   bin/run-tests.sh --lease-config --docuceo
#   bin/run-tests.sh --all --coverage
#   bin/run-tests.sh --integration         # lease-config integration suite
#   bin/run-tests.sh --e2e --report        # e2e then open dashboard
#   bin/run-tests.sh --report              # just regenerate + open dashboard

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$ROOT/test-results"
DASHBOARD="$RESULTS_DIR/index.html"

# ── Flag parsing ─────────────────────────────────────────────────────────────

run_api=0
run_lease_config=0
run_docuceo=0
run_e2e=0
coverage=0
integration=0
open_report=0

while [ $# -gt 0 ]; do
  case "$1" in
    --api) run_api=1 ;;
    --lease-config) run_lease_config=1 ;;
    --docuceo) run_docuceo=1 ;;
    --e2e) run_e2e=1 ;;
    --all) run_api=1; run_lease_config=1; run_docuceo=1; run_e2e=1 ;;
    --coverage) coverage=1 ;;
    --integration) integration=1 ;;
    --report) open_report=1 ;;
    -h|--help)
      sed -n '2,15p' "$0"
      exit 0
      ;;
    *) echo "❌ Unknown flag: $1" >&2; exit 2 ;;
  esac
  shift
done

# No suite selected → run everything
if [ $((run_api + run_lease_config + run_docuceo + run_e2e)) -eq 0 ] && [ $open_report -eq 0 ]; then
  run_api=1; run_lease_config=1; run_docuceo=1; run_e2e=1
fi

mkdir -p "$RESULTS_DIR/api" "$RESULTS_DIR/lease-config" "$RESULTS_DIR/docuceo" "$RESULTS_DIR/e2e"

# ── Per-suite runners ────────────────────────────────────────────────────────

declare -A status   # suite → "pass"|"fail"|"skip"
declare -A summary  # suite → human one-line summary

run_suite_api () {
  echo "━━━ api ━━━"
  pushd "$ROOT/api" >/dev/null

  local script="test"
  [ $coverage -eq 1 ] && script="test:coverage"

  local log="$RESULTS_DIR/api/run.log"
  # node:test summary lines are `ℹ tests N` / `ℹ pass N` / `ℹ fail N` — tee log
  if npm run "$script" 2>&1 | tee "$log"; then
    : # exit code captured below from PIPESTATUS
  fi
  local rc=${PIPESTATUS[0]}

  local pass fail tests
  pass=$(grep -E "^ℹ pass " "$log" | tail -1 | awk '{print $3}')
  fail=$(grep -E "^ℹ fail " "$log" | tail -1 | awk '{print $3}')
  tests=$(grep -E "^ℹ tests " "$log" | tail -1 | awk '{print $3}')

  # Copy coverage HTML if produced
  if [ $coverage -eq 1 ] && [ -d coverage ]; then
    rm -rf "$RESULTS_DIR/api/coverage"
    cp -R coverage "$RESULTS_DIR/api/coverage"
  fi

  status[api]=$([ $rc -eq 0 ] && echo pass || echo fail)
  summary[api]="${pass:-0} passed, ${fail:-0} failed, ${tests:-0} total"
  popd >/dev/null
}

run_suite_lease_config () {
  echo "━━━ lease-config ━━━"
  pushd "$ROOT/lease-config" >/dev/null

  local script="test"
  [ $coverage -eq 1 ] && script="test:coverage"
  [ $integration -eq 1 ] && script="test:integration"

  local log="$RESULTS_DIR/lease-config/run.log"
  npm run "$script" 2>&1 | tee "$log"
  local rc=${PIPESTATUS[0]}

  # Vitest prints `Tests  N passed (N)` / `Tests  N failed | M passed (T)`
  local line; line=$(grep -E "^[[:space:]]*Tests " "$log" | tail -1)
  local pass fail total
  pass=$(echo "$line" | grep -oE '[0-9]+ passed' | head -1 | awk '{print $1}')
  fail=$(echo "$line" | grep -oE '[0-9]+ failed' | head -1 | awk '{print $1}')
  total=$(echo "$line" | grep -oE '\([0-9]+\)' | tr -d '()')

  if [ $coverage -eq 1 ] && [ -d coverage ]; then
    rm -rf "$RESULTS_DIR/lease-config/coverage"
    cp -R coverage "$RESULTS_DIR/lease-config/coverage"
  fi

  status[lease-config]=$([ $rc -eq 0 ] && echo pass || echo fail)
  summary[lease-config]="${pass:-0} passed, ${fail:-0} failed, ${total:-0} total"
  popd >/dev/null
}

run_suite_docuceo () {
  echo "━━━ docuceo ━━━"
  pushd "$ROOT/docuceo" >/dev/null

  local script="test"
  [ $coverage -eq 1 ] && script="test:coverage"

  local log="$RESULTS_DIR/docuceo/run.log"
  npm run "$script" 2>&1 | tee "$log"
  local rc=${PIPESTATUS[0]}

  local line; line=$(grep -E "^[[:space:]]*Tests " "$log" | tail -1)
  local pass fail total
  pass=$(echo "$line" | grep -oE '[0-9]+ passed' | head -1 | awk '{print $1}')
  fail=$(echo "$line" | grep -oE '[0-9]+ failed' | head -1 | awk '{print $1}')
  total=$(echo "$line" | grep -oE '\([0-9]+\)' | tr -d '()')

  if [ $coverage -eq 1 ] && [ -d coverage ]; then
    rm -rf "$RESULTS_DIR/docuceo/coverage"
    cp -R coverage "$RESULTS_DIR/docuceo/coverage"
  fi

  status[docuceo]=$([ $rc -eq 0 ] && echo pass || echo fail)
  summary[docuceo]="${pass:-0} passed, ${fail:-0} failed, ${total:-0} total"
  popd >/dev/null
}

run_suite_e2e () {
  echo "━━━ e2e ━━━"
  pushd "$ROOT/e2e" >/dev/null

  local log="$RESULTS_DIR/e2e/run.log"
  npm run test:local 2>&1 | tee "$log"
  local rc=${PIPESTATUS[0]}

  # Playwright reporter line: "N passed (Xs)" or "N failed N passed"
  local line; line=$(grep -E "(passed|failed) \(" "$log" | tail -1)
  local pass fail
  pass=$(echo "$line" | grep -oE '[0-9]+ passed' | head -1 | awk '{print $1}')
  fail=$(echo "$line" | grep -oE '[0-9]+ failed' | head -1 | awk '{print $1}')

  if [ -d playwright-report ]; then
    rm -rf "$RESULTS_DIR/e2e/playwright-report"
    cp -R playwright-report "$RESULTS_DIR/e2e/playwright-report"
  fi

  status[e2e]=$([ $rc -eq 0 ] && echo pass || echo fail)
  summary[e2e]="${pass:-0} passed, ${fail:-0} failed"
  popd >/dev/null
}

# ── Run requested suites ─────────────────────────────────────────────────────

[ $run_api -eq 1 ] && run_suite_api
[ $run_lease_config -eq 1 ] && run_suite_lease_config
[ $run_docuceo -eq 1 ] && run_suite_docuceo
[ $run_e2e -eq 1 ] && run_suite_e2e

# ── Render dashboard ─────────────────────────────────────────────────────────

# Pass summary data to the renderer as a JSON blob via stdin
{
  echo '{'
  echo '  "generatedAt": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'",'
  echo '  "coverage": '"$coverage"','
  echo '  "suites": {'
  first=1
  for suite in api lease-config docuceo e2e; do
    [ -z "${status[$suite]+x}" ] && continue
    if [ $first -eq 0 ]; then echo ','; fi
    first=0
    echo '    "'"$suite"'": {'
    echo '      "status": "'"${status[$suite]}"'",'
    echo '      "summary": "'"${summary[$suite]}"'"'
    echo -n '    }'
  done
  echo
  echo '  }'
  echo '}'
} > "$RESULTS_DIR/last-run.json"

node "$SCRIPT_DIR/lib/render-dashboard.mjs" "$RESULTS_DIR/last-run.json" "$DASHBOARD"

echo
echo "━━━ summary ━━━"
overall_rc=0
for suite in api lease-config docuceo e2e; do
  if [ -n "${status[$suite]+x}" ]; then
    icon=$([ "${status[$suite]}" = "pass" ] && echo "✔" || echo "✖")
    printf "  %s %-13s %s\n" "$icon" "$suite" "${summary[$suite]}"
    [ "${status[$suite]}" = "fail" ] && overall_rc=1
  fi
done
echo
echo "Dashboard: $DASHBOARD"

if [ $open_report -eq 1 ]; then
  case "$(uname -s)" in
    Darwin) open "$DASHBOARD" ;;
    Linux) xdg-open "$DASHBOARD" 2>/dev/null || true ;;
    *) echo "(open dashboard manually: $DASHBOARD)" ;;
  esac
fi

exit $overall_rc
