# Pi adapter

This is the most complete adapter. It installs shared instructions, Pi prompt templates, the restricted `researcher` role, subagent runtime limits, and optionally the reviewed package manifest.

## Requirements

- macOS or Linux
- Pi installed and authenticated
- Git and Node.js/npm for package reconciliation
- A clone of this repository

Check the CLI:

```sh
pi --version
```

The currently reviewed configuration targets Pi `0.82.1`.

## Preview

From the repository root:

```sh
./install.sh --dry-run pi
```

Preview settings and package activation:

```sh
./install.sh --dry-run --with-settings pi
```

Review [`settings.json`](settings.json), [`PACKAGES.md`](PACKAGES.md), and every proposed backup before continuing.

## Install

Install instructions, prompts, the repository-owned agent, and subagent limits:

```sh
./install.sh pi
```

Install the managed settings and pinned package manifest:

```sh
./install.sh --with-settings pi
pi update --extensions
```

`pi update --extensions` performs network access and installs or reconciles the exact package revisions declared in `settings.json`. The repository installer itself does not install network packages.

## Installed paths

```text
~/.pi/agent/AGENTS.md                           -> <repo>/AGENTS.md
~/.pi/agent/settings.json                       -> <repo>/pi/settings.json  (--with-settings only)
~/.pi/agent/prompts/*                           -> <repo>/prompts/*
~/.pi/agent/skills/gws-*                        -> <repo>/pi/skills/gws-*
~/.pi/agent/agents/researcher.md                 -> <repo>/pi/agents/researcher.md
~/.pi/agent/extensions/subagent/config.json      -> <repo>/pi/subagents.json
~/.agents/skills/*                               -> <repo>/skills/*
```

Pi discovers the vendor-neutral `~/.agents/skills` directory directly, so duplicate links under `~/.pi/agent/skills` are intentionally not created.

## Verify files

Run from the repository root:

```sh
ROOT=$(pwd -P)
test "$(readlink "$HOME/.pi/agent/AGENTS.md")" = "$ROOT/AGENTS.md"
test "$(readlink "$HOME/.agents/skills/evidence-learning-loop")" = "$ROOT/skills/evidence-learning-loop"
test "$(readlink "$HOME/.pi/agent/skills/gws-shared")" = "$ROOT/pi/skills/gws-shared"
test "$(readlink "$HOME/.pi/agent/skills/gws-drive-upload")" = "$ROOT/pi/skills/gws-drive-upload"
test "$(readlink "$HOME/.pi/agent/agents/researcher.md")" = "$ROOT/pi/agents/researcher.md"
test "$(readlink "$HOME/.pi/agent/extensions/subagent/config.json")" = "$ROOT/pi/subagents.json"
test "$(readlink "$HOME/.pi/agent/prompts/research.md")" = "$ROOT/prompts/research.md"
```

If settings were installed:

```sh
test "$(readlink "$HOME/.pi/agent/settings.json")" = "$ROOT/pi/settings.json"
```

## Verify packages and runtime

```sh
pi list
```

Expected package sources are pinned revisions of:

```text
nicobailon/pi-web-access
nicobailon/pi-subagents
```

Start a new Pi session. Confirm the evidence skill loads without warnings by running:

```text
/skill:evidence-learning-loop
```

Then ask:

```text
Show me the available subagents.
```

Expected visible roles:

```text
researcher
reviewer
worker
scout
planner
oracle
```

`context-builder` and `delegate` are intentionally disabled. The reviewer should have `read`, `grep`, `find`, `ls`, and `bash`, but no `edit` or `write`. The researcher should use fresh context, Sonnet 4.6, and only `web_search`, `fetch_content`, and `get_search_content`.

## Google Drive uploads

The Pi adapter installs the reviewed `gws-shared` and `gws-drive-upload` skills from Google Workspace CLI `0.22.5`; see the vendored [`UPSTREAM.md`](skills/UPSTREAM.md) for provenance and integration notes. Install the CLI separately, then authenticate it with Drive-only access:

```sh
brew install googleworkspace-cli
# or: npm install -g @googleworkspace/cli

gws auth setup
gws auth login --scopes https://www.googleapis.com/auth/drive
```

OAuth setup may create or modify a Google Cloud project and opens a browser for consent. Keep generated credentials out of this repository. Version 0.22.5 encrypts its saved OAuth credentials and token cache under `~/.config/gws`; generated client configuration can still contain sensitive plaintext. The CLI does not prompt before uploading—the vendored skill requires Pi to obtain user confirmation before invoking the write command.

After authentication, restart Pi or run `/reload`, then ask Pi to upload a file. A direct smoke test is:

```sh
gws drive files list --params '{"pageSize": 1, "fields": "files(id,name)"}'
```

## Web research configuration

The parent Pi process does not load web tools. The researcher loads `pi-web-access` as a child-only extension.

Machine-local search configuration belongs at:

```text
~/.pi/web-search.json
```

The recommended configuration uses Brave Search, disables browser cookies, and disables GitHub cloning and media processing. Keep `BRAVE_API_KEY` outside this repository and restrict any file containing credentials:

```sh
chmod 600 ~/.pi/web-search.json
```

Smoke-test with a sanitized public question:

```text
/research What is the current documented behavior of <public library feature> in version <version>?
```

Do not include private repository names, source code, internal URLs, credentials, customer data, or device evidence.

## Reload and troubleshooting

Restart active Pi sessions after changing settings, agent definitions, extension configuration, prompts, or package revisions.

If a package is missing:

```sh
pi update --extensions
pi list
```

If a role is missing, verify the symlink first, then restart Pi. Tool restrictions are harness boundaries, not an operating-system sandbox.
