# Codex adapter

This adapter installs the model-neutral instructions and Agent Skills for Codex. It does not install Codex-specific custom agent roles or settings.

## Requirements

- macOS or Linux
- Codex CLI installed and authenticated
- A clone of this repository

Check the CLI:

```sh
codex --version
```

## Preview

From the repository root:

```sh
./install.sh --dry-run codex
```

## Install

```sh
./install.sh codex
```

## Installed paths

```text
~/.codex/AGENTS.md  -> <repo>/AGENTS.md
~/.codex/skills/*   -> <repo>/skills/*
~/.agents/skills/*  -> <repo>/skills/*
```

## Verify

Run from the repository root:

```sh
ROOT=$(pwd -P)
test "$(readlink "$HOME/.codex/AGENTS.md")" = "$ROOT/AGENTS.md"
test "$(readlink "$HOME/.codex/skills/code-review")" = "$ROOT/skills/code-review"
test "$(readlink "$HOME/.codex/skills/verify-changes")" = "$ROOT/skills/verify-changes"
```

Start a new Codex session and confirm that the shared instructions apply and the `code-review` and `verify-changes` skills are discoverable.

## Current limitations

- No Codex-specific role adapter is installed.
- Pi agent definitions must not be copied into Codex because tool, context, and permission semantics differ.
- Machine-local authentication, sandboxing, approval policies, and secrets remain outside this repository.
