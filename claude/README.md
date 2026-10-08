# Claude Code adapter

`./install.sh claude` installs `AGENTS.md` as `~/.claude/CLAUDE.md`, the skills, and the `researcher` subagent. `researcher` has only `WebSearch`/`WebFetch` but still inherits `CLAUDE.md`, so it is told to send only sanitized public context. No `settings.json` is managed here; keep permissions and hooks in your own `~/.claude/settings.json`.

Check with `./install.sh --dry-run claude`, then start a new session.
