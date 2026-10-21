#!/usr/bin/env bash
# causal-claim-router: PreToolUse(Bash) hook.
#
# A SKILL.md description is a retrieval hint, not a trigger.
# The deterministic predicate for causal-claim is not a file path, it is a warehouse query
# that groups by a cohort, tier, coverage band, or treatment flag. That shape IS a
# between-group comparison, and the confounds have to be named before it runs.
#
# Emits additionalContext. Never blocks. Fires at most once per session.
#
# Guardrail error: refuses the silent miss. A false fire costs one nudge; a miss ships an
# uncontrolled number to an exec slide. Tuned to over-fire.
set -uo pipefail
PAYLOAD=$(cat)
CMD=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.command // empty' 2>/dev/null)
SID=$(printf '%s' "$PAYLOAD" | jq -r '.session_id // "nosid"' 2>/dev/null)
[ -z "$CMD" ] && exit 0

STATE="${TMPDIR:-/tmp}/claude-skill-router-$SID"
mkdir -p "$STATE" 2>/dev/null
[ -e "$STATE/causal-claim" ] && exit 0

# Predicate part 1: a query against a data store.
QUERY_RE='(psql|athena|awswrangler|start-query-execution|run_sql|bq query|duckdb)'
printf '%s' "$CMD" | grep -qiE "$QUERY_RE" || exit 0

# Predicate part 2: an actual SQL body. Keeps meta-scripts and greps from matching.
printf '%s' "$CMD" | grep -qiE 'select .*from' || exit 0

# Predicate part 3: a between-group shape. Aggregation plus cohort vocabulary.
AGG_RE='(group by|count\(|sum\(|avg\(|median|percentile|ntile|width_bucket)'
COHORT_RE='(adopt|treated|untreated|coverage|cohort|tier|treatment|control|band|pre_|post_|before|after|matched|comp_|_bucket|_group|high|low)'
printf '%s' "$CMD" | grep -qiE "$AGG_RE" || exit 0
printf '%s' "$CMD" | grep -qiE "$COHORT_RE" || exit 0

touch "$STATE/causal-claim"
jq -nc --arg c "This query groups by a cohort, tier, or treatment flag, so the number it returns is a causal claim and not a description. Load the causal-claim skill with Skill(causal-claim) before you interpret the result. Print its pre-registration table FIRST: mechanism, estimand, denominator derived from the mechanism, treatment timing against the outcome window, exposure, selection, instrumentation, composition, instrument parity across arms, declared slice count, and the falsifier. Then climb the design ladder from the top rung rather than reporting the cross-sectional cut as an effect. The three rows that fail most often are denominator, treatment timing, and exposure. This nudge fires once per session." \
  '{hookSpecificOutput:{hookEventName:"PreToolUse", additionalContext:$c}}'
exit 0
