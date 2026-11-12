---
name: how
description: Explains how code works and where a change belongs, in the current repo or any local code directory. Use for "how does X work", "where does X live", or "where should this go". Read-only.
---

# How

- **Target.** The current repo, or the local directory named. In a repo too large to read, start from its code-search tool and read only the hits.
- **Scope.** A narrow question or one module: explore and answer directly. A subsystem spanning several files or services: split it into 2–4 angles, each a read-only subagent (Claude Code `Explore`; Pi `worker`, told read-only). When in doubt, answer directly.
- **Each angle returns** its components with `file:line`, the flow, boundaries, non-obvious behavior, and open questions.
- **Answer** in the main session: Overview, Key concepts, How it works (a diagram when 3+ parts interact), Where things live, Gotchas. Drop empty sections. Mark gaps UNVERIFIED.
- Change no code and no VCS state.
