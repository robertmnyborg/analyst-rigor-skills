---
name: trustworthy-insights
description: Use when analyzing interviews, survey responses, support tickets, reviews, churn notes, or any other qualitative customer data, and when someone asks to "find themes", "code responses", "summarize customer research", or pull quotes. Stops invented quotes, stitched quotes, generic themes, and findings stated with more confidence than the sample supports.
version: 0.2.0
---

# Trustworthy Insights

A theme is cheap to write and hard to check. These checks make every finding traceable to
words a customer said.

Credit: inspired by Caitlin Sullivan, ["How to do AI analysis you can actually trust"](https://www.lennysnewsletter.com/p/how-to-do-ai-analysis-you-can-actually),
Lenny's Newsletter. Read the original for her method. The checks below are my own.

## Before you read the data

- Write down the decision the analysis feeds, in one sentence. If nobody can name the
  decision, ask for it. Themes with no decision behind them come out generic.
- Write down who the participants are and how they were picked. A churned-customer set and an
  active-customer set answer different questions.

## While you extract

- A quote is one continuous stretch of one person's words. Never join two places in a
  transcript into one quote, and never join two people.
- Keep the hedges ("I think", "maybe", "sort of"). They tell the reader how sure the speaker was.
- Cite every quote with a participant ID and a location: `[P04 ~12:30]` or `[row 118]`.
- If you score or bucket responses, write the definition of each bucket before you start, and
  anchor each bucket with one real response from this dataset.

## Before you report

1. Search the source for every quote you plan to use. Mark each one FOUND, PARAPHRASE, or
   MISSING. Delete MISSING quotes. Replace PARAPHRASE quotes with the exact words.
2. Check each participant against themselves. A stated preference that conflicts with a
   described behavior is a finding, not noise. Report the conflict.
3. Count people, not mentions. Ten mentions from one person are one data point.
4. Mark a finding LOW confidence when fewer than 3 people support it or the support comes from
   one account.

## Output

The first line states the sample: how many people, how many distinct accounts, and what is
still missing. A reader who stops there must know what the sample can support.

```
Sample: N people across M accounts. <Missing segments, or "complete".>

Finding: <specific claim, not "users value reliability">
Confidence: HIGH / MEDIUM / LOW, because <count and spread>
Decision impact: <what this changes about the decision>
Evidence:
- "<exact quote>" [P## ~mm:ss]
Conflicts: <contradicting quotes, or none>
```
