# Antigravity CLI adapter

This adapter installs the shared instructions, Agent Skills, and conservative local custom agents for Antigravity CLI. It intentionally does not install the network-enabled `researcher` role because an equivalent of Pi's context and tool isolation has not been verified.

## Requirements

- macOS or Linux
- Antigravity CLI installed and authenticated
- A clone of this repository

The current locally verified version is:

```text
Antigravity CLI (agy) 1.1.4
```

Check the CLI:

```sh
agy --version
```

Official sources:

- [Antigravity CLI repository](https://github.com/google-antigravity/antigravity-cli)
- [CLI features](https://antigravity.google/docs/cli/features)
- [CLI changelog](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md)

## Preview

From the repository root:

```sh
./install.sh --dry-run antigravity
```

Review every proposed backup and link before continuing.

## Install

```sh
./install.sh antigravity
```

Restart active Antigravity sessions afterward. Agent and customization discovery may be cached by an existing process.

## Installed paths

```text
~/.gemini/config/AGENTS.md                       -> <repo>/AGENTS.md
~/.gemini/config/skills/code-review              -> <repo>/skills/code-review
~/.gemini/config/skills/verify-changes            -> <repo>/skills/verify-changes
~/.gemini/config/agents/oracle/agent.md            -> <repo>/antigravity/agents/oracle/agent.md
~/.gemini/config/agents/planner/agent.md           -> <repo>/antigravity/agents/planner/agent.md
~/.gemini/config/agents/reviewer/agent.md          -> <repo>/antigravity/agents/reviewer/agent.md
~/.gemini/config/agents/scout/agent.md             -> <repo>/antigravity/agents/scout/agent.md
~/.gemini/config/agents/worker/agent.md            -> <repo>/antigravity/agents/worker/agent.md
~/.agents/skills/*                                 -> <repo>/skills/*
```

Project-local Antigravity customizations can override global definitions. Antigravity discovers workspace roots named `.agents/`, `.agent/`, `_agents/`, or `_agent/`; custom agents conventionally live at `.agents/agents/<name>/agent.md`.

## Verify files

Run from the repository root:

```sh
ROOT=$(pwd -P)
test "$(readlink "$HOME/.gemini/config/AGENTS.md")" = "$ROOT/AGENTS.md"
test "$(readlink "$HOME/.gemini/config/skills/code-review")" = "$ROOT/skills/code-review"
test "$(readlink "$HOME/.gemini/config/skills/verify-changes")" = "$ROOT/skills/verify-changes"
test "$(readlink "$HOME/.gemini/config/agents/oracle/agent.md")" = "$ROOT/antigravity/agents/oracle/agent.md"
test "$(readlink "$HOME/.gemini/config/agents/reviewer/agent.md")" = "$ROOT/antigravity/agents/reviewer/agent.md"
```

## Verify runtime discovery

```sh
agy agent
```

Expected custom roles:

```text
oracle
planner
reviewer
scout
worker
```

If the interactive agent selector shows only one custom role, exit all active Antigravity sessions, start a new process, and run `agy agent` again. The non-interactive command is the clearest discovery check.

## Why researcher is intentionally absent

The Pi researcher relies on runtime-enforced properties:

```text
fresh child context
no inherited project context or skills
only web_search, fetch_content, and get_search_content
child-only loading of the web extension
```

The currently verified Antigravity agent format establishes role discovery and `subagent: true`, but not an equivalent combination of:

- Fresh context with project context excluded
- A strict web-only tool allowlist
- Child-only network capability loading
- Prevention of local file or shell access

Copying the Pi researcher prompt without these controls would create only a behavioral promise, not the intended privacy boundary. A network-enabled child might still receive or access local project information.

Use the primary agent for local-first inspection. For sanitized external research, continue using Pi's managed `/research` workflow until Antigravity's isolation contract is verified.

## Researcher enablement criteria

Add an Antigravity researcher only after a source-level or executable test confirms:

1. The child can start without parent conversation or project context.
2. Only approved remote search and fetch tools are registered.
3. Local file, shell, mutation, memory, and nested-agent capabilities are absent.
4. Per-role network credentials can be scoped without exposing unrelated secrets.
5. Tool restrictions apply in interactive and headless modes.
6. The role remains constrained when project-local configuration is present.

Tool lists and prompts are harness controls, not an operating-system sandbox.

## Native precedence

Antigravity's documented customization precedence is approximately:

```text
workspace project
  > explicitly declared workspace configuration
  > global ~/.gemini/config
  > built-in customization
  > global declared configuration
```

Treat project-local agents, rules, skills, hooks, and plugins as executable configuration and load them only in trusted projects.
