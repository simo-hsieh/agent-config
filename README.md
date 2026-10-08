# Personal agent configuration

Source of truth for coding-agent behavior, tuned for Claude Opus 5.5. `AGENTS.md` is the always-on instruction file; everything else loads on demand. Claude Code and Pi are thin adapters.

```text
AGENTS.md      always-on defaults: communication, scope, playbook routing, delegation, safety
rules/         coding — read by the agent before writing code
playbooks/     bugfix, feature (intent <-> design <-> code)
skills/        code-review, evidence-learning-loop, auto-research
claude/        researcher and worker subagents
pi/            subagent definitions, settings.json, runtime limits
install.sh     idempotent copy installer
```

Project-specific commands and conventions belong in each project's own `AGENTS.md`. Secrets and machine-local permissions do not belong here.

## Install

```sh
./install.sh --dry-run          # preview
./install.sh claude pi          # selected adapters (default: all)
./install.sh --with-settings pi
```

The installer copies files (never symlinks), backs up anything it replaces under `${XDG_STATE_HOME:-~/.local/state}/agent-config-installer/backups/`, and never deletes. Files removed from this repo stay installed until you remove them by hand.

| Source | Installed to |
|---|---|
| `skills/*`, `rules/*`, `playbooks/*` | `~/.agents/` (and each tool's `skills/` dir) |
| `AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.pi/agent/AGENTS.md` |
| `claude/agents/*.md` | `~/.claude/agents/` |
| `pi/agents/*.md`, `pi/subagents.json` | `~/.pi/agent/agents/`, `~/.pi/agent/extensions/subagent/config.json` |

Settings are opt-in (`--with-settings`) because replacing them can disable local hooks or permissions. Restart agent sessions after installing.

## Models

- **Main thinking model:** Claude Opus 5.5 (`anthropic/claude-opus-5-5`), used for design and review.
- **Main non-thinking model:** GPT-5.6 Sol (`openai-codex/gpt-5.6-sol`), the Pi default with thinking off, and the Pi `worker`.
- **Backup:** Claude Sonnet 5.5. Pi's model catalog (0.85) does not list it yet, so Pi has no pinned backup; update Pi, then set `anthropic/claude-sonnet-5-5`.
- **Claude Code:** the session runs Opus 5.5; `researcher` and `worker` run Sonnet 5.5.

## Editing

Edit here, never the installed copies. Keep every line behavior-changing: no emphasis words, no duplicated rules, no instructions the model follows by default. Review config changes like code; a global instruction affects every repository.

Released under the [MIT License](LICENSE).
