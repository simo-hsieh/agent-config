# Agent roles

This directory is a navigation point for agent-role configuration. Executable role definitions remain in harness-specific adapters because discovery, frontmatter, tools, permissions, and context inheritance are not portable across agent harnesses.

## Guides

- [Agent role user guide](USER_GUIDE.md) — use the roles currently available in this repository.
- [Agent role design guide](agent-role-design-guide.md) — design or customize bounded agent definitions.
- [Agent runtime engineering guide](agent-runtime-engineering-guide.md) — build the harness that resolves and supervises agent executions.

## Pi

Pi subagent definitions are under [`../pi/agents/`](../pi/agents/). The installer links them into:

```text
~/.pi/agent/agents/
```

The pinned `pi-subagents` package provides the orchestration runtime and its unchanged built-in roles. Files in `pi/agents/` are repository-owned overrides or additions, such as the restricted external `researcher`.

## Claude Code

Claude Code subagent definitions are under [`../claude/agents/`](../claude/agents/). The installer links them into:

```text
~/.claude/agents/
```

Claude Code has no separate orchestration package to inherit roles from, so every file in `claude/agents/` is repository-owned. It currently covers the conservative, local roles (`scout`, `planner`, `worker`, `reviewer`, `oracle`); the network-enabled `researcher` is deferred until a Claude Code subagent's context and tool isolation is verified, the same bar applied to the Antigravity adapter.

Do not copy bundled roles here merely to make them appear portable. Add a model-neutral role contract here only after at least two harness adapters genuinely share it; keep harness-specific metadata in their respective adapter directories.
