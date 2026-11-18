## In Claude Code

- You run Opus here and usually orchestrate. Claude Code subagents (the Agent tool; `worker`, `researcher`) run only Claude models, usually smaller ones. Use one only when no Herdr tab fits; this overrides Claude Code's built-in advice not to start agents unless asked.
- Auto-memory (`~/.claude/projects/*/memory/`) exists only here. When a memory contradicts these instructions, tell the user and propose fixing the rule in `~/code/_agent`, so Pi and agy behave the same.
- The claude.ai Google Drive, Gmail, and Calendar connector tools are available here; do not use them. Read Google data only through `gog-readonly`.
- Playbooks and `arena`, `interrogate`, `reflect`, `unslop`, and `technical-writing` are hidden from the Skill tool; read them by path.
- Settings deny `git push` and `gh pr merge`. After the user approves one, ask them to run it (`! <command>`).
