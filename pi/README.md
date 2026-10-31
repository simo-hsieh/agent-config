# Pi adapter

`./install.sh pi` installs `AGENTS.md`, the `researcher` subagent, and the subagent runtime limits in `subagents.json`. The `--with-settings` flag also installs `settings.json`, which activates the pinned third-party packages (`pi-web-access`, `pi-subagents`); review the manifest and revisions first, then run `pi update --extensions`. The installer does no network installs.

Pi runs only GPT-6.1 Sol; Opus 5.5 is not allowed in Pi. `subagents.modelScope` enforces GPT-6.1 Sol for every subagent; `defaultThinking` and a `worker` override set `medium` (GPT-6.1 Sol rejects thinking off), and `scout` keeps its builtin `low`. Pi keeps `worker`, `scout`, and the custom `researcher` (fresh context, only `web_search`, `fetch_content`, and `get_search_content`); the review, oracle, auditor, delegate, and external-CLI builtins are disabled because Claude Code does that work. Pi runs parallel subagents itself, up to 4 at once (`subagents.json`). Claude Code drives Pi in Herdr tabs through the `pi-delegate` skill. These are harness tool boundaries, not sandboxes. Targets Pi `1.1.0`, pi-subagents `0.76.1`, and pi-web-access `0.37.0`.

Restart Pi or run `/reload` after changes.
