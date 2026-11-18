---
name: delegate
description: Runs delegated work in a Herdr tab on Claude Code, Pi, or agy, picking the tab from models.md and rerouting when a subscription is out of quota. Use when HERDR_ENV=1 and work should go to another harness or model family (arena, interrogate, reflect, auto-research), or when several agents will write in one checkout.
---

# Delegate through Herdr

Delegation is a conversation between models. Herdr tabs reach another harness or model family; native subagents are fine for work the current harness's models do well. Any agent may delegate, including a delegate. For CLI details, run `herdr --skill`. Parse IDs from JSON output; never guess them.

## Pick a model

Logical roles are `claude-thinking`, `claude-fast`, `pi-thinking`, `pi-fast`, `agy-thinking`, and `agy-fast`. Read the Role map and Task map in `~/.agents/src/models.md` before each launch rather than relying on remembered model IDs or harness defaults.

1. Find the task's row and drop roles whose harness is quota-blocked for this session. Keep `+` fan-outs and cross-family requirements intact.
2. For equals (`=`), use the subscription with more quota left in `codexbar usage --format json`, or the first when unavailable.
3. Resolve the role's exact model and effort. Check Pi IDs against `pi --list-models` and agy IDs against `agy models`. agy IDs include the effort suffix; when retrying, replace that suffix with the retry effort and verify the resulting ID. Claude uses the exact Role map ID. If a model is unavailable, report it rather than silently substituting.
4. A cross-family seat needs another unblocked family; otherwise report it skipped (for example, "not interrogated").

## Choose a workspace

- Group substantial work by one coherent outcome, such as `Fix OAuth refresh race`, not by model or role. Keep small side questions in the current workspace.
- Run `herdr workspace list` and `herdr tab list --workspace <id>`. Reuse a workspace for the same outcome; a matching label alone does not prove it is the same outcome. For a different substantial outcome, run `herdr workspace create --cwd "<task cwd>" --label "<outcome>" --no-focus` and retain `.result.workspace.workspace_id`, `.result.tab.tab_id`, and `.result.root_pane.pane_id`. Do not rename or repurpose unrelated workspaces.
- Start a fresh agent per task. Send a follow-up to a live agent when it depends on that agent's conversation, such as a clarification or a fix to its own work; otherwise close its tab and pass its handover into the next brief.

## Run a task

1. Set a short topic and a unique live name such as `pi-fast-oauth-a1`, matching `[a-z][a-z0-9_-]{0,31}`; check `herdr agent list` for collisions.
2. Use the new workspace's shell pane, or `herdr tab create --workspace "<id>" --cwd "<task cwd>" --label "<topic> [<role>]" --no-focus`, retaining the tab and root pane IDs. When using a workspace's root tab, run `herdr tab rename <tab_id> "<topic> [<role>]"`.
3. Run `herdr agent start <name> --kind <claude|pi|agy> --pane <pane_id> -- <args>`:
   - Claude Code: `--model <model> --effort <effort> --name "<topic>" --settings ~/.agents/src/claude/delegate.json --append-system-prompt "<report note>"`
   - Pi: `--model <model>:<effort> --name "<topic>" --session-id <new uuid> --append-system-prompt "<report note>"`
   - agy: `--model <model> --effort <effort> --settings ~/.agents/src/agy/delegate.json`; agy has no system-prompt flag, so put the report note first in the brief.
4. `herdr agent prompt <name> "<brief>" --wait --timeout 600000`. Write the brief as you would for a capable colleague: goal, context and what you already know, relevant files, done-when, and which paths it may change. For research, say to send only sanitized public context.
5. Read the reply. Pi: run `herdr agent get <name>` and read the last assistant message from its live `agent_session.value` when `agent_session.kind` is `path`. Claude Code and agy: `herdr agent read <name> --source recent-unwrapped --lines 200`. An idle tab is not a finished one: a delegate running its own subagents (agy especially) can go idle mid-task, so wait for the `status:` line.
6. On `blocked`, `agent_blocked`, or `agent_not_ready` (trust, approval, or sign-in), read the pane and ask the user before answering it; never add an auto-approve flag. On a timeout or stall, read before resending.
7. Once the work is done and the reply has a handover, close each tab you created with `herdr tab close <tab_id>`. Never close tabs you did not create; ask before closing a workspace.

## Report note

"Start your final reply with `status: DONE | BLOCKED | FAILED` (BLOCKED with the reason, `quota` for a usage limit), then `harness: <name> <model> <effort>` and `task: <Task map row>`. Say what you changed or ran, with real output, and anything unexpected. Finish background commands you started before replying. End with a `handover:` a fresh agent could continue from: changed paths, state left behind, open questions, and the next step. Do not push, merge, open PRs, or move bookmarks."

## Quota

Treat a harness as quota-blocked when its reply says `status: BLOCKED` for quota, or the pane shows a usage-limit, rate-limit, 429, or quota error. Record the reset time if shown, collect any partial work, close the tab, and send the same brief plus partial work to the next role in the row. Within an `auto-research` fan-out, do not reroute; name the missing engine. Tell the user once which harness is blocked and where its work went. When the orchestrator's own harness hits a limit, tell the user to continue in another harness's session.

## Several writers in one checkout

Two agents editing the same file corrupt each other's work, and a jj command snapshots everyone's half-done edits. When agents write concurrently:

- Name one integrator. Give each writer its own whole files or subtrees and say in the brief which paths are its own and that the rest belong to others. Stage shared interfaces before the writers start.
- Until every writer has stopped, nobody runs jj, Git mutations, or repo-wide formatting or codegen; the integrator owns shared files, lockfiles, history, and integrated tests. Readers share the checkout too, so tell them.
- The barrier closes when every writer has replied and its background commands have finished; Herdr `--wait` or an idle tab alone does not show that. Then the integrator reviews the diffs, resolves shared changes, and runs the tests together.
- On unexpected overlap, stop the affected writers, keep their edits, and reassign or serialize; never revert someone else's work.
- Give parallel app drivers separate runtime resources: app state, profiles, ports, and output files.

## Failures

After two failures on a task, retry in a fresh tab at the Role map's retry effort; after another, take it over yourself. Approval dialogs and quota blocks are not task failures.
