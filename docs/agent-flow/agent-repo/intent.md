# Intent: treat the agent repo as a codebase

Status: draft.

## Problem

`~/code/_agent` holds skills, playbooks, agent-team design, and later benchmarks, yet its conventions live in the global AGENTS.md as the `config-change` row, loaded in every session and named as if it were configuration.

## Desired outcome

- The global instructions carry one line: to change agent behavior, work in `~/code/_agent`.
- The repo's own project instructions hold its conventions (one home per rule, every line behavior-changing, skill layout and loading, publishing through `~/.agents/src`), and work in it follows `feature` and `bugfix` like any repo.
- The improvement pipeline's collect and propose steps live there too.

## Open questions

1. File layout: move the global file to `global/AGENTS.md` and make the root `AGENTS.md` the project file; verify that Claude Code loads a project `CLAUDE.md` link to it alongside the global file.
