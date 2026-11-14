---
name: delegate
description: Runs delegated work in a Herdr tab on Claude Code, Pi, or agy, picking the tab from models.md and rerouting when a subscription is out of quota. Use when HERDR_ENV=1 and work goes to researcher or worker, or a skill needs another model family (arena, interrogate, reflect, auto-research).
---

# Delegate through Herdr

The session the user steers is the orchestrator. Check `test "${HERDR_ENV:-}" = 1`; outside Herdr, work in the main session. Never use native subagents in any harness. A delegate never delegates again. For CLI details, run `herdr --skill`. Parse IDs from JSON output; never guess them.

## Pick a model

Logical roles are `claude-thinking`, `claude-fast`, `pi-thinking`, `pi-fast`, `agy-thinking`, and `agy-fast`. Read the Role map and Task map in `~/.agents/src/models.md` before each launch. Do not rely on remembered model IDs or harness defaults.

1. Find the task's row. Drop roles whose harness is quota-blocked for this session. In fast rows, move the orchestrator's family last, because it spends the orchestrator's quota. Keep `+` fan-outs and cross-family requirements intact.
2. For equals (`=`), use the subscription with more quota left in `codexbar usage --format json`, or the first when unavailable.
3. Resolve the role's exact model and effort. Check Pi IDs against `pi --list-models` and agy IDs against `agy models` before creating a tab. agy IDs include the effort suffix; when retrying, replace that suffix with the retry effort and verify the resulting ID. Claude uses the exact Role map ID. An unavailable model is `BLOCKED`; report it rather than silently substituting a model.
4. With no eligible role, do fast work in the main session. A cross-family seat needs another unblocked family; otherwise report it skipped (for example, "not interrogated").

## Run a task

1. Set a short, specific topic such as `Fix OAuth refresh race`, not `worker` or `pi-fast`. Choose a unique live agent name such as `pi-fast-oauth-a1`, matching `[a-z][a-z0-9_-]{0,31}`. Use the role for routing, the name for CLI targeting, and the topic for display. Check `herdr agent list` for collisions. Create a fresh tab per independent task; do not reuse another task's conversation.
2. `herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label "<topic> [<role>]" --no-focus`; retain `.result.tab.tab_id` and `.result.root_pane.pane_id`.
3. `herdr agent start <name> --kind <claude|pi|agy> --pane <pane_id> -- <args>`, with the verified model and effort and the Contract below:
   - Claude Code: `--model <model> --effort <effort> --name "<topic>" --settings ~/.agents/src/claude/delegate.json --disallowedTools Agent,Task,TeamCreate --append-system-prompt "<contract>"`
   - Pi: `--model <model>:<effort> --name "<topic>" --session-id <new uuid> --exclude-tools 'subagent*' --append-system-prompt "<contract>"`
   - agy: `--model <model> --effort <effort> --settings ~/.agents/src/agy/delegate.json`; the installed `no-subagents` plugin must be enabled. agy has no system-prompt flag, so put the Contract first in its brief.
4. `herdr agent prompt <name> "<brief>" --wait --timeout 600000`. Include the topic, goal, exact files, steps, done-when, Task map row, harness, model, and effort. For research, add: send only sanitized public context. Request a temp Markdown report only if terminal output cannot recover the answer.
5. Read the report. Pi: read the last assistant message in `~/.pi/agent/sessions/--<cwd with / replaced by ->--/*_<uuid>.jsonl`. Claude Code and agy: `herdr agent read <name> --source recent-unwrapped --lines 200`. Check the reported model and effort against the launch request. With no status line, inspect state and ask for the report; idle alone is not proof of completion.
6. On `blocked`, `agent_blocked`, or `agent_not_ready` (trust, approval, or sign-in), read the pane and ask the user before answering it. Never add an auto-approve flag. On a timeout or stall, read before resending; it does not prove the prompt was lost.
7. Leave finished delegate tabs open by default. When tabs accumulate and many delegates are idle, you may close tabs you created with `herdr tab close <tab_id>` after reading their reports and confirming they have no more work. Never close active delegates or tabs you did not create.

## Quota

A harness out of quota may not produce a report. Treat it as quota-blocked when its report says `status: BLOCKED` for quota, or the pane shows a usage-limit, rate-limit, 429, or quota error.

1. Leave the task's tab open and record the blocked harness and reset time. Without a reset time, skip it for this session.
2. Send the same brief in a fresh, topic-labeled tab for the next eligible role. Within an `auto-research` fan-out, do not reroute; name the missing engine.
3. Tell the user once which harness is blocked and where its work went.

When the orchestrator's own harness hits a usage limit, tell the user to continue in another harness's session.

## Contract

"You are a delegate. Work single-agent: do not use subagents, teams, workflows, swarms, Herdr agents, or another harness. Do not push, merge, open PRs, or move bookmarks. Start your final reply with `status: DONE | BLOCKED | FAILED` (BLOCKED with the reason, `quota` when a usage limit stopped you), then lines `topic: <task topic>`, `harness: <name> <model> <effort>`, and `task: <Task map row>`. Give a 1-3 line summary, what changed or ran with exact commands and real output, and anything unexpected. Wait for background commands before the final reply. Write a long report only when the brief gives a path."

## Coordinate

- Give concurrent delegates disjoint files; tabs in the same cwd share the working tree. Batch small tasks into one brief and run them sequentially in that tab.
- After two task failures, retry in a fresh topic-labeled tab at the Role map's retry effort. After another failure, take over in the main session. Approval dialogs and quota blocks are not task failures.
- Treat a report as a claim: check the diff and rerun the decisive command before relying on it.
