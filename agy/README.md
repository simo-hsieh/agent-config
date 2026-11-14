# Antigravity adapter

`./install.sh agy` links `AGENTS.md`, the skills, and the `no-subagents` plugin into `~/.gemini/config/`, leaving `~/.gemini/config/hooks.json` (Herdr's hook) and `~/.gemini/antigravity-cli/settings.json` untouched. `no-subagents` blocks `invoke_subagent`, `define_subagent`, `swarm`, and `run_workflow` through a `PreToolUse` hook so `agy` never spawns background subagents that let a turn go idle early under `herdr agent prompt --wait`. Inside Herdr (`HERDR_ENV=1`), `agy` delegates through Herdr tabs instead; when started as a delegate tab, pass `--settings ~/.agents/src/agy/delegate.json` to block pushes, PRs, and bookmark moves.

Check with `./install.sh --dry-run agy` and `agy plugin validate agy/plugins/no-subagents`, then start a new `agy` session.
