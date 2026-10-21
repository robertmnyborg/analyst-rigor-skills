---
name: causal-claim
description: Pre-register and red-team any comparison between groups before running it. Use when the work compares treatment vs control, adopters vs non-adopters, high vs low coverage, before vs after, or cohort vs cohort; when the question is "does X drive Y" or "does our product produce a measurable outcome difference"; when reporting a ratio, lift, gradient, or dose-response between segments; or when a number is headed for a slide, a customer, or an exec doc. Not for descriptive counts with no comparison.
version: 0.1.0
---

# Causal Claim

A between-group number is a causal claim wearing a table. This skill forces the threats to
validity out **before** the first query, so the objection arrives from you and not from the
person who reads the finding.

Origin: a multi-day outcome investigation ("do customers who use the product get a better
business outcome?"). Several of its course corrections were confounds a pre-registration
would have caught: composition, exposure window, denominator choice, data-source mix, and a
skipped design ladder.

## Fires on

Predicate: `hooks/causal-claim-router.sh` (PreToolUse on Bash), when a SQL query groups by a
cohort, tier, coverage band, or treatment flag. Also invoke by hand on any of the description
triggers. The hook nudges once per session and never blocks.

## Step 1: Print the pre-registration block first

Print this table before you run the first query. Fill every row. Write "unknown" where you
cannot answer, and treat each "unknown" as a caveat you owe the reader.

| Row | What to state |
|---|---|
| Mechanism | The physical story. How does treatment reach outcome, step by step? |
| Estimand | The one number that settles it. |
| Denominator | The unit the mechanism acts on. Derive it from the mechanism, not from convenience. |
| Treatment timing | When did treatment start, per entity? Compare it to the outcome window. |
| Outcome window | The date range. Confirm it is identical for both arms. |
| Exposure | Did both arms have the full window available? Tenure differences go here. |
| Selection | Who gets treated, and what else correlates with getting treated? |
| Instrumentation | Does the treated arm get measured more, or measured differently? |
| Composition | Which mix differences track treatment? Signup cohort, account size, plan, data source, geography. |
| Instrument parity | Both arms must use one measurement source. Name it. |
| Slice count | How many cuts will you try? Declare the number now. |
| Falsifier | The result that kills the claim. Name it before you see the data. |

Three rows fail most often. **Denominator** must match the mechanism: if a checkout change
acts on each checkout attempt, a rate per *visitor* is wrong and a rate per *checkout
session* is right. **Treatment timing** must precede the outcome window: a feature flag read
today, against outcomes accumulated over the prior year, credits an account for months before
it had the feature. **Exposure** must be equal: an arm that signed up six months ago has half
the window instrumented.

## Step 2: Climb the design ladder from the top

Start at rung 1. Drop a rung only when sample runs out. State the sample cost of each rung
before you pick one.

| Rung | Design | What it kills | What it costs |
|---|---|---|---|
| 1 | Within-entity, turn by turn | Every fixed trait of the entity. Separates a real effect from mean reversion by shape | Severe sample loss. Needs repeat spells on both sides |
| 2 | Within-entity, before vs after | Every fixed trait, but reversion still mimics it | Moderate loss. Watch for the Ashenfelter dip |
| 3 | Within-parent, sibling vs sibling | Parent account, region, signup cohort, budget | Needs variation inside the parent |
| 4 | Matched pairs across a boundary | The matched dimensions only | Needs an external comp source, and usually a second instrument |
| 5 | Cross-sectional, unmatched | Nothing | Free. Not evidence |

Rung 5 is the design an analyst dismisses on sight. Report it as a description, never as an
effect.

## Step 3: Report against the falsifier

State the falsifier result first, then the estimate. Report the sample that survived each
filter, as a table, so the reader sees selection happen. Say which rung you reached and why
you stopped there.

## Step 4: Red-team before you deliver

Write the three strongest objections a hostile analyst would raise. Answer or concede each
one inline. Run any objection that would flip the direction of the finding, before you
report the number.

Concede the design when the challenger is right. Hold the mechanism until you have checked
it. A fast full concession skips the check and gets half the concession wrong.

## Hard stops

Do not report a between-group ratio when the denominator is unstated.
Do not measure one arm with a truth source and the other with a proxy.
Do not report the favorable slice out of many without naming the slice count.
Do not call an effect an effect at rung 5.
Do not say data is missing until you have checked the source layer, not the summary layer.
Do not say a join is impossible until you have named the keys tried and the alternatives.
Do not name a same-day event as the cause of a before/after move until the entities it touched
carried at least half of the lost volume. A date match is a suspect, not an effect. Suppose a
same-day change touched entities that carried 4% of the drop: the change is a coincidence, and
the other 96% still needs a cause.
Do not use a series as an outcome until you have sampled its rows (top paths, event types, and
user agents). A count that includes your own internal API calls or health checks can pose as
customer activity and reverse a verdict.

## Domain confounds: seed your own

Keep a table of the confounds that bite in your domain and check each against the analysis at
hand. The example below is for a SaaS product and an online store. Replace it with yours.

| Confound | Why it bites |
|---|---|
| Early adopters | Accounts that turn on a new feature first are already your most engaged accounts. They land in the treated arm and would have retained better anyway |
| New accounts | New signups behave differently in their first months (setup activity, trial usage). If new accounts adopt the feature by default, the treated arm is younger |
| Treatment timing | A feature gets turned on when an account hits a need, so treatment sits inside an activity spike |
| Addressable step | A checkout change touches the payment step only. Steps before and after are outside. State the step |
| Parent account | Accounts under one parent share budget, admins, and habits. Hold the parent constant where the data allows |
| Proxy vs outcome | The change influences the order. Delivery, returns, and refunds depend on things it does not touch |
| Data presence | A populated field can track which integration the account uses, not data quality |
| Bot and internal traffic | Crawlers, monitors, and your own API calls inflate counts. Filter them before you compare arms |
| Seasonality | Retail demand peaks in Q4. Raw March vs November is a season effect. Use share of total, YoY, or a demand control |
| Source mix | Traffic comes from several outside sources (search, ads, marketplaces, referrals) with independent changes. Split every before/after by source |
| Outcome grain | Pick the event the customer values (an order completed), not the nearest loggable event (a button click) |
| Capture vs generate | More orders through a new flow may be the same orders rerouted from the old flow. The total across both flows settles it |

## Component record

Guardrail error: this routes, and it refuses the silent miss. A false fire costs one nudge
per session. A miss ships an uncontrolled number to an exec slide. Tune toward over-firing.
Deletion test: without it, group comparisons ship with confounds unstated.
Kill condition: cut it when a session review shows the block printed and then ignored, or
when a 90-day audit shows zero invocations.
