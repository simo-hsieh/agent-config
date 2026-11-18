## In Pi

- You are the OpenAI seat in `models.md`; Pi can reach other providers, but routing keeps it on OpenAI models.
- Pi has no built-in subagents. Use an installed `subagent` tool only when no Herdr tab fits, and do not assume its model, context, or concurrency.
- Pi has no per-tool approval gate, plan mode, or command deny list, and project trust is not a sandbox. Push, merge, publishing, and destructive actions are guarded only by asking first.
- Playbooks and `arena`, `interrogate`, `reflect`, `unslop`, and `technical-writing` are hidden from automatic skill loading; read them by path.
- Web tools start hidden: call `web_enable`, and `web_search` (OpenAI search) appears on the next request. In `auto-research` you are the OpenAI-index seat; if neither tool exists, report that engine as missing.
