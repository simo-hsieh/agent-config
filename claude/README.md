# Claude Code adapter

`./install.sh claude` installs `AGENTS.md` as `~/.claude/CLAUDE.md`, the skills, and the `researcher` and `worker` subagents, both on Sonnet 5.5 (`model: sonnet`); the main session stays on Opus 5.5. Claude Code subagents can only use Claude models. `researcher` has only `WebSearch`/`WebFetch` but still inherits `CLAUDE.md`, so it is told to send only sanitized public context. No `settings.json` is managed here; keep permissions and hooks in your own `~/.claude/settings.json`.

Check with `./install.sh --dry-run claude`, then start a new session.
