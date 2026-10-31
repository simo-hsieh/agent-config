# Claude Code adapter

`./install.sh claude` installs `AGENTS.md` as `~/.claude/CLAUDE.md`, the skills, and the `researcher` and `worker` subagents, on Sonnet 5.5 (`model: sonnet`) at `effort: high` for `worker` and `medium` for `researcher`; the main session stays on Opus 5.5. Inside Herdr (`HERDR_ENV=1`) the `pi-delegate` skill runs these roles in Pi on GPT-6.1 Sol instead, so the subagents are the fallback. Claude Code subagents can only use Claude models. `researcher` has only `WebSearch`/`WebFetch` but still inherits `CLAUDE.md`, so it is told to send only sanitized public context. No `settings.json` is managed here; keep permissions and hooks in your own `~/.claude/settings.json`.

Check with `./install.sh --dry-run claude`, then start a new session.
