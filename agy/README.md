# Antigravity adapter

`./install.sh agy` links `shared/AGENTS.md` followed by `agy/harness.md` as `~/.gemini/config/AGENTS.md`, and the skills, into `~/.gemini/config/`, leaving `~/.gemini/config/hooks.json` (Herdr's hook) and `~/.gemini/antigravity-cli/settings.json` untouched. Check with `./install.sh --dry-run agy`, then start a new `agy` session.

- **Delegate tabs** start with `--settings ~/.agents/src/agy/delegate.json`, which denies `git push`, `git merge`, `git branch -f`, `gh pr create`, and `gh pr merge`. agy has no system-prompt flag, so the report note goes first in the brief.
- **Subagents** (`self`, `research`, `image-generator`), `run_workflow`, `swarm`, and backgrounded commands let a turn go idle before the work finishes, and Herdr can report the pane idle mid-command. `agy/harness.md` forbids them; an orchestrator still waits for the `status:` line, never an idle tab.
- **Machine-local settings** (`~/.gemini/antigravity-cli/settings.json`, rewritten by agy): default model Gemini 4 Carbon (Medium), the `models.md` thinking tier; `toolPermission: always-proceed`, so interactive agy auto-approves commands not denied, and `git push` and `gh pr merge` are denied there too. Plan mode asks before every command and stalls delegate tabs.
- **Transcripts** are JSONL at `~/.gemini/antigravity-cli/brain/<conversation-id>/.system_generated/logs/transcript_full.jsonl`; `herdr agent get <name>` shows the conversation ID.
- **Models**: `agy models` also lists Claude and OSS models against the Google quota; routing uses only the Gemini IDs, which include the effort suffix.
