---
name: job-card
description: Build and use a quote-backed Jobs-to-be-Done card per product, so PRDs, specs, positioning, and outreach point at a real buyer and a real job. Use when the user says "job card", "jobs to be done", "who is this for", "what job does this serve", "extract the job from this call", "translate this into messaging", "headline test", or starts a PRD, spec, or outreach sequence for a product that has no card under its project `jobs/` folder.
---

# job-card

A job card is one file per job: `<project>/jobs/<job-name>.md`. Every entry on the card is a customer's words with a source and an evidence level. Product work cites the card. Marketing work is generated from the card.

Inspired by Matt Lerner's SYSTM course; see https://www.systm.co. The push, pull, anxiety, and inertia fields follow the standard JTBD switch-interview model. The rules, levels, and gate below are my own.

## Evidence levels

The gate counts these levels. Score the source, not how convincing the quote sounds.

| Level | What produced the quote | Counts toward |
|---|---|---|
| 0 | A model, a guess, or a colleague's opinion about customers (including sales and executives) | Nothing. Use it to plan questions |
| 1-2 | Something a buyer said in passing, with no recording or no context | Context only |
| 3 | Public buyer words you did not prompt: reviews, forum threads, support tickets, community posts | Job exists |
| 4 | A recorded interview about what the buyer already did, or a commitment already made (paid pilot, signed trial, intro to the budget holder) | Job exists; demand when it is a commitment |
| 5 | Money changed hands for this job: a closed deal with a recorded reason, a paid order through a test page | Demand exists |

## Rules that do not bend

- **A card entry is a quote, never a summary.** Paraphrase destroys the verbs that `translate` needs.
- **Every entry carries `[source, level]`.** An entry without a source is level 0.
- **Model output is level 0.** A simulated interview, a guess, and an internal opinion about customers are all level 0.
- **The card records absence.** If no quote exists for a field, write `NONE FOUND` and the sources searched. Do not fill the field.
- **A job exists at 3+ quotes of level 3+ from 2+ sources. Demand exists at 1+ commitment signal of level 4+ in section H.**

## Mode: extract

Input is a transcript, a review set, a forum thread, or a CRM note export.

1. Invoke `Skill(trustworthy-insights)` and apply its checks.
2. Copy `references/card-template.md` to `<project>/jobs/<job-name>.md` if the card does not exist.
3. Read the source for each card field in this order: struggle, alternatives, trigger, where the buyer looked, desired outcomes, anxieties, inertia, other stakeholders, commitment signals.
4. Add each quote to the card with the source ID, the timestamp, and the evidence level.
5. If the speaker works for the seller, do not add the quote. Sellers are not buyers.
6. If a buyer uses a vague word ("better", "easier", "visibility"), add the word to the `Probe next call` list.
7. For each empty field, add a question about past behavior to the `Probe next call` list ("Talk me through the last time that happened").
8. Search the source for every quote on the card. Remove each quote that is not found verbatim.
9. Write the job statement (`When I / I want to / So that I can`) only from verbs that appear in the quotes.
10. Run `job-card-gate --card <card>` and copy the counts into the `Gate status` block.

## Mode: translate

Input is a card. Output goes to `<project>/jobs/<job-name>.messaging.md`.

1. If the card fails the job line of the gate, stop. Report the missing evidence.
2. List the words buyers used for the struggle and the outcome, with the number of sources for each word.
3. Write 2 or 3 headlines each for the struggle and the outcome. Use only the words from step 2.
4. Remove every headline that contains "all in one", "faster", "better", "easy", "smart", "seamless", "platform", or "AI-powered". If the card gives a number for the vague word ("an afternoon every week"), use the number.
5. Write the positioning line against the alternative that the most sources named.
6. For each anxiety on the card, write one answer that cites a fact.
7. Write the channel list from the `Where the buyer looked` field.
8. Test the top headline for comprehension before any paid test: show it to 5 people for 5 seconds, then ask what it said and what it means. Pass at 4 of 5 explaining it in their own words.
9. Do not copy a reworded or approved testimonial onto a card. The card holds only the words the buyer said first.

## Mode: model

Output is `<project>/growth-model.md`, next to the `jobs/` folder. The gate reads it to check the `Driver:` line in a PRD.

1. Name the North Star: a count of times customers get the job on the card done, per week or month. Not revenue, not a ratio.
2. List the customer behaviors that move the North Star, as a table with one driver per row.
3. Give each driver a baseline and the query that produces it. If no query exists, write `Unverified`.
4. Mark 1 to 3 drivers as key, and name the one that limits the rest, with one sentence of reasoning.
5. Give each key driver an owner and a target. If the user has not named an owner, write `OPEN`.

## Mode: simulate

A simulated interview is practice and question planning. It never produces card evidence, because a model playing the customer returns the answer the team already assumes.

1. Ask a model to play a recent buyer and answer questions about the trigger, the alternatives, the anxieties, and what made switching hard.
2. Write the output to `<project>/jobs/<job-name>.simulated.md`. Put `LEVEL 0: SIMULATED, NOT EVIDENCE` on the first line.
3. Do not copy any simulated line onto a card.
4. Turn each simulated answer into an interview question. Add the questions to the `Probe next call` list.

## Gate

The gate is a script: `job-card-gate <prd-or-spec.md>` (from `bin/` in this repo, on your PATH). The script reads two header lines from the document, `Job card: <path>` and `Driver: <name>`. The script counts evidence rows on the card and looks for the driver in `growth-model.md` beside the `jobs/` folder. Exit code 0 means pass.

Optional trigger: a PreToolUse hook on Write that matches a `.md` filename containing `prd`, `spec`, `requirements`, `brief`, `one-pager`, or `pitch` and adds a one-line nudge to run the gate. The nudge does not block.

A document with no buyer evidence yet (a spike, an internal tool) carries `Job card waiver: <reason, who, date>` in place of the two lines. The script reports `WAIVED`. A waiver is a human decision. Do not write a waiver without the user's instruction.

The card parser reads table rows. An evidence row ends with the source cell and then an integer level cell. Keep that column order.

## Component record

1. Guarantee or estimate: the card content is an estimate, read by a human. The gate counts are a guarantee, so a script computes them.
2. Reversible: yes. Files only.
3. Frozen eval set for the gate: `fixtures/demo/` (pass, no card, bad driver, waiver). Worked example: `examples/tidyroster/`.
4. Deletion test: without it, PRDs and outreach name a persona from memory with no quote behind it.
5. Guardrail error: the gate refuses false passes (a PRD built on invented demand costs weeks). A false block costs one interview or a written waiver line.
