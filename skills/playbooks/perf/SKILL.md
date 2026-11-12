---
name: perf
description: Playbook for a measured slowness or resource problem to trace and improve against a baseline. Routed from AGENTS.md or forced with /perf.
disable-model-invocation: true
---

# Playbook: perf

Tie every change to a measurement; never claim a speedup from reading code.

1. **Baseline.** Write the result that would change a decision, then measure on the surface where the slowness shows. Vet the baseline and every later number per `~/.agents/skills/benchmark-checklist/SKILL.md`.
2. **Ground** hypotheses with `how` and a profile, and name the limiter. Try fixes in this order, stopping when one meets the target: don't do the work; don't do it again; do less; do it later; do it when the user isn't waiting; do it concurrently; do it cheaper.
3. **One change per attempt**: measure before and after with the same harness, keep it only when the number moves past noise and the tests stay green, otherwise revert it fully. Each attempt ends green before the next starts.
4. **Sustained improvement** of one metric against a target runs as `long-run`, where a unit advances when the metric moves past noise.
5. **Report**: baseline and after, the delta with unit, run count, range, limiter, and the artifact path.
