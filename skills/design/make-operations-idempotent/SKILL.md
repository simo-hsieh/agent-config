---
name: make-operations-idempotent
description: Designing a command, lifecycle step, installer, or processing loop that must survive crashes, restarts, and retries. Loaded by path from long-run and from installer or script work.
disable-model-invocation: true
---

# Make operations idempotent

Derive each step from the state that exists, not from what a previous run meant to do: read the current state, compare it with the goal, and apply only the difference.

Answer for every state-changing operation:

1. What happens if it runs twice in a row?
2. What happens if the previous run crashed at each possible point?
3. Does every rerun converge to the same end state?

If any answer is "it depends on what was left behind", add a reconciliation step.

Make everything a run leaves behind (a lock, a temp file, a half-written record, a claimed job) recognizable as stale by the next run, using evidence that holds wherever the previous run stopped. Write to a temp path and rename into place; compare artifacts by content, not by creation order.
