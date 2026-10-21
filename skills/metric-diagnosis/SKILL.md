---
name: metric-diagnosis
description: Diagnose why a metric moved (dropped, spiked, flatlined, diverged from forecast) with a sized, tree-decomposed, hypothesis-ranked investigation. Use when the user asks "this metric dropped, why", "why did X go up/down", "investigate this change in DAU/conversion/revenue/CTR", "is this dip real", practices a PM or DS metric-investigation interview question, or asks how to define, decompose, or sanity-check a metric. Hands off to causal-claim when the question becomes "did X cause Y" between groups.
version: 0.2.0
---

# Metric Diagnosis

A metric move is a symptom. A checklist of places to look is not a diagnosis. The method must
size the move, localize it, rank hypotheses, and confirm one before proposing a fix.

Sources: TROPICS segmentation checklist (PM interview prep), metric/driver trees (Amplitude
North Star, Abhi Sivasailam), hypothesis-driven MECE issue trees (McKinsey), and the data-first
habit of big-tech analytics interviews. "CIEF" has no traceable source. Do not cite it.

## Modes

- **Live data**: the metric exists in a reachable system (warehouse, event store, product
  analytics, billing). Run every step as queries. Name the table and filter for each claim.
- **Interview / hypothetical**: no data. Say each step aloud, state what you would query, and
  commit to a most-likely hypothesis with its reasoning. Silence on ranking fails the answer.

## Procedure

1. **Clarify the metric.** State the exact formula, the grain, and the time window. Ask whether the
   definition, the logging, or the pipeline changed near the move. Check data validity first. A broken
   pipeline is the most common real cause.
   - **Sample the rows of every series before it becomes evidence.** This applies to the metric
     itself and to every supporting series you derive. Print the top 10 paths, event types, and
     user agents that make up the count. Then put the count next to one independent number from
     the same funnel and explain the ratio in one clause. If you can't explain it, the series is
     suspect. For example, a "clicks" series ten times larger than the conversions it feeds needs
     an explanation before anyone trusts it. Common culprits: your own API calls logged as
     clicks, and static assets (scripts, images) counted as page views.
2. **Size the move.** Compare the move to normal week-over-week variance and to the same period
   last year. Classify the shape: a cliff (release, outage, logging) or a slope (behavior,
   market, seasonality). Stop if the move sits inside normal noise.
   - **Never compare raw volume across seasons.** Most demand is seasonal. Use a share of the
     total (for example, channel conversions ÷ all conversions), YoY, or a demand control such
     as a comparable channel in the same region and week.
3. **Decompose with a metric tree.** Write the metric as a formula of drivers (for example,
   users × sessions per user × conversion). For a ratio, split the numerator and the denominator.
   Identify the branch that moved. Check related metrics upstream and downstream.
4. **Segment the moving branch (TROPICS).** Cut by Time, Region, Other internal changes,
   Platform, Industry/competitors, Cannibalization, and Segment (new vs returning, plan, channel).
   Check for mix shift. Flat segments with a falling total mean the population mix moved.
   - **Cut by source or provider first** when outside platforms feed the metric (AI assistants,
     search engines, marketplaces, ad networks). Put every provider in the same table or chart.
     A cliff in one provider points outward. A cliff in every provider at once points to
     your side.
   - **Scope the definition to the whole population, even when one provider dominates.** Metric
     definitions, charts, and scorecards cover all providers. Only the narrative may center the
     dominant driver. A funnel built from one vendor because the question named that vendor
     hides whether the move is local or channel-wide.
5. **Rank hypotheses.** List internal causes (releases, experiments, bugs, pricing,
   cannibalization) and external causes (seasonality, competitors, platform policy, outages,
   macro). Rank each one by fit to the timing, the shape, and the segment. Lead with the top
   hypothesis and one sentence of reasoning.
6. **Confirm the cause.** Test the top hypothesis with the cheapest decisive evidence: an
   experiment holdout, a rollback, or the same move in a matched segment. If the claim compares
   groups, invoke `causal-claim` before running the query. A date that lines up is a suspect,
   not a confirmation. Pass all three gates below before you write "root cause":
   - **Delta attribution.** Measure the metric's volume in the entities the suspect touched,
     before the move. If they carried less than half of the lost volume, the suspect is a
     coincidence. Suppose pages removed on the day of a drop had carried 4% of the lost
     traffic: the removal explains 4%, and the other 96% still needs a cause.
   - **Observed mechanism.** A claim about how an outside system changed needs direct evidence:
     every agent from that vendor shifting in your logs the same week, or a dated external
     source. The outcome series behind it must also pass the row-sample check in step 1.
   - **Run the check yourself.** Do not write "only X can confirm" or "ask the data team" when
     you can query the data. A lookup you can run yourself is cheaper than a handoff and often
     overturns the draft.
7. **Decide the action.** Classify the move as a bug, a real regression, or a healthy drop
   (bot or fraud cleanup, a deliberate change, a definition change). Propose a fix, a rollback,
   or an experiment. State the trade-off against the metrics the change improved.

## Output shape

- Line 1: the verdict or the top hypothesis, with its confidence.
- Table: step | finding | proof | evidence link | Verified / Unverified. **Proof** is the observation
  that makes the claim true, not a restatement of the claim. **Evidence link** points to a
  committed query or notebook that reproduces the number. A query run only inside the session is
  Unverified. Before the first query, create an evidence store: a repo with `queries/`,
  `results/`, and `scripts/charts.py`.
- A series over time (6+ periods) ships as a chart, never a table. Use small multiples by
  segment or by provider. The table goes in the evidence store.
- One question per document. A metric-drop diagnosis and a proposal (attribution, experiment,
  roadmap) are separate pages, linked to each other. When a follow-up changes the question,
  start a new page. Never retitle the old one.
- Close with one next action: the single query or check that confirms or kills the top hypothesis.

## Failure modes this skill prevents

| Failure | Guard |
|---|---|
| Investigating noise | Step 2 sizes the move against variance before any cut |
| Blaming users when the denominator grew | Step 3 splits numerator and denominator |
| Missing Simpson's paradox | Step 4 mix-shift check |
| A list of possible causes with no answer | Step 5 forces a ranked lead hypothesis |
| Fixing an unconfirmed cause | Step 6 confirmation gate |
| "Fixing" a healthy drop | Step 7 healthy-drop classification |
| A series counts the wrong events (API calls, static assets) | Step 1 row sample + downstream reconcile |
| Seasonal volume read as a trend | Step 2 share-of-total or YoY |
| Same-day coincidence named as root cause | Step 6 delta attribution |
| External mechanism inferred from your own metric | Step 6 observed mechanism |
| Confirmation handed to a person while the data sits in reach | Step 6 run it yourself |
| One provider's funnel presented as the metric | Step 4 all-provider scope |
| "Verified" with nothing to re-run | Output: evidence link |
| Weekly tables, two topics in one page | Output shape |

Origin of the last eight rows: one metric-drop investigation where the skill fired at the
start and later drafts still shipped wrong root causes. Each row maps to a correction.
