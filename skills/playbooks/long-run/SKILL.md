---
name: long-run
description: Playbook for long or unattended work (a migration, a multi-part change, research or optimization over hours) that no narrower playbook fits. Routed from AGENTS.md or forced with /long-run.
disable-model-invocation: true
---

# Playbook: long-run

A unit advances by kind of run: **build**, the done predicate moved closer with checks green; **research**, new evidence appeared (no code changes); **optimize**, the metric moved past noise.

1. **Frame** before the first tool call, then start work in the same turn:
   - done as a falsifiable predicate;
   - scope, quantified (units, rough effort, blockers found while grounding);
   - rigor, higher for one-way doors and wide blast radius;
   - budget (default 6 h) and its cost: which harnesses and models run, and roughly how many delegated runs.
2. **Design the run**: atomic, independently landable units; the riskiest unknown first; the verification harness and a baseline captured before any change (numbers vetted per `~/.agents/skills/benchmark-checklist/SKILL.md`); every step safe to rerun after a crash per `~/.agents/skills/make-operations-idempotent/SKILL.md`.
   - Keep `worklist.md` beside `decisions.tsv` in the run's scratch directory. Record the predicate, budget and elapsed active-run time (excluding stopped time), and each unit's dependencies, done check, and status (`ready`, `blocked`, or `done` with evidence).
   - Block only on an unfinished prerequisite, external access or input you cannot obtain yourself, or a decision or approval AGENTS.md requires. Name the obstacle and what would unblock it; settle reversible technical choices yourself.
   - Before each attempt, record the unit, its baseline evidence, and its task-owned changes. Update the list and time used after each attempt and on every stop. On resume, read both files and inspect live diffs against that baseline before continuing incomplete work. Preserve unrelated edits, recheck evidence and blockers, and continue only within the remaining budget.
3. **Loop**, one unit at a time: hypothesis, smallest change, measure on the real artifact against the baseline, then keep it as its own jj change or revert it fully. A delegated unit gets a judge from the other model family. A worker that games the gate: reset and harden its brief. A wrong gate: fix it in its own change.
4. **Claims** are scoped (component, change, environment, input) and marked STALE when their source changes. Inconclusive is not a pass.
5. **Trail**: append one row per unit to `decisions.tsv` in the run's scratch directory (ts, phase, decision, why, evidence pointer, result); a wrong row gets a superseding row, never an edit.
6. **Stop** when the predicate holds, the budget is spent, two attempted units in a row made no progress, all unfinished units are blocked, or I ask to pause. Skipping blocked work is not an attempt. Never relax the predicate to finish.
7. **On every stop**: start nothing new; wait for or stop this run's commands and delegates before checkpointing. Preserve unrelated work. Safely checkpoint or back out the current unit; mark incomplete work unverified. Update the work list and trail. If unfinished, save a resume note (intent, progress, verified state, next step, key files, scratch path) in `worklist.md` and any task-owned jj change description.

Before starting another unit or stopping, recheck the predicate and refresh blockers. Make units ready when all their blockers clear, and add missing in-scope work needed for the predicate without expanding the goal. If ready work remains and no stop condition holds, continue without waiting for approval, subject to AGENTS.md. Otherwise run step 7 and report the stop reason, predicate state, units kept and reverted, budget used, both file paths, and each unfinished unit with what would unblock it.
