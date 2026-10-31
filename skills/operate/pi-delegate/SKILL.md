---
name: pi-delegate
description: Claude Code only. Runs GPT-family work in Pi, one Herdr tab per role, while the Claude session keeps orchestration, design, and review. Use when delegated `researcher` or `worker` work should run on GPT, or a skill needs a GPT seat (arena, interrogate, reflect), and HERDR_ENV=1.
---

# Pi delegation through Herdr

Claude orchestrates, designs, and reviews. Pi, on the model in its settings, does delegated work, each role in its own Herdr tab.

Check `test "${HERDR_ENV:-}" = 1` first; if it fails, or Pi reports a quota or rate-limit error, do small tasks in the main session and give larger ones to the Claude Code `researcher` or `worker` subagent. If Claude usage is also exhausted, stop and tell the user; the Gemini fallback is manual (README, Models). For Herdr CLI details beyond this page, run `herdr --skill`. Parse every ID from JSON output; never guess one.

## Run a task

1. Use one Pi per role, named `researcher`, `worker`, or the skill that needs it (`arena`, `interrogate`, `reflect`). If `herdr agent get <name>` succeeds, reuse it and skip to step 3. Otherwise `herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label <name> --no-focus`; keep `.result.tab.tab_id` and `.result.root_pane.pane_id`.
2. `herdr agent start <name> --kind pi --pane <pane_id>`.
3. `herdr agent prompt <name> "<task>" --wait --timeout 600000`. Make the prompt self-contained: goal, exact files, steps, done-when, and the report: first line `status: DONE | BLOCKED | FAILED`, a 1-3 line summary, then what changed or ran, exact commands with real output, anything unexpected. Tell Pi to wait for its subagents before replying and to write any long report itself to a Markdown file at a temp path you give; its `researcher` cannot write files. For research, tell Pi to use its `researcher` subagent and send only sanitized public context.
4. `herdr agent read <name> --source recent-unwrapped --lines 200`. If the reply has no status line or Pi still shows a running subagent, Pi answered early: wait for the subagent to finish, then ask Pi for the report.
5. On `blocked` or `agent_not_ready` (for example Pi's project-trust prompt), read the pane and ask the user before answering an approval. A timeout or stall does not prove the prompt was lost; read before resending.
6. When the role has no more work, `herdr tab close <tab_id>` for each tab you created. Never close tabs you did not create.

## Coordinate

- Send all independent tasks for a role in one prompt and tell Pi to run them in parallel with its own subagents, giving parallel workers disjoint files; they share the working tree.
- After a task fails twice, retry it in a new Pi named `<role>-xhigh`, started as in step 2 with `-- --thinking xhigh`; if it fails again, take the task over in the main session.
- Treat a Pi report as a claim: check the diff and rerun the decisive command before relying on it.
