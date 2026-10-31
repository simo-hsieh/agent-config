---
name: auto-research
description: Researches open questions that need external evidence from several sources (web, papers, vendor docs) and returns one cited report. Use for comparisons, prior art, best practice, or "how do others do X". Not for how this or another local codebase works (use how) or a single known-location lookup.
---

# Auto Research

Split the request into questions, send each to `researcher` with only its own part, and merge the answers into one cited report. Run independent questions in parallel; when one depends on another, run them in order and pass the first result on. A sub-question about local code goes back to the caller for `how`.

## Modes

- **Quick (default):** one round, a few parallel questions. State the mode in one line.
- **Deep:** several rounds in the background. State it in one line.
- **Longer than an hour:** run under the `long-run` playbook (`~/.agents/skills/long-run/SKILL.md`), where advancing means new evidence.

## Report

Findings with sources (`file:line`, URL with access date), UNVERIFIED marks, and open questions. Send empirical checks (scratch repros, benchmarks, test runs) to `worker` instead of guessing.

## Saving

Save only deep runs or on request: a repo-tied report goes in that repo's docs, any other in `~/notes/research/<YYYY-MM-DD>-<topic>.md`. The header records the date, question, sources, and, when repo-tied, the jj change it was based on. A saved report is dated evidence: live code and newer evidence override it, and a `design.md` that relies on it restates the decision and cites it.
