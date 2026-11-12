---
name: long-run
description: Playbook for long or unattended work (a migration, a multi-part change, research or optimization over hours) that no narrower playbook fits. Routed from AGENTS.md or forced with /long-run.
disable-model-invocation: true
---

# Playbook: long-run

A unit advances by kind of run: **build**, the done predicate moved closer with checks green; **research**, new evidence appeared (no code changes); **optimize**, the metric moved past noise.

1. **Frame**, in one message, then continue:
   - done as a falsifiable predicate;
   - scope, quantified (units, rough effort, blockers found while grounding);
   - rigor, higher for one-way doors and wide blast radius;
   - budget (default 6 h) and its cost: which harnesses and models run, and roughly how many delegated runs.
2. **Design the run**: atomic, independently landable units; the riskiest unknown first; the verification harness and a baseline captured before any change (numbers vetted per `~/.agents/skills/benchmark-checklist/SKILL.md`); every step safe to rerun after a crash per `~/.agents/skills/make-operations-idempotent/SKILL.md`. Write the phase list down.
3. **Loop**, one unit at a time: hypothesis, smallest change, measure on the real artifact against the baseline, then keep it as its own jj change or revert it fully. A delegated unit gets a judge from the other model family. A worker that games the gate: reset and harden its brief. A wrong gate: fix it in its own change.
4. **Claims** are scoped (component, change, environment, input) and marked STALE when their source changes. Inconclusive is not a pass.
5. **Trail**: append one row per unit to `decisions.tsv` in the run's scratch directory (ts, phase, decision, why, evidence pointer, result); a wrong row gets a superseding row, never an edit.
6. **Stop** when the predicate holds, the budget is spent, or two units in a row made no progress. Never relax the predicate to finish.
7. **Pause** only when I ask: finish or back out of the current unit, describe the current jj change with a resume note (intent, progress, verified state, next step, key files), and start nothing new.

Report the predicate state, units kept and reverted, budget used, the trail path, and what is open.
