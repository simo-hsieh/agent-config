---
name: tdd
description: Red-green cycle for a bugfix or one feature unit. Loaded by path from the bugfix fix step and the feature code step.
disable-model-invocation: true
---

# TDD

1. **Name the behavior**: intended, current, and the smallest observable reproduction.
2. **Pick the narrowest existing check** for that code path: the closest unit, component, integration, or regression test already in use.
3. **Write the failing test first.** Drive the code through its users' interface with a concrete input, and derive the expected value from the requirement, not from a run of the code.
4. **Run it and confirm it fails for the intended reason.** If it passes, or fails for another reason, fix the test before touching the code.
5. **Change the code** minimally, then rerun the test and nearby checks until green.

## Judge the test

A good test catches a broken behavior (a wrong value, a skipped or doubled effect) and survives a refactor that keeps every observable result. Rewrite or delete a test that fails either edit. Behavior is what users of the interface observe: return values, errors, readable state, and effects on outside systems, including the payload a mocked external service receives. A call to an internal helper is not behavior.

Prefer no new test over a bad one: a test that mostly exercises mocks, depends on timing or global state, mirrors the implementation, or needs heavy infrastructure for a small fix. Then use the closest executable check instead (a script, a repro command, browser automation) and say why.

Never change a test to match a wrong implementation, and never weaken an assertion unless the intended behavior changed.

## Record

Keep the test and the code in one jj topic. Its description and the report give the failing-before run and the passing-after run, or why a failing test was impractical.
