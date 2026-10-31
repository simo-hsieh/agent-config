# Claude Code adapter

`./install.sh claude` installs `AGENTS.md` as `~/.claude/CLAUDE.md`, the skills, and the subagents in `agents/` (`scout`, `researcher`, `worker`, `reviewer`). Advisory roles get only read tools; `researcher` gets only `WebSearch`/`WebFetch` but still inherits `CLAUDE.md`, so it is told to send only sanitized public context. `worker` is the only role with `Edit`/`Write`.

`./install.sh --with-settings claude` also installs `settings.json` (review it first; it replaces the existing file). Machine-local overrides go in `settings.local.json`, which is gitignored.

Check with `./install.sh --dry-run claude`, then start a new session; existing sessions do not notice new agents or skills.
