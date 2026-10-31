---
name: bugfix
description: Playbook for a failing test, crash, wrong behavior, or small behavior-preserving refactor. Routed from AGENTS.md or forced with /bugfix.
disable-model-invocation: true
---

# Playbook: bugfix

For a failing test, crash, wrong behavior, or a small behavior-preserving refactor. Work inline with one approach; no planning subagent.

1. **Reproduce.** Run the bare failing test or command first and read the real error, on the surface where the bug shows (a UI bug in a browser or screenshot). For a refactor, add the missing pinning test.
2. **Find the root cause.** Start at the failing line and ask "why" until the answer is a wrong decision in the code. Decide whether the triggering state is legitimate (fix the code that broke on it) or should never exist (find what produced it; a guard where it broke hides the bug). For a failure that appears only after a restart, suspect persisted state first. When state is unclear, instrument and read it as the code runs.
3. **Fix test-first** per `~/.agents/skills/tdd/SKILL.md`: the smallest root-cause change, and every instance of the same fault in the system you are changing.
4. **Green.** Re-run the exact command once, on the same surface as step 1.
5. **Report.** Cause, fix, the failing-before and passing-after runs, and the cheap always-on signal that would have shown this cause at first look.

If the work grows past a few files, switch to `feature`.
