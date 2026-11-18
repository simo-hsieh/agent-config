# Antigravity adapter

`./install.sh agy` links `AGENTS.md` followed by `agy/harness.md`, and the skills, into `~/.gemini/config/`, leaving `~/.gemini/config/hooks.json` (Herdr's hook) and `~/.gemini/antigravity-cli/settings.json` untouched. agy subagents can let a turn go idle before the work finishes, so an orchestrator waits for an agy delegate's `status:` line rather than an idle tab. When started as a delegate tab, pass `--settings ~/.agents/src/agy/delegate.json` to block pushes, PRs, and bookmark moves.

Check with `./install.sh --dry-run agy`, then start a new `agy` session.
