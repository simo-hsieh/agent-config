---
name: delegate
description: Runs delegated work in a Herdr tab on Claude Code, Pi, or agy, picking the tab from the Task map in models.md and rerouting when a subscription is out of quota. Use when HERDR_ENV=1 and work goes to `researcher` or `worker`, or a skill needs a seat from another model family (arena, interrogate, reflect, auto-research).
---

# Delegate through Herdr

Works from any harness; the session the user steers is the orchestrator. Check `test "${HERDR_ENV:-}" = 1` first; outside Herdr, do the work in the main session, or in Claude Code give larger tasks to its `researcher` or `worker` subagent. For Herdr CLI details beyond this page, run `herdr --skill`. Parse every ID from JSON output; never guess one.

## Pick a tab

Tabs are `<harness>-<tier>`: `claude-thinking`, `claude-fast`, `pi-thinking`, `pi-fast`, `agy-thinking`, `agy-fast`. Model and effort per tab come from the Role map in `~/.agents/src/models.md`; the tab for a task comes from its Task map row.

1. Find the task's row. Drop tabs whose harness is in the session's blocked list (below). When the orchestrator is not Claude Code, its own family's tab moves last in fast rows instead of `claude-fast`, because it spends the orchestrator's quota.
2. For equals (`=`), if `codexbar usage --format json` works, take the subscription with more quota left; otherwise the first.
3. If no tab is left: a fast row runs in the main session; a cross-family seat goes to any other family not blocked, and with none left the skill reports the seat as skipped (for example "not interrogated").

## Run a task

1. `herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label <tab> --no-focus`; keep `.result.tab.tab_id` and `.result.root_pane.pane_id`. Reuse a running tab of the same name only to keep expensive built state.
2. `herdr agent start <tab> --kind <claude|pi|agy> --pane <pane_id> -- <args>`, with `<model>` and `<effort>` from the Role map and `<contract>` the text under Contract:
   - Claude Code: `--model <model> --effort <effort> --permission-mode auto --name <tab> --settings ~/.agents/src/claude/delegate.json --append-system-prompt "<contract>"`
   - Pi: `--model <model>:<effort> --session-id <new uuid> --append-system-prompt "<contract>"`
   - agy: `--model <model> --effort <effort> --mode auto --settings ~/.agents/src/agy/delegate.json`; agy has no system-prompt flag, so `<contract>` is the brief's first paragraph.
3. `herdr agent prompt <tab> "<brief>" --wait --timeout 600000`. The brief is self-contained: goal, exact files, steps, done-when, the Task map row, the tab's harness, model, and effort (a delegate cannot always see its own), and a temp Markdown path for a long report. For research, add: send only sanitized public context.
4. Read the report. Pi: the last assistant message in `~/.pi/agent/sessions/--<cwd with / replaced by ->--/*_<uuid>.jsonl`. Claude Code and agy: `herdr agent read <tab> --source recent-unwrapped --lines 200`. With no status line, or a subagent still running, wait for it, then ask for the report.
5. On `blocked` or `agent_not_ready` (a trust, approval, or sign-in prompt), read the pane and ask the user before answering it; never add an auto-approve flag. A timeout or stall does not prove the prompt was lost; read before resending.
6. When the role has no more work, `herdr tab close <tab_id>` for each tab you created. Never close tabs you did not create.

## Quota

A harness out of quota often cannot produce a report. Treat the tab as quota-blocked when its report says `status: BLOCKED` for quota, or its pane shows a usage-limit, rate-limit, 429, or quota error. Then:

1. Close the tab and add the harness to the session's blocked list, with the reset time when the pane shows one. Skip it until that time; without one, skip it for the session.
2. Send the same brief to the next tab in the row (Pick a tab, step 1). Within an `auto-research` fan-out, do not reroute; the report names the missing engine.
3. Tell the user once which harness is blocked and where its work went.

When the orchestrator's own harness reports a usage limit, stop and tell the user to continue in another harness's session; this skill and `models.md` work the same from Pi or agy.

## Contract

"You are a delegate. Do not start Herdr agents or delegate to another harness. Do not push, merge, open PRs, or move bookmarks. Start your final reply with `status: DONE | BLOCKED | FAILED` (BLOCKED with the reason, `quota` when a usage limit stopped you), then lines `harness: <name> <model> <effort>` and `task: <Task map row>`, a 1-3 line summary, what changed or ran with exact commands and real output, and anything unexpected. Wait for your subagents and background tasks before the final reply. Write a long report to the path the brief gives."

agy runs single-agent: its `no-subagents` plugin blocks subagents, workflows, and swarms.

## Coordinate

- Send all independent tasks for a role in one brief and let Claude Code or Pi run them with their own subagents, giving parallel workers disjoint files; they share the working tree.
- After a task fails twice, retry it in a new tab `<tab>-retry` at the Role map's retry effort; if that fails, take it over in the main session.
- Treat a report as a claim: check the diff and rerun the decisive command before relying on it.
