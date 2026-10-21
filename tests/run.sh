#!/usr/bin/env bash
# Runs job-card-gate against the frozen fixtures and the worked example; checks exit codes.
# Also feeds the causal-claim hook one matching and one non-matching payload.
set -u
cd "$(dirname "$0")/.."
GATE=bin/job-card-gate; FX=skills/job-card/fixtures/demo; fail=0
expect() { # expected_exit file
  "$GATE" "$2" >/dev/null; got=$?
  if [ "$got" = "$1" ]; then echo "ok   $2 (exit $got)"; else echo "FAIL $2 expected $1 got $got"; fail=1; fi
}
expect 0 "$FX/prd-pass.md"
expect 0 "$FX/prd-waiver.md"
expect 1 "$FX/prd-nocard.md"
expect 1 "$FX/prd-baddriver.md"
expect 0 skills/job-card/examples/tidyroster/prd-shift-swap.md

export TMPDIR="$(mktemp -d)"
hit=$(printf '%s' '{"session_id":"t1","tool_input":{"command":"psql -c \"select cohort, count(*) from orders group by cohort\""}}' | bash hooks/causal-claim-router.sh)
miss=$(printf '%s' '{"session_id":"t2","tool_input":{"command":"ls -la"}}' | bash hooks/causal-claim-router.sh)
again=$(printf '%s' '{"session_id":"t1","tool_input":{"command":"psql -c \"select cohort, count(*) from orders group by cohort\""}}' | bash hooks/causal-claim-router.sh)
case "$hit" in *causal-claim*) echo "ok   hook fires on cohort query";; *) echo "FAIL hook did not fire"; fail=1;; esac
[ -z "$miss" ] && echo "ok   hook silent on ls" || { echo "FAIL hook fired on ls"; fail=1; }
[ -z "$again" ] && echo "ok   hook fires once per session" || { echo "FAIL hook fired twice"; fail=1; }
rm -rf "$TMPDIR"
exit $fail
