---
name: benchmark-checklist
description: Vets a measured number (a benchmark, speedup, regression, or eval result) before reporting or acting on it. Loaded by path from the feature design step and perf work.
disable-model-invocation: true
---

# Benchmark checklist

## Before running

- Write the claim you expect to ship ("export is 30% faster at p50 on the 60k-row fixture") and the result that would change the decision.
- Read the measurement script: what it times, counts, and ignores.
- Check `uptime` and the core count. If the machine is busy and you can't stop the load, interleave the sides and say so.

## Answer each from a run, not from reading code

1. **Why not double?** Name the limiter (a core, lock, disk, network, or the load generator) from a profile or system counters in an unreported run, mapped to source.
2. **Was it tuned?** Run every side as production runs it: release build, production flags, pools, caches, data. An untuned side means no winner.
3. **Did it break limits?** Check the arithmetic against disk, network, and core capacity. Removing a piece that takes 10% of the run gains at most about 11%.
4. **Did it error?** Count failures and check outputs are correct, not just present.
5. **Does it reproduce?** At least 5 runs per side, alternating A/B. Report median and range; a gap inside the spread is no difference.
6. **Does it matter?** Measure the end-to-end path a user waits on, and give a micro result as a share of it.
7. **Did it happen?** Confirm the work ran inside the timed region: no unawaited promises, unread generators, discarded results, or timeouts.

For an eval result, ask the same of the trials: did every run do the task, does the gap hold across trials and models, does the scenario matter. A quick ballpark the user asked for needs one run plus questions 4 and 7, labeled as one run.

## Report

Lead with faster, slower, no measurable difference, or inconclusive. Give the number with unit, run count, range, and limiter. Inconclusive is required when a side ran untuned, the limiter is unknown, or questions 4 or 7 went unchecked. Keep the runs and evidence with the number.
