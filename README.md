# Personal agent configuration

Source of truth for coding-agent behavior, tuned for Claude Opus 5.5. `AGENTS.md` is the always-on instruction file; everything else loads on demand. Claude Code, Pi, and Antigravity (`agy`) are thin adapters.

```text
AGENTS.md      always-on defaults: communication, scope, playbook routing, delegation, safety
rules/         coding — read by the agent before writing code
skills/        <intent>/<skill>/SKILL.md, installed flat by skill name
  playbooks/   investigation, bugfix, feature, perf, ship, long-run (routed by AGENTS.md)
  understand/  how, why, recall, teach, auto-research
  clarify/     sharpen
  design/      arena, model-the-domain, make-operations-idempotent
  build/       tdd, typescript-best-practices
  verify/      code-review, blast-radius, interrogate, benchmark-checklist, statechart,
               create-/maintain-verification-skill, create-/maintain-formal-verification-skill
  write/       unslop, technical-writing, ketchup, bro
  learn/       evidence-learning-loop, reflect, correct
  operate/     delegate
  tools/       jj, agent-browser, notion-mcp
claude/        researcher and worker subagents (outside Herdr), delegate tab deny list
pi/            subagent definitions, settings.json, runtime limits
agy/           no-subagents hook plugin and delegate tab deny list
models.md      model and effort per harness tier, task routing, evidence
bin/           model-usage: per-model delegate stats from session logs
install.sh     symlink installer into the stable workspace ~/.agents/src
```

Project-specific commands and conventions belong in each project's own `AGENTS.md`. Secrets and machine-local permissions do not belong here.

## Install

```sh
./install.sh --dry-run          # preview
./install.sh claude pi agy      # selected adapters (default: all)
./install.sh --with-settings pi
```

The installer links each installed path into a second jj workspace at `~/.agents/src` (override with `AGENT_SRC`), so only the change checked out there is live; drafts in this working copy are not. It fails on duplicate skill names across intents, backs up any file it replaces under `${XDG_STATE_HOME:-~/.local/state}/agent-config-installer/backups/`, and removes only dangling links into `~/.agents/src`.

```sh
jj workspace add ~/.agents/src                  # once
jj -R ~/.agents/src new <accepted-change>       # go live with a new accepted change
jj -R ~/.agents/src workspace update-stale      # after rewriting the accepted change
```

| Source | Installed to |
|---|---|
| `skills/<intent>/<skill>`, `rules/*` | `~/.agents/skills/<skill>`, `~/.agents/rules/` (skills also to `~/.claude/skills/<skill>` and `~/.gemini/config/skills/<skill>`) |
| `AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.pi/agent/AGENTS.md`, `~/.gemini/config/AGENTS.md` |
| `claude/agents/*.md` | `~/.claude/agents/` |
| `pi/agents/*.md`, `pi/subagents.json` | `~/.pi/agent/agents/`, `~/.pi/agent/extensions/subagent/config.json` |
| `agy/plugins/*` | `~/.gemini/config/plugins/` |

Settings are opt-in (`--with-settings`) because replacing them can disable local hooks or permissions. Restart agent sessions after installing.

## Models

[`models.md`](models.md) holds the model and effort for each harness tier, which tab takes each task type, the evidence, and the review procedure. In short:

- **Orchestrator:** the session you steer, normally Claude Code on Opus 5.5, does design, hard bugs, and final review. Opus is not allowed in Pi.
- **Delegates:** inside Herdr, the `delegate` skill runs `researcher` and `worker` work in a thinking or fast tab of Claude Code, Pi (GPT-6.1), or agy (Gemini 4), chosen by task type. Cross-family seats (`arena`, `interrogate`, `reflect`) take any family other than the author's.
- **Out of quota:** a tab that hits a usage limit is marked blocked for the session and its work goes to the next tab in its Task map row; with every other harness blocked, the orchestrator does the work itself. When the orchestrator's own harness hits its limit, continue in a Pi or agy session; the same skills and `models.md` apply there.
- **Outside Herdr:** Claude Code gives larger tasks to its `researcher` and `worker` subagents on Sonnet 5.5; Pi uses its own subagents; agy works single-agent.

```mermaid
flowchart LR
  O["Orchestrator<br/>Claude Code, Pi, or agy"]
  O -->|"delegate skill<br/>models.md Task map"| T["Herdr tab<br/>harness and tier"]
  T --> C["Claude Code<br/>Opus or Sonnet"]
  T --> P["Pi<br/>Sol or Terra"]
  T --> A["agy<br/>Carbon or Hydrogen"]
  T -. "BLOCKED on quota<br/>next tab in row" .-> T
  T -. "status line + report" .-> O
```

## Editing

Edit here, never the installed copies. Keep every line behavior-changing: no emphasis words, no duplicated rules, no instructions the model follows by default. Review config changes like code; a global instruction affects every repository.

Many skills and playbooks are adapted from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, Lauren Tan; notice in `LICENSE`); `docs/agent-flow/intent.md` records each adoption decision.

Released under the [MIT License](LICENSE).
