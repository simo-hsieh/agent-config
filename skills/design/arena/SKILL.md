---
name: arena
description: Runs one task as two independent candidates on different model families, then picks a base and grafts the best of the other. Use for /arena on a shape-level fork that can't be settled by measuring.
disable-model-invocation: true
---

# Arena

1. **Frame.** State the artifact both candidates produce and write a rubric of 3–6 gradeable criteria. Only you see the rubric; candidates see the task.
2. **Fan out.** Run a Claude Code subagent and a Pi `worker` (GPT, via `pi-delegate`) on the same task and grounding, each in its own jj workspace (`jj workspace add`) or scratch directory. Tell each to produce its best version, not a hedge, and to name the alternatives it rejected.
3. **Judge.** A read-only judge from the family that does not synthesize scores each candidate against the rubric and recommends a base. This cross-family check is allowed under AGENTS.md.
4. **Pick.** Read both candidates in full and score them yourself, criterion by criterion. If you and the judge disagree, reread both rationales before deciding. On a tie, prefer the smaller interface or cleaner boundary.
5. **Graft** one or two ideas from the other candidate by hand, so the result keeps one design. If the candidates converged, say so and graft nothing. If they diverged wildly, the framing was wrong: reframe and rerun.
6. **Verify** the result like any other output, then remove the workspaces you created.

Report the base and why, the judge's verdict, each graft and its source, what you rejected, and the verification result.
