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

## Choose a workspace and conversation

- Group substantial work by one coherent outcome, such as `Fix OAuth refresh race`, not by model or role. An outcome may span repositories and worktrees. Keep small side questions in the current workspace.
- Run `herdr workspace list`, `herdr tab list --workspace <id>`, and `herdr agent list`; inspect candidate agents' topics and reports. Reuse a workspace for the same outcome; a matching label alone does not prove ownership or relevance. If the current workspace is a repository catch-all rather than this outcome's workspace, create a named outcome workspace for substantial work. For a different substantial outcome, run `herdr workspace create --cwd "<task cwd>" --label "<outcome>" --no-focus`. Retain `.result.workspace.workspace_id`, `.result.tab.tab_id`, and `.result.root_pane.pane_id`; the new workspace already has a shell pane. Do not rename or repurpose unrelated workspaces.
- Continue a conversation only when the next task depends on its findings. For an independent subtask, use a fresh conversation in a compatible idle tab or start a fresh agent. Before resetting, collect its report and confirm no commands or pending work remain. Discover the installed harness's reset command, verify that history was cleared and the delegate contract still applies, and send a self-contained brief. If reset behavior is uncertain, start a fresh agent instead. Use compaction only to continue a long task, not to clean between tasks.
- Reuse only agents created for this outcome or explicitly assigned to it by the user. Before reusing an agent, verify its actual cwd, model, effort, delegate restrictions, and relevant file state. After repository, branch, or configuration changes, check for stale reads and loaded instructions or tools; reset or restart when needed. Do not reuse a tab merely because Herdr reports it idle.
- Workspaces do not share model context or isolate files. Do not assume a kept tab guarantees a cache hit or lower cost.

## Run a task

1. Choose the outcome workspace and task cwd above. Set a short subtask topic and, for a new agent, a unique live name such as `pi-fast-oauth-a1`, matching `[a-z][a-z0-9_-]{0,31}`. Check `herdr agent list` for collisions. Use the role for routing, the name for CLI targeting, and the topic for display.
2. For a fresh agent, use the new workspace's shell pane or create a tab with `herdr tab create --workspace "<outcome workspace id>" --cwd "<task cwd>" --label "<topic> [<role>]" --no-focus`. Retain `.result.tab.tab_id` and `.result.root_pane.pane_id`. For a verified reusable agent, skip creation and startup. When using a workspace's root tab or reusing a tab, run `herdr tab rename <tab_id> "<topic> [<role>]"`. Keep using the live agent name for CLI targeting; the brief and tab label identify its current task.
3. For a fresh agent, run `herdr agent start <name> --kind <claude|pi|agy> --pane <pane_id> -- <args>`, with the verified model and effort and the Contract below:
   - Claude Code: `--model <model> --effort <effort> --name "<topic>" --settings ~/.agents/src/claude/delegate.json --disallowedTools Agent,Task,TeamCreate --append-system-prompt "<contract>"`
   - Pi: `--model <model>:<effort> --name "<topic>" --session-id <new uuid> --exclude-tools 'subagent*' --append-system-prompt "<contract>"`
   - agy: `--model <model> --effort <effort> --settings ~/.agents/src/agy/delegate.json`; the installed `no-subagents` plugin must be enabled. agy has no system-prompt flag, so put the Contract first in its brief.
4. `herdr agent prompt <name> "<brief>" --wait --timeout 600000`. Include the topic, goal, exact files, steps, done-when, Task map row, harness, model, and effort. For research, add: send only sanitized public context. Request a temp Markdown report only if terminal output cannot recover the answer.
5. Read the report. Pi: run `herdr agent get <name>` and read the last assistant message from its live `agent_session.value` when `agent_session.kind` is `path`; do not reuse a launch UUID after resetting. If no live session path is available, inspect the pane and request the report rather than guessing a file. Claude Code and agy: `herdr agent read <name> --source recent-unwrapped --lines 200`. Check the reported model and effort against the launch request. With no status line, inspect state and ask for the report; idle alone is not proof of completion.
6. On `blocked`, `agent_blocked`, or `agent_not_ready` (trust, approval, or sign-in), read the pane and ask the user before answering it. Never add an auto-approve flag. On a timeout or stall, read before resending; it does not prove the prompt was lost.
7. Leave finished delegate tabs open by default. When tabs accumulate and many delegates are idle, you may close tabs you created with `herdr tab close <tab_id>` after collecting their reports and confirming no commands or pending work remain. Preserve any results needed for handoff before closing. Track created tab IDs in the task handoff; if ownership is unknown, leave the tab open. Never close active delegates or tabs you did not create; ask before closing a workspace.

## Quota

A harness out of quota may not produce a report. Treat it as quota-blocked when its report says `status: BLOCKED` for quota, or the pane shows a usage-limit, rate-limit, 429, or quota error.

1. Leave the task's tab open and record the blocked harness and reset time. Without a reset time, skip it for this session.
2. Send the same brief to the next eligible role in the same outcome workspace, using the reuse checks above or a fresh topic-labeled tab. Within an `auto-research` fan-out, do not reroute; name the missing engine.
3. Tell the user once which harness is blocked and where its work went.

When the orchestrator's own harness hits a usage limit, tell the user to continue in another harness's session.

## Contract

"You are a delegate. Work single-agent: do not use subagents, teams, workflows, swarms, Herdr agents, or another harness. Do not push, merge, open PRs, or move bookmarks. Start your final reply with `status: DONE | BLOCKED | FAILED` (BLOCKED with the reason, `quota` when a usage limit stopped you), then lines `topic: <task topic>`, `harness: <name> <model> <effort>`, and `task: <Task map row>`. Give a 1-3 line summary, what changed or ran with exact commands and real output, and anything unexpected. Wait for background commands before the final reply. Write a long report only when the brief gives a path."

## Coordinate

- Serialize overlapping edits or use separate jj workspaces or Git worktrees for independent writers. Concurrent writers in one cwd must have explicitly coordinated disjoint files, including shared lockfiles and generated artifacts. Herdr workspaces do not isolate these files. Batch related small tasks into one brief and run them sequentially in that tab.
- After two task failures, retry in a fresh topic-labeled tab at the Role map's retry effort. After another failure, take over in the main session. Approval dialogs and quota blocks are not task failures.
- Treat a report as a claim: check the diff and rerun the decisive command before relying on it.
