---
name: feature
description: Playbook for new behavior, a new interface, a cross-module change, or a design doc. Routed from AGENTS.md or forced with /feature.
disable-model-invocation: true
---

# Playbook: feature

For new behavior, a new interface, a cross-module change, or when a design doc is the deliverable. The loop:

```text
intent.md <-> design.md <-> code + tests
   ^                           |
   +------ observed feedback --+
```

Each artifact lives in the target project (for example `docs/<topic>/`), is committed, and is approved by a human before the next step. Write only the artifacts that reduce risk: a small, local, reversible change goes straight from a stated intent to code and tests.

1. **Intent** (`intent.md`): problem, desired outcome, affected users and systems, constraints, open questions, in the requester's words. Ask probing questions about scope and success criteria, then wait for acceptance.
2. **Design** (`design.md`), written for engineers who know the system; skip trivial background:
   - numbered requirements (R1, R2, ...) that satisfy the intent;
   - the approach and key decisions, with alternatives and why they were rejected when a real trade-off exists;
   - how each intent constraint is satisfied, open questions, and flagged concerns (security, compatibility, migration) with an owner each;
   - diagrams as Mermaid in the markdown.

   Resolve flagged concerns, then wait for acceptance. Raise the reviewer bar for risky or hard-to-reverse designs.
3. **Plan** (inline, or `plan.md` for larger work), in read-only mode before any edit: files affected, ordered steps, risks, and the test that proves each R#. The engineer corrects it before code is written.
4. **Code and tests:** one plan step at a time, citing R# in test names or commit messages.
5. **Feedback:** when code reveals that the design or intent is wrong, stop, update `design.md` (or `intent.md`) in the same change, and return it for approval rather than silently diverging.
6. **Report:** what changed, how it was checked, how the diff maps to R#, open risks.

Use `researcher` for external evidence only. Bugfixes and investigations skip this flow.
