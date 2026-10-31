# Playbook: bugfix

For a failing test, crash, wrong behavior, or a small behavior-preserving refactor. Work inline with one approach; no planning subagent.

1. **Reproduce.** Run the bare failing test or command first and read the real error. For a refactor, add the missing pinning test.
2. **Fix.** Open only the code at the failing line. Make the smallest root-cause change; never weaken the test.
3. **UI changes.** Run the UI and check it in a browser or screenshot, not only by type check.
4. **Green.** Re-run the exact command once.
5. **Report.** Cause, fix, the command that now passes.

If the work grows past a few files, switch to `feature`.
