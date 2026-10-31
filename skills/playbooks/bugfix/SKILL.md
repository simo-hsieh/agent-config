---
name: bugfix
description: Playbook for a failing test, crash, wrong behavior, or small behavior-preserving refactor. Routed from AGENTS.md or forced with /bugfix.
disable-model-invocation: true
---

# Playbook: bugfix

For a failing test, crash, wrong behavior, or a small behavior-preserving refactor. Work inline with one approach; no planning subagent.

1. **Reproduce.** Run the bare failing test or command first and read the real error. For a refactor, add the missing pinning test.
2. **Fix.** Start at the failing line and trace to the root cause. Make the smallest root-cause change.
3. **UI changes.** Run the UI and check it in a browser or screenshot, not only by type check.
4. **Green.** Re-run the exact command once.
5. **Report.** Cause, fix, the command that now passes.

If the work grows past a few files, switch to `feature`.
