# Personal agent configuration

Source of truth for coding-agent behavior, tuned for Claude Opus 5.5. `AGENTS.md` is the always-on instruction file; everything else loads on demand. Claude Code and Pi are thin adapters.

```text
AGENTS.md      always-on defaults: communication, scope, playbook routing, delegation, safety
rules/         coding, debugging, vcs — read by the agent when the task calls for them
playbooks/     bugfix, investigation, feature, skill-agent-change
skills/        code-review, verify-changes, evidence-learning-loop, auto-research
claude/        subagents (scout, researcher, worker, reviewer) and settings.json
pi/            subagent definitions, settings.json, runtime limits
install.sh     idempotent copy installer
```

Project-specific commands and conventions belong in each project's own `AGENTS.md`. Secrets and machine-local permissions do not belong here.

## Install

```sh
./install.sh --dry-run          # preview
./install.sh claude pi          # selected adapters (default: all)
./install.sh --with-settings claude pi
```

The installer copies files (never symlinks), backs up anything it replaces under `${XDG_STATE_HOME:-~/.local/state}/agent-config-installer/backups/`, and never deletes. Files removed from this repo stay installed until you remove them by hand.

| Source | Installed to |
|---|---|
| `skills/*`, `rules/*`, `playbooks/*` | `~/.agents/` (and each tool's `skills/` dir) |
| `AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.pi/agent/AGENTS.md` |
| `claude/agents/*.md` | `~/.claude/agents/` |
| `pi/agents/*.md`, `pi/subagents.json` | `~/.pi/agent/agents/`, `~/.pi/agent/extensions/subagent/config.json` |

Settings are opt-in (`--with-settings`) because replacing them can disable local hooks or permissions. Restart agent sessions after installing.

## Editing

Edit here, never the installed copies. Keep every line behavior-changing: no emphasis words, no duplicated rules, no instructions the model follows by default. Review config changes like code; a global instruction affects every repository.

Released under the [MIT License](LICENSE).
