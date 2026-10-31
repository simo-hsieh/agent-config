---
name: auto-research
description: Researches open questions that need evidence from several sources (local code, internal docs, external web and papers) and returns one cited report. Use for comparisons, prior art, best practice, or "why/how do others do X". Not for a single known-location lookup, a bug fix, or a question one file answers.
---

# Auto Research

Split the request into questions, route each by type, and merge the answers into one cited report.

## Routing

| Question type | Handled by |
|---|---|
| Where/how in this codebase | `scout` or direct search |
| External web, papers, vendor docs | `researcher` |

Send each leaf only its own part of the question. When one answer depends on another, run them in order and pass the first result on. Run independent questions in parallel.

## Modes

- **Quick (default):** one round, at most a few parallel leaves. Run it and state the mode in one line.
- **Deep:** several rounds of leaves, run in the background. Say so in one line.
- **Overnight / over an hour:** ask the user first in one line (cost, question, done-when), then end the turn.

## Overnight loop

1. Write `intent.md` with the question, done-when condition, and budget (default 6 h) in a scratch directory outside the repo.
2. Each round: pick open questions, fan out to leaves, merge, then decide whether new evidence appeared and whether sources contradict.
3. Stop when done-when is met, after two rounds with no new evidence, or when the budget is spent.
4. Make no code commits; the user decides next steps.

## Report

List findings with sources (`file:line`, URL with access date), mark what is UNVERIFIED, and list open questions. Send empirical checks (scratch repros, benchmarks, test runs) to `worker` instead of guessing.
