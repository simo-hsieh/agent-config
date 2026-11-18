---
name: delegate
description: Runs delegated work in a Herdr tab on Claude Code, Pi, or agy, picking the tab from models.md and rerouting when a subscription is out of quota. Use when HERDR_ENV=1 and work should go to another harness or model family (arena, interrogate, reflect, auto-research), or when several agents write code at once.
---

# Delegate through Herdr

Delegation is a conversation between models. Delegate in a Herdr tab, so the user can watch and read the work in its pane; the harness section of your instructions says when a native subagent fits instead. Any agent may delegate, including a delegate. Hand off whole tasks with a clear boundary and target, such as research, a codemod, or a test run; the orchestrator keeps the design and main work, and the context behind them. For CLI details, run `herdr --skill`. Parse IDs from JSON output; never guess them.

## Pick a model

Logical roles are `claude-thinking`, `claude-fast`, `pi-thinking`, `pi-fast`, `agy-thinking`, and `agy-fast`. Read the Role map and Task map in `~/.agents/src/models.md` before each launch rather than relying on remembered model IDs or harness defaults.

1. Find the task's row. It is the default: pick another model when you have a reason, and state it in the brief and the report. Drop roles whose harness is quota-blocked for this session. Keep `+` fan-outs and cross-family requirements intact.
2. For equals (`=`), use the subscription with more quota left in `codexbar usage --format json`, or the first when unavailable.
3. Resolve the role's exact model and effort. Check Pi IDs against `pi --list-models` and agy IDs against `agy models`. agy IDs include the effort suffix; when retrying, replace that suffix with the retry effort and verify the resulting ID. Claude uses the exact Role map ID. If a model is unavailable, report it rather than silently substituting.
4. A cross-family seat needs another unblocked family; otherwise report it skipped (for example, "not interrogated").

## Choose a workspace

- Group substantial work by one coherent outcome, such as `Fix OAuth refresh race`, not by model or role. Keep small side questions in the current workspace.
- Run `herdr workspace list` and `herdr tab list --workspace <id>`. Reuse a workspace for the same outcome; a matching label alone does not prove it is the same outcome. For a different substantial outcome, run `herdr workspace create --cwd "<task cwd>" --label "<outcome>" --no-focus` and retain `.result.workspace.workspace_id`, `.result.tab.tab_id`, and `.result.root_pane.pane_id`. Do not rename or repurpose unrelated workspaces.
- Start a fresh agent for each new task. A follow-up on a task, such as a re-review, a clarification, or a fix to its own work, goes to the agent that did it, even after it finished; start fresh from its handover only when its conversation has drifted.

## Run a task

1. Set a short topic and a unique live name such as `pi-fast-oauth-a1`, matching `[a-z][a-z0-9_-]{0,31}`; check `herdr agent list` for collisions.
2. Use the new workspace's shell pane, or `herdr tab create --workspace "<id>" --cwd "<task cwd>" --label "<topic> [<role>]" --no-focus`, retaining the tab and root pane IDs. When using a workspace's root tab, run `herdr tab rename <tab_id> "<topic> [<role>]"`.
3. Run `herdr agent start <name> --kind <claude|pi|agy> --pane <pane_id> -- <args>`:
   - Claude Code: `--model <model> --effort <effort> --name "<topic>" --settings ~/.agents/src/claude/delegate.json --append-system-prompt "<report note>"`
   - Pi: `--model <model>:<effort> --name "<topic>" --session-id <new uuid> --append-system-prompt "<report note>"`
   - agy: `--model <model> --effort <effort> --settings ~/.agents/src/agy/delegate.json`; agy has no system-prompt flag, so put the report note first in the brief.
4. `herdr agent prompt <name> "<brief>" --wait --timeout 600000`. Write the brief as you would for a capable colleague: goal, context and what you already know, relevant files, done-when, and which paths it may change. For research, say to send only sanitized public context.
5. Read the reply. Pi: run `herdr agent get <name>` and read the last assistant message from its live `agent_session.value` when `agent_session.kind` is `path`. Claude Code and agy: `herdr agent read <name> --source recent-unwrapped --lines 200`; for agy, the full reply is also in `~/.gemini/antigravity-cli/brain/<conversation id>/.system_generated/logs/transcript_full.jsonl`. An idle tab is not a finished one: a delegate running its own subagents (agy especially) can go idle mid-task, so wait for the `status:` line.
6. On `blocked`, `agent_blocked`, or `agent_not_ready` (trust, approval, or sign-in), read the pane and ask the user before answering it; never add an auto-approve flag. On a timeout or stall, read before resending.
7. When the reply has a handover and no commands are still running, rename the tab `<topic> [<role>] done` and leave it open in its outcome workspace, so the user can read the work; the user closes it.
8. When a task's work is done (its delegates have handed over and you have integrated the results), offer to close that task's workspace. If open delegate tabs across workspaces (`herdr agent list`) reach 15 first, close the oldest finished tabs you created with `herdr tab close <tab_id>`. Never close tabs you did not create; ask before closing a workspace.

## Report note

"Start your final reply with `status: DONE | BLOCKED | FAILED` (BLOCKED with the reason, `quota` for a usage limit), then `harness: <name> <model> <effort>` and `task: <Task map row>`. Say what you changed or ran, with real output, and anything unexpected. Finish background commands you started before replying. End with a `handover:` a fresh agent could continue from: changed paths, state left behind, open questions, and the next step. Commit only on your own branch. Do not push, merge, open PRs, or move other branches."

## Quota

Treat a harness as quota-blocked when its reply says `status: BLOCKED` for quota, or the pane shows a usage-limit, rate-limit, 429, or quota error. Record the reset time if shown, collect any partial work, rename the tab `<topic> [<role>] quota`, and send the same brief plus partial work to the next role in the row. Within an `auto-research` fan-out, do not reroute; name the missing engine. Tell the user once which harness is blocked and where its work went.

Quota is nearly used up for a harness that hit a usage limit this session, or whose subscription shows under 20% left in `codexbar usage --format json` where that command exists. Then run design input and reviews with fewer seats, keeping at least one other family, and say which seats were dropped. When the orchestrator's own harness hits a limit, tell the user to continue in another harness's session.

## Several writers at once

Two agents editing one checkout overwrite each other's work, so each writer gets its own git worktree:

- Name one integrator. Stage shared interfaces on the base first. For each writer, run `git worktree add <path> -b <topic> <base>` and use that path as the writer's task cwd.
- The integrator owns shared files, lockfiles, repo-wide formatting or codegen, and integrated tests. When a writer's reply has its handover and its background commands have finished (an idle tab alone does not show that), the integrator reviews its branch, merges or cherry-picks it, and runs the tests together.
- Each worktree needs its own dependency install and build. Give parallel app drivers separate ports, profiles, and output files.
- Read-only git commands are fine at any time. Remove a worktree once its branch is merged, reading the path from `git worktree list`; show the diff and ask before removing one with uncommitted work.

## Failures

After two failures on a task, retry in a fresh tab at the Role map's retry effort; after another, take it over yourself. Approval dialogs and quota blocks are not task failures.
