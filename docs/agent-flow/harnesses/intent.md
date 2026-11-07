# Intent: agy, Codex, and Hermes as delegate harnesses

Status: draft; awaiting approval of the role map and the smoke-test runs.

## Problem

Delegation reaches only Pi (and Claude Code subagents as backup). Three more harnesses are installed and unused by this setup: agy 1.5.3 (Google Antigravity CLI), Codex CLI 0.167.0, and Hermes Agent v0.21.5. Each has its own instruction files, permission model, and usage reporting, so none of them follows `AGENTS.md`, the skills, or the never-push rule today.

## Desired outcome

1. Each harness is a separate adapter in this repo and in `install.sh` (`./install.sh agy codex hermes`).
2. Each harness has a stated delegation mode: how Claude Code sends a task, and how a status-lined report comes back.
3. Each harness has named roles, each with an allow list, and every delegated run records its token use and quota where the harness exposes them.
4. Hermes has a defined role in the flow that the other harnesses do not already cover.

## Constraints

- Claude Code on Opus stays the orchestrator, designer, and reviewer. No delegate drives another harness.
- Delegates never push, merge, open PRs, or move bookmarks.
- Files a harness rewrites at runtime (settings, trust lists, auth) stay machine-local.
- Pi, Codex, and Hermes use the same ChatGPT subscription; only agy adds a separate quota.

## Success criteria

- `./install.sh --dry-run agy codex hermes` lists only links into `~/.agents/src`.
- One smoke run per harness and role returns a parseable report, a usage record, and a denied push.

## Open questions

1. Whether Codex replaces Pi as the default headless worker, since both use GPT-6.1 Sol on one quota.
2. Whether a messaging bot token for the Hermes gateway is acceptable on this machine.
