# Pi adapter

`./install.sh pi` installs `AGENTS.md`, the `researcher` subagent, and the subagent runtime limits in `subagents.json`. The `--with-settings` flag also installs `settings.json`, which activates the pinned third-party packages (`pi-web-access`, `pi-subagents`); review the manifest and revisions first, then run `pi update --extensions`. The installer does no network installs.

The researcher uses fresh context and only `web_search`, `fetch_content`, and `get_search_content`. `reviewer` is restricted to read tools and `worker` uses Sonnet 5 through `agentOverrides`; `context-builder` and `delegate` are disabled. These are harness tool boundaries, not sandboxes. Targets Pi `0.85.0`.

Restart Pi or run `/reload` after changes.
