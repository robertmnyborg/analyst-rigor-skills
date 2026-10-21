# analyst-rigor-skills

Four Claude Code skills that stop an agent from fabricating analytical conclusions: a confounded group comparison reported as an effect, a same-day coincidence named as root cause, an invented customer quote, a persona with no buyer behind it.

Each rule exists because an agent shipped the wrong answer without it.

## Install

```bash
git clone <this repo> analyst-rigor-skills
cp -R analyst-rigor-skills/skills/* ~/.claude/skills/
cp analyst-rigor-skills/bin/job-card-gate ~/.local/bin/        # any directory on your PATH
cp analyst-rigor-skills/hooks/causal-claim-router.sh ~/.claude/hooks/
```

Register the hook in `~/.claude/settings.json` (optional, needs `jq`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/causal-claim-router.sh" }]
      }
    ]
  }
}
```

Requirements: Claude Code, Python 3 (gate), bash and `jq` (hook). Run `bash tests/run.sh` to check the gate and the hook.

## causal-claim

**Failure it prevents:** a between-group number (adopters vs non-adopters, before vs after, high vs low tier) reported as an effect while the confounds stay unstated.

**Why:** in a multi-day outcome investigation, several course corrections were confounds a pre-registration would have caught: composition, exposure window, denominator, data-source mix, and a skipped design ladder.

**How:** print a 12-row pre-registration table (mechanism, denominator, treatment timing, exposure, falsifier, declared slice count) before the first query, climb a five-rung design ladder from within-entity down to cross-sectional, report against the falsifier, then red-team three objections. Hard stops forbid rung-5 "effects", unstated denominators, and same-day suspects that carried under half the lost volume.

**Trigger:** `hooks/causal-claim-router.sh` fires once per session when a Bash command runs SQL that aggregates by a cohort, tier, or treatment column. It adds context and never blocks. It over-fires by design: a false fire costs one nudge, a miss ships an uncontrolled number to an exec slide.

## metric-diagnosis

**Failure it prevents:** "the metric dropped because of X" where X happened on the same day and nothing else connects them.

**Why:** in one metric-drop investigation, a draft blamed a change made the same day that touched only a small share of the lost volume, and a later draft rested on a "clicks" series that mostly counted an internal API call. The skill had already fired; both wrong answers shipped anyway, so the gates below are the fix.

**How:** clarify and row-sample every series, size the move against noise and YoY, decompose with a metric tree, segment (TROPICS, provider first), rank hypotheses, then pass three gates before writing "root cause": delta attribution (the suspect carried at least half the lost volume), observed mechanism, and run the confirming query yourself. Works in live-data mode and in PM/DS interview mode.

**Sources:** TROPICS segmentation checklist (PM interview prep), metric/driver trees (Amplitude North Star; Abhi Sivasailam), hypothesis-driven issue trees (McKinsey). The incident gates are original.

## trustworthy-insights

**Failure it prevents:** themes and quotes from customer interviews or surveys that read well and do not exist in the source: invented or stitched quotes, generic themes, everything presented at equal confidence.

**How:** name the decision first, extract only single-source verbatim quotes with citations, search the source for every quote before reporting, count people rather than mentions, and open with one line stating the sample.

**Credit:** inspired by Caitlin Sullivan, ["How to do AI analysis you can actually trust"](https://www.lennysnewsletter.com/p/how-to-do-ai-analysis-you-can-actually), Lenny's Newsletter. Read the original for her method; the checks here are my own.

## job-card

**Failure it prevents:** PRDs, specs, positioning, and outreach that name a persona from memory, with no buyer quote behind it. Model-simulated interviews count as evidence level 0.

**How:** one card per job, every entry a verbatim quote with `[source, level]` on a 0 to 5 evidence scale defined in the skill. A job exists at 3+ quotes of level 3+ from 2+ sources; demand exists at 1+ commitment signal of level 4+. Modes: `extract` (from transcripts, via `trustworthy-insights`), `translate` (headlines only from buyer words), `model` (growth-model drivers), `simulate` (question planning only, never evidence).

**Gate:** `job-card-gate <prd.md>` reads the doc's `Job card:` and `Driver:` lines, counts evidence rows on the card, and checks the driver exists in `growth-model.md`. Exit 0 = pass. A `Job card waiver:` line records a human decision to skip.

```
$ job-card-gate skills/job-card/examples/tidyroster/prd-shift-swap.md
  job exists:    PASS  12 quotes at level 3+ from 5 source(s); need 3+ from 2+
  demand exists: PASS  2 commitment signal(s) at level 4+ in section H; need 1+
  driver:        PASS  "Shifts filled without a manager call" is in .../growth-model.md
GATE: PASS
```

`examples/tidyroster/` is a fully synthetic card for a fictional scheduling product. Every quote in it is invented.

**Credit:** inspired by Matt Lerner's SYSTM course; see https://www.systm.co.

## License

MIT. See `LICENSE`.
