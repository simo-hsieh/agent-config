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

`intent.md` and `design.md` live in the target project (for example `docs/<topic>/`) as committed records for future change, kept true to the shipped code. Write only the docs that reduce risk: a small, local, reversible change goes straight from the stated goal to code and tests. Stop for my approval only at a stage I name ("let's discuss the intent").

1. **Intent** (`intent.md`): problem, desired outcome, affected users and systems, constraints, success criteria, open questions, in the requester's words.
2. **Design** (`design.md`), for engineers who know the system; skip trivial background:
   - numbered requirements (R1, R2, ...) that satisfy the intent;
   - the approach, system diagram, and key components, as Mermaid;
   - detailed design: write 2–3 caller call sites first and derive the API or proto from them; screen it for two ways to do one task, importable internals, hand-synced lists, and split ownership; choose the data structure per `~/.agents/skills/model-the-domain/SKILL.md`;
   - for a stateful design, the states, the events including failures (crash, timeout, retry, a concurrent actor), and the rules as "never X";
   - alternatives: when they differ on something measurable, build each as a throwaway prototype in scratch and benchmark it per `~/.agents/skills/benchmark-checklist/SKILL.md`, and record each one's numbers and verdict;
   - how each intent constraint is met, open questions, and flagged concerns (security, compatibility, migration) with an owner each.
3. **Plan** inline: files affected, ordered steps, risks, and the test that proves each R#.
4. **Code and tests:** first a scaffold change with the detailed design's types and signatures and `not implemented` bodies; then one unit at a time, red-green per `~/.agents/skills/tdd/SKILL.md`, each unit green before the next, citing R# in test names or change descriptions.
5. **Feedback:** the design is wrong when friction repeats: the same workaround in unrelated places, type escape hatches, an unplanned lock, or two deviations of the same shape. Then redesign as if the requirement had been there from the start, propagate it to every reference (types, docs, examples), and update `design.md` or `intent.md` in the same change.
6. **Interrogate:** when the change is ready, run `~/.agents/skills/interrogate/SKILL.md` in the background and keep going.
7. **Report:** what changed, how it was checked, how the diff maps to R#, which doc sections changed during the build, interrogate findings (or "not interrogated"), and open risks.
