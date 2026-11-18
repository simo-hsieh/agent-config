# Pi adapter

`settings.json` is a template. `--with-settings` links it as `~/.pi/agent/settings.json`, but Pi writes changelog fields into that file at runtime, so on this Mac the live file is a copy kept in step by hand. The template pins `pi-web-access` with no `extensions` or `skills` filter; an empty filter (`[]`) loads nothing, which is how `web_search` went missing before 2026-11-19. Sessions start with only `web_enable`; calling it adds `web_search` and the fetch tools. `~/.pi/web-search.json` (the legacy path the package still reads when `~/.pi/agent/web-search.json` is absent) must set `"provider": "openai"` so `web_search` uses OpenAI search through the ChatGPT subscription; with `brave` it searches the same index as Claude Code and `auto-research` loses an engine. The installer does no network installs; after a package change run `pi update --extensions`.

The installer prunes links into `~/.agents/src` for retired Pi agent definitions and subagent configuration. It leaves other files and third-party extensions alone. Sessions persist as JSONL under `~/.pi/agent/sessions/`. Pi has no command deny list; project trust is not a sandbox.

Restart Pi or run `/reload` after changes, with the session owner's approval.
