---
name: evidence-learning-loop
description: Track material claims and reusable lessons across research, design, implementation, and review. Use for non-trivial work with unfamiliar or evolving systems, experiments, conflicting evidence, or an explicit learning goal; skip mechanical changes.
---

# Evidence learning loop

Treat explanations as scoped claims that later evidence can support, narrow, or overturn.

## Classify before verifying

- **Requirement or preference:** the owner decides; nothing to verify.
- **Source claim:** code, docs, or a person says so.
- **Observation:** an execution or measurement under stated conditions.
- **Inference:** a plausible explanation not yet demonstrated.

Do not treat intended design as proof of current behavior, or a hypothesis as a decision. When design and implementation conflict, report both.

## Loop

1. State the material claims and what would change the plan if they were false.
2. Match evidence to the question: reproduce or test for current behavior, canonical docs and approved decisions for intent, authoritative sources for external facts. Treat search snippets as leads; open the source.
3. Test the riskiest claim first, with the cheapest experiment that could falsify it.
4. Record each claim's status with scope: component, revision, environment, input. Never write an unscoped "verified".
5. Mark claims `STALE` when their source or environment changed.

## Keep what is reusable

Persist a lesson only when it is likely to be reused: save it to memory (in Pi, list it in the report) with its scope, revision, and last-checked date; `reflect` promotes it into `~/code/_agent` or the project's docs with my approval. Keep raw transcripts, credentials, and customer data out. When the same mistake repeats, enforce it at the highest level that works: architecture or types, then a check or lint whose error names the fix, then a test, then rule or skill text.
