# Claude Code adapter

This adapter installs the shared instructions, Agent Skills, and repository-owned subagent role files for Claude Code.

## Requirements

- macOS or Linux
- Claude Code installed and authenticated
- A clone of this repository

Check the CLI:

```sh
claude --version
```

## Preview

From the repository root:

```sh
./install.sh --dry-run claude
```

Preview optional shared settings as well:

```sh
./install.sh --dry-run --with-settings claude
```

Review every proposed backup and link before continuing.

## Install

Install instructions, skills, and subagent roles:

```sh
./install.sh claude
```

Install the managed Claude settings only after reviewing [`settings.json`](settings.json):

```sh
./install.sh --with-settings claude
```

`--with-settings` backs up an existing `~/.claude/settings.json` and replaces it with a symlink. It does not merge hooks, permissions, or machine-local configuration.

## Installed paths

```text
~/.claude/CLAUDE.md      -> <repo>/AGENTS.md
~/.claude/skills/*       -> <repo>/skills/*
~/.claude/agents/*       -> <repo>/claude/agents/*
~/.claude/settings.json  -> <repo>/claude/settings.json  (--with-settings only)
~/.agents/skills/*       -> <repo>/skills/*
```

The `CLAUDE.md` symlink makes the model-neutral `AGENTS.md` the user-level instruction source for Claude Code.

## Subagent roles

`claude/agents/` currently defines the conservative, local roles described in the [agent role user guide](../agents/USER_GUIDE.md): `scout`, `planner`, `worker`, `reviewer`, and `oracle`. Each restricts its `tools` frontmatter to local, read-only capabilities (`worker` additionally gets `Edit`/`Write` as the sole writer); none has network access. Invoke them with intent-oriented language, e.g. "Ask reviewer to review the current diff and report findings only."

The network-enabled `researcher` role available to the Pi adapter (see [`../pi/agents/researcher.md`](../pi/agents/researcher.md)) is deliberately not ported here yet. Porting it requires the same privacy-boundary review noted for the Antigravity adapter: verifying that a Claude Code subagent restricted to `WebFetch`/`WebSearch` genuinely excludes local file, Bash, and inherited project context before it is trusted with external queries.

## Verify

Run from the repository root:

```sh
ROOT=$(pwd -P)
test "$(readlink "$HOME/.claude/CLAUDE.md")" = "$ROOT/AGENTS.md"
test "$(readlink "$HOME/.claude/skills/code-review")" = "$ROOT/skills/code-review"
test "$(readlink "$HOME/.claude/skills/verify-changes")" = "$ROOT/skills/verify-changes"
test "$(readlink "$HOME/.claude/agents/reviewer.md")" = "$ROOT/claude/agents/reviewer.md"
```

If settings were installed:

```sh
test "$(readlink "$HOME/.claude/settings.json")" = "$ROOT/claude/settings.json"
```

Then start a new Claude Code session and check that it can discover the `code-review` and `verify-changes` skills, and that `scout`, `planner`, `worker`, `reviewer`, and `oracle` appear as available subagent types. Existing sessions may not notice a newly created agents or skills directory until restarted.

## Current limitations

- Pi agent frontmatter under `pi/agents/` is not compatible with Claude Code; `claude/agents/*.md` role files are authored separately with Claude-native frontmatter (`tools`, `model`), not copied.
- The network-enabled `researcher` role is not yet ported to Claude Code; see [Subagent roles](#subagent-roles) above.
- Claude permissions remain Claude-specific and should not be inferred from Pi tool lists.
- Keep secrets and machine-local permission exceptions outside this repository.
