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

## Choose a workspace

- Group substantial work by one coherent outcome, such as `Fix OAuth refresh race`, not by model or role. An outcome may span repositories and worktrees. Keep small side questions in the current workspace.
- Run `herdr workspace list` and `herdr tab list --workspace <id>`. Reuse a workspace for the same outcome; a matching label alone does not prove ownership or relevance. If the current workspace is a repository catch-all rather than this outcome's workspace, create a named outcome workspace for substantial work. For a different substantial outcome, run `herdr workspace create --cwd "<task cwd>" --label "<outcome>" --no-focus`. Retain `.result.workspace.workspace_id`, `.result.tab.tab_id`, and `.result.root_pane.pane_id`; the new workspace already has a shell pane. Do not rename or repurpose unrelated workspaces.
- Start a fresh agent for each task. Send a follow-up to a live agent only right after reading its report, when the follow-up depends on that conversation, such as a clarification or a fix to its own work. Otherwise close its tab and pass its handover into the next brief. Never reset or reuse an idle tab for a new task: every open tab is one more agent to trace.
- Workspaces do not share model context or isolate files.

## Run a task

1. Choose the outcome workspace and task cwd above. Set a short subtask topic and a unique live name such as `pi-fast-oauth-a1`, matching `[a-z][a-z0-9_-]{0,31}`. Check `herdr agent list` for collisions. Use the role for routing, the name for CLI targeting, and the topic for display.
2. Use the new workspace's shell pane or create a tab with `herdr tab create --workspace "<outcome workspace id>" --cwd "<task cwd>" --label "<topic> [<role>]" --no-focus`. Retain `.result.tab.tab_id` and `.result.root_pane.pane_id`. When using a workspace's root tab, run `herdr tab rename <tab_id> "<topic> [<role>]"`.
3. Run `herdr agent start <name> --kind <claude|pi|agy> --pane <pane_id> -- <args>`, with the verified model and effort and the Contract below:
   - Claude Code: `--model <model> --effort <effort> --name "<topic>" --settings ~/.agents/src/claude/delegate.json --disallowedTools Agent,Task,TeamCreate --append-system-prompt "<contract>"`
   - Pi: `--model <model>:<effort> --name "<topic>" --session-id <new uuid> --exclude-tools 'subagent*' --append-system-prompt "<contract>"`
   - agy: `--model <model> --effort <effort> --settings ~/.agents/src/agy/delegate.json`; the installed `no-subagents` plugin must be enabled. agy has no system-prompt flag, so put the Contract first in its brief.
4. `herdr agent prompt <name> "<brief>" --wait --timeout 600000`. Include the topic, goal, exact files, steps, done-when, Task map row, harness, model, and effort. For implementation, name the integrator, explicit writable whole files/subtrees and forbidden paths (everything else is forbidden), staged shared interfaces, allowed commands/tests, and any assigned runtime resources. Source-read-only briefs allow no source writes; list any requested report file as an explicit writable path. State whether a shared-checkout write wave is active and include its barrier rules, including no jj commands for any delegates until the integrator confirms the barrier complete. For research, add: send only sanitized public context. Request a temp Markdown report only if terminal output cannot recover the answer.
5. Read the report. Pi: run `herdr agent get <name>` and read the last assistant message from its live `agent_session.value` when `agent_session.kind` is `path`. If no live session path is available, inspect the pane and request the report rather than guessing a file. Claude Code and agy: `herdr agent read <name> --source recent-unwrapped --lines 200`. Check the reported model and effort against the launch request. With no status line, inspect state and ask for the report; idle alone is not proof of completion.
6. On `blocked`, `agent_blocked`, or `agent_not_ready` (trust, approval, or sign-in), read the pane and ask the user before answering it. Never add an auto-approve flag. On a timeout or stall, read before resending; it does not prove the prompt was lost.
7. Close each tab you created once its work is done. First confirm the report has a `handover:` section and no commands or background work remain. Keep the handover in your context, or in the task's handoff file for long work. Then run `herdr tab close <tab_id>`. Keep a tab open only while its agent is working, waiting on the user, or about to get a dependent follow-up. Never close tabs you did not create; ask before closing a workspace.

## Quota

A harness out of quota may not produce a report. Treat it as quota-blocked when its report says `status: BLOCKED` for quota, or the pane shows a usage-limit, rate-limit, 429, or quota error.

1. Read the pane, record the blocked harness and reset time, and collect any partial work, then close the tab. Without a reset time, skip the harness for this session.
2. Send the same brief, plus any partial work, to the next eligible role in a fresh topic-labeled tab in the same outcome workspace. Within an `auto-research` fan-out, do not reroute; name the missing engine.
3. Tell the user once which harness is blocked and where its work went.

When the orchestrator's own harness hits a usage limit, tell the user to continue in another harness's session.

## Contract

"You are a delegate. Work single-agent: do not use subagents, teams, workflows, swarms, Herdr agents, or another harness. Edit only the brief's writable paths; everything else is forbidden. If none are assigned, work read-only. When the brief declares a shared-checkout write wave, do not run jj (even read-only), Git mutations, or broad mutating commands from launch until the integrator confirms the barrier complete; this also applies to readers. The integrator owns shared files, manifests/lockfiles, repo-wide formatting/codegen, snapshots, history, and integrated tests. Run only assigned tests whose inputs and output resources are independent. If ownership overlaps or a needed change is outside your paths, stop affected work, preserve edits, and report it; never revert another writer. Use only assigned runtime resources; one live driver per shared app instance. Do not push, merge, open PRs, or move bookmarks. Start your final reply with `status: DONE | BLOCKED | FAILED` (BLOCKED with the reason, `quota` when a usage limit stopped you), then lines `topic: <task topic>`, `harness: <name> <model> <effort>`, and `task: <Task map row>`. Give a 1-3 line summary, what changed or ran with exact commands and real output, and anything unexpected. Before the final reply, stop writing, wait for all background mutating commands you started, and report their completion or any unresolved activity. End with a `handover:` section that lets a fresh agent continue without this conversation: changed paths, shared changes needed from the integrator, state left behind (processes, temp files, ports), open questions, and the next step. Write a long report only when the brief gives a path."

## Coordinate

- Choose delegation by benefit versus overhead, not task size. No committee is required for ordinary tasks. Batch related small tasks into one brief when that reduces coordination.
- Before a write wave, name one integrator, stage shared interfaces, and assign genuinely independent whole files or subtrees with explicit writable and forbidden paths. Before launching writers, wait for existing delegates in the checkout to finish or obtain their acknowledgment of the wave restrictions, including readers. The wave starts when the integrator launches its assigned writers and ends only when it confirms the barrier complete; briefs declare participation, including for readers. Workers may share one checkout; a separate jj workspace per worker is not required. Ownership is a cooperative convention, not enforced locking or isolation. Herdr outcome workspaces remain navigation groups.
- During the wave, implementation delegates edit only their assigned paths. All delegates, including readers, run no jj commands, Git mutations, or broad mutating commands. The integrator owns snapshots/history, shared files, manifests/lockfiles, repo-wide formatting/codegen, and integrated tests, but avoids competing edits and history operations until the barrier. Worker tests are allowed only when their inputs and output resources are independent; otherwise defer them.
- At the barrier, confirm every writer has stopped and every background mutating command has finished. Read reports and check unresolved command activity; Herdr `--wait` or an idle/done state alone is not proof. For missing reports, timeouts, or quota blocks, inspect the pane and tracked commands. Missing completion evidence or unresolved activity keeps the barrier closed; if completion cannot be established, ask the user rather than starting integration. Then the integrator reviews diffs, resolves shared changes, formats/generates/tests together, and organizes coherent jj topics.
- On unexpected ownership overlap, stop affected writers, preserve their edits, and reassign or serialize. Never auto-revert someone else's work. Readers may run in parallel, but findings can reflect unfinished or stale state; revalidate relevant claims at integration.
- Allow only one live driver per shared app instance. Parallel drives require genuinely separate runtime resources, including app state, profiles, ports, and output files.
- After two task failures, retry in a fresh topic-labeled tab at the Role map's retry effort. After another failure, take over in the main session. Approval dialogs and quota blocks are not task failures.
- Treat a report as a claim: check the diff and rerun the decisive command before relying on it.
