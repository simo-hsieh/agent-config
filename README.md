# Personal agent configuration

A portable, tool-neutral source of truth for coding-agent behavior. `AGENTS.md` and Agent Skills are canonical; Claude Code, Pi, Codex, and Antigravity are adapters around them. The instructions remain model-neutral whether the harness uses a model from Anthropic, OpenAI, Google, or another provider.

## Design

```text
_agent/
├── AGENTS.md              shared defaults, kept deliberately compact
├── agents/                agent usage, role design, and runtime guides
├── docs/                  design proposals and decisions
├── skills/                Agent Skills standard capabilities
├── prompts/               Pi prompt templates
├── claude/
│   ├── agents/            repository-owned Claude Code subagent roles
│   └── settings.json      shared Claude Code settings
├── pi/
│   ├── agents/            managed Pi subagent definitions
│   ├── skills/            reviewed Pi-specific skills and provenance
│   ├── settings.json      shared Pi settings and pinned package manifest
│   ├── subagents.json     conservative pi-subagents runtime limits
│   └── PACKAGES.md        package review and upgrade policy
├── codex/                 Codex-specific additions when needed
├── antigravity/           Antigravity shared resources and conservative roles
└── install.sh             portable, idempotent symlink installer
```

The repository separates three layers:

1. **Shared defaults** — behavior that should apply across projects and harnesses.
2. **Skills** — detailed workflows loaded only when relevant, avoiding permanent context cost.
3. **Adapters** — settings or resources that only one harness understands.

Project-specific build commands, architecture, and conventions belong in each project's own `AGENTS.md`, not here. Secrets and machine-local permissions do not belong in this repository.

## Install

Preview all supported adapters:

```sh
./install.sh --dry-run
```

Install Claude Code and Pi:

```sh
./install.sh claude pi
```

Install every supported adapter:

```sh
./install.sh
```

Harness settings are intentionally opt-in because replacing an existing settings file can disable machine-specific hooks, permissions, or extensions. Pi settings also activate the reviewed third-party packages declared in `pi/settings.json`:

```sh
./install.sh --with-settings claude pi
pi update --extensions
```

The second command installs or reconciles the pinned Pi packages after you have reviewed the manifest. The installer itself does not perform network package installation.

The installer uses absolute symlinks so edits remain visible in this repository. Existing destinations are moved to timestamped backups and never deleted.

### Installed paths

Shared skills are installed under the vendor-neutral location:

```text
~/.agents/skills/*
```

Adapters are installed as follows:

```text
~/.claude/CLAUDE.md        -> AGENTS.md
~/.claude/settings.json    -> claude/settings.json  (--with-settings only)
~/.claude/skills/*         -> skills/*
~/.claude/agents/*         -> claude/agents/*

~/.pi/agent/AGENTS.md      -> AGENTS.md
~/.pi/agent/settings.json                    -> pi/settings.json      (--with-settings only)
~/.pi/agent/prompts/*                        -> prompts/*
~/.pi/agent/skills/gws-*                     -> pi/skills/gws-*
~/.pi/agent/agents/*                         -> pi/agents/*
~/.pi/agent/extensions/subagent/config.json  -> pi/subagents.json

~/.codex/AGENTS.md         -> AGENTS.md
~/.codex/skills/*          -> skills/*

~/.gemini/config/AGENTS.md                  -> AGENTS.md
~/.gemini/config/skills/*                   -> skills/*
~/.gemini/config/agents/<role>/agent.md      -> antigravity/agents/<role>/agent.md
```

Pi discovers `~/.agents/skills` directly, so duplicate links under `~/.pi/agent/skills` are intentionally avoided. Antigravity installs conservative local roles but intentionally omits the network-enabled researcher until equivalent context and tool isolation is verified.

### Adapter installation guides

- [Claude Code](claude/README.md)
- [Pi](pi/README.md)
- [Codex](codex/README.md)
- [Antigravity CLI](antigravity/README.md)

## Pi packages

Pi packages are declared directly in the native `packages` array in `pi/settings.json`. Third-party executable packages are pinned to immutable revisions and upgraded deliberately rather than tracking a branch. See [`pi/PACKAGES.md`](pi/PACKAGES.md) for the review policy, current inventory, and update workflow.

Web access is installed but filtered out of the parent process. The managed `researcher` subagent loads it as a child-only extension, runs with fresh context and no local file, Bash, or mutation tools, and returns a cited brief. Use `/research <question>` for this local-first, sanitized workflow. This tool boundary reduces accidental use but is not an operating-system sandbox.

Do not install the managed Pi settings on a corporate or restricted machine merely for consistency. Network-enabled extensions should only be enabled where their external data flows are permitted.

## Design documents

- **Draft proposal:** [`docs/prompt-to-device-evaluation-platform.md`](docs/prompt-to-device-evaluation-platform.md) — reproducible prompt-to-template and device-provisioning evaluation with a bounded optimization loop

## License and attribution

Released under the [MIT License](LICENSE). Portions of this repository were developed with AI assistance and subsequently reviewed and edited by the maintainer.

This is an unofficial personal configuration repository. It is not affiliated with or endorsed by Anthropic, OpenAI, Google, Pi, or the maintainers of referenced third-party packages. Product names may be trademarks of their respective owners.

Referenced packages remain subject to their own licenses; this repository pins them but does not vendor their source.

## Maintenance rules

- Keep `AGENTS.md` broadly applicable and short enough to load in every session.
- Add a skill only for a distinct workflow that benefits from progressive disclosure.
- Keep tool-specific syntax in its adapter directory.
- Prefer repository-level instructions over adding exceptions to global defaults.
- Review configuration changes like code; a global instruction can affect every repository.
- Do not commit `settings.local.json`, credentials, session history, trust databases, or generated caches.

## Machine-local settings

Use harness-supported local or project settings for permissions that should not travel between machines. The previous Claude permission file, if present during migration, is retained as `claude/settings.local.json` and ignored by Git; it is not installed globally.

## Adding another harness

Only add an adapter after its discovery and precedence rules are known. Prefer pointing it at `AGENTS.md` and `~/.agents/skills` rather than copying content. If an internal CLI is under your control, use this order:

1. user-global `AGENTS.md`
2. ancestor `AGENTS.md` files from repository root toward the working directory
3. current-directory `AGENTS.md`
4. a documented fallback such as `CLAUDE.md` only when `AGENTS.md` is absent

More-specific instructions should override broader defaults deterministically.
