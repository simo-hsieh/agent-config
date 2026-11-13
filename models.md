# Models

Reference for which model and effort each delegate tab runs. This is the only file that names model IDs for delegation; the `delegate` skill (`skills/operate/delegate/SKILL.md`), README, and design docs link here. Last reviewed: 2026-11-13.

## Role map

| Harness | Tier | Model | Default effort | Retry after two failures | Basis |
|---|---|---|---|---|---|
| Claude Code | thinking | `claude-opus-5-5` | `medium` | `xhigh` | README rule; no index score recorded |
| Claude Code | fast | `claude-sonnet-5-5` | `low` | `xhigh` | index score at `high` only |
| Pi | thinking | `openai-codex/gpt-6.1-sol` | `medium` | `xhigh` | index score |
| Pi | fast | `openai-codex/gpt-6.1-terra` | `low` | `xhigh` | guess from model name |
| agy | thinking | `gemini-4-carbon` | `medium` | `high` (no `xhigh` variant) | index score at `high` only |
| agy | fast | `gemini-4-hydrogen` | `low` | `xhigh` | assumed equal to Sonnet 5.5 and Sol (user, 2026-11-14); no index score found |

Start every task at the default effort. After two failures, retry on the same model at the retry effort in a new tab; after that, the orchestrator takes the task over.

## Task map

Which tab takes which kind of task (harnesses design, R7). The orchestrator finds the task's row and sends it to the first tab in the order. Tabs joined by `=` are equals: send to the one whose subscription has more quota left in `codexbar usage --format json`, or to the first if CodexBar is unavailable. On a quota `BLOCKED`, or a usage-limit error in the tab's pane, mark the harness blocked for the session and move to the next tab in the row (R6); with no tab left, the orchestrator does the task itself. `claude-fast` comes last in fast rows because it spends the orchestrator's quota. Tabs joined by `+` all get the same question at once, and the orchestrator merges their answers (harnesses design, R8).

| Task type | Tier | Order | Basis |
|---|---|---|---|
| Design, hard bugs, final review | thinking | orchestrator itself | README, Models |
| `arena`, `interrogate`, `reflect` seats | thinking | one seat per family other than the orchestrator's | R5 |
| UI and frontend | thinking | `pi-thinking` = `agy-thinking` | unmeasured; plan step 5 decides |
| Web research, one lookup | fast | `pi-fast` = `agy-fast`, then `claude-fast` | Hydrogen assumed equal to Sol |
| Web research, several sources (`auto-research`) | fast | `pi-fast` + `agy-fast` + `claude-fast`, in parallel | each harness searches a different engine: Claude Code uses Brave, Pi uses OpenAI search through the ChatGPT subscription, agy uses Google |
| Code search with a summary | fast | `pi-fast` = `agy-fast`, then `claude-fast` | Hydrogen assumed equal to Sol |
| Well-specified edits, codemods | fast | `pi-fast` = `agy-fast`, then `claude-fast` | Sonnet 5.5 `high` scores below Sol `medium` at a higher cost; Hydrogen assumed equal to Sol |
| Test runs, repros, benchmarks | fast | `pi-fast` = `agy-fast`, then `claude-fast` | Hydrogen assumed equal to Sol |

A row's order changes only through the Review procedure: a model leads a row when it beats the others on that task type over at least 10 runs, or wins an `arena` run on a real task of that type.

## Evidence

Benchmark: Artificial Analysis Coding Agent Index, October 2026, from the README; the Carbon row is from Artificial Analysis's Carbon launch article, 2026-10-28.

| Model and effort | Score | Cost per task | Minutes per task |
|---|---|---|---|
| Gemini 4 Argon | 64 | $5.84 | 35 |
| Gemini 4 Carbon `high`, in agy | 59 | $7.74 | 30 |
| Sonnet 5.5 `xhigh` | 63 | $3.33 | 27 |
| GPT-6.1 Sol `medium` | 61 | $0.70 | 11 |
| Sonnet 5.5 `high` | 55 | $1.24 | 12 |
| GPT-5.6 Sol `max` | 55 | $6.35 | not recorded |
| Haiku 5.5 | 41 or less | not recorded | not recorded |

Real use: not yet measured. Record runs, DONE rate, median minutes, and tokens per completed task per model and effort here after each review.

## Model IDs pinned in config

Harnesses read these files directly, so they keep their own IDs. Change them in the same topic as the role map.

- `claude/agents/worker.md` and `claude/agents/researcher.md`: `model: sonnet`
- `pi/settings.json`: `defaultModel`, `defaultThinkingLevel`, and `subagents.modelScope.allow`; subagents inherit the tab's model (`subagents.defaultModel` unset, `pi/agents/researcher.md` has `model: inherit`)

## Review

Review when `pi --list-models`, `agy models`, or a Claude release adds a model, or once a month.

1. Refresh the benchmark table through `researcher`, with the source and date.
2. Collect real-use numbers per model and effort from local session logs with `bin/model-usage`, which reads:
   - Claude Code: `~/.claude/projects/*/*.jsonl`, `message.model` and `message.usage` per assistant turn.
   - Pi: `~/.pi/agent/sessions/*/*.jsonl`, `model`, `thinkingLevel`, `usage`, `durationMs`, `stopReason` per assistant message.
   - agy: `~/.gemini/antigravity-cli/conversations/*.db`; its `gen_metadata` and `steps` columns are protobuf blobs with no published schema, so the script only counts them; take agy outcomes from the reports the orchestrator read.
   - Outcome and task type: the `status:` and `task:` lines of each delegate report in those logs.
3. Reorder Task map rows from the per-task-type numbers. Replace a model when the candidate scores at least as high at no more cost per completed task on the benchmark, and its real-use DONE rate is no lower over at least 10 runs. When the benchmark and real use disagree, trial both in `arena` on one real task.
4. Update this file and the pinned config files in one topic, with the evidence in the description, and set "Last reviewed".
