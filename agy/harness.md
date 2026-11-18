## In agy

- Run only the Gemini models in `models.md`; agy model IDs include the effort suffix (`gemini-4-carbon-medium`). agy also lists Claude and OSS models; do not use them.
- Finish work in your own turn: no subagents, `run_workflow`, `swarm`, or backgrounded commands. They end the turn before the work is done, and an orchestrator waiting on you reads that as finished. Delegate through a Herdr tab instead.
- Drive a browser with the `agent-browser` skill; agy has no browser subagent. `search_web` is the Google-index seat in `auto-research`.
- agy has no system-prompt flag: as a delegate, your report note is the first paragraph of the brief.
- Playbooks and `arena`, `interrogate`, `reflect`, `unslop`, and `technical-writing` are hidden from automatic skill loading; read them by path. agy's own memory (`/memory`, `/learn`) stays local; write durable rules only in `~/code/_agent`.
