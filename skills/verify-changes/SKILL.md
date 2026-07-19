---
name: verify-changes
description: Validate code changes using repository-specific tests, type checks, linting, formatting, builds, and diff inspection. Use after implementation or when the user asks whether changes are ready.
---

# Verify Changes

Build evidence that the current change works without hiding failures or modifying unrelated code.

## Process

1. Read repository instructions and inspect package/build configuration to discover supported commands.
2. Inspect the diff for accidental edits, debug output, generated artifacts, secrets, and incomplete work.
3. Run the narrowest relevant tests first.
4. Run applicable type checking, linting, formatting checks, or builds.
5. Expand to broader tests when the change has wide impact and the cost is reasonable.
6. Diagnose failures and distinguish failures caused by the change from pre-existing or environmental failures.

Do not install dependencies, update snapshots, rewrite lockfiles, or apply broad automatic fixes unless necessary and permitted by the task.

## Report

Provide:

- each command run and whether it passed
- failures with the important error and likely cause
- checks not run and why
- residual risks or areas requiring manual verification

Never describe a result as verified when the relevant command was not run.
