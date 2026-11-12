---
name: code-review
description: Review a working tree, commit, pull request, patch, or selected files for correctness, regressions, security, and maintainability. Use when the user requests a code review or asks for risks in a change.
---

# Code Review

Review as a skeptical maintainer. Do not edit code unless the user also asks for fixes.

## Process

1. Identify the review target and its intended behavior.
2. Read repository instructions, any project `REVIEW.md`, and the surrounding code needed to understand invariants and call sites.
3. Inspect the complete relevant diff; do not infer the change from filenames alone.
4. When `intent.md`, `design.md`, `plan.md`, an issue, or a user request defines the expected behavior, check the change against that artifact.
5. Check for:
   - incorrect behavior and edge cases
   - regressions and compatibility breaks
   - security, privacy, and unsafe input handling
   - concurrency, lifecycle, and error-handling problems
   - missing or misleading tests
   - unnecessary complexity only when it creates a concrete maintenance risk
6. Prove each finding with a run against the real code (a failing test, repro, or command output) where that is cheap; otherwise verify it against the code and mark it UNVERIFIED.

## Output

List findings first, ordered by severity. For each finding include:

- severity: critical, high, medium, or low
- precise file and line reference
- the failure scenario or affected invariant
- why it matters
- a concise remediation direction

Avoid style-only comments unless they violate an explicit project convention or obscure correctness. If there are no substantive findings, say so and mention any testing or context gaps that limit confidence.
