# Intent: multi-agent settings

Status: decided 2026-11-19, after the review on the Multi-Agent Decisions page (https://claude.ai/artifact/SHjBwcorhNLXDcbMCkWMDm). Decision numbers there are given as D#.

## Problem

Compared with pstack's poteto-mode, setup-pstack, and orchestrate, delegation here had no role-to-model map, no effort tiering, reused Pi agents across tasks, and capped work at one subagent. By 2026-11-18 the delegation rules themselves were the problem: with capable models, bans on subagents, nested delegation, and same-family checks, plus a benefit-versus-overhead gate, blocked useful work. Delegation should be communication between models, guided by patterns on how to work, with quality ahead of cost.

## Decisions

1. Any agent, a delegate included, may delegate. Guidance says how to work together, not when delegation is forbidden; quality comes before cost (D1).
2. Delegated work runs in a Herdr tab, so I can watch it and read its context in the pane, for example a research task. A native subagent is used only when no tab fits: its work is invisible to me, and delegating to one has lowered the quality of the work (D11 note).
3. The orchestrator, on the strongest model, designs and builds the main work itself, because it needs the context behind its decisions. It hands off whole tasks with a clear boundary and target, such as research, a codemod, or a test run, never reading on its own behalf to save context (D4, D6 notes).
4. When the work is ready, the orchestrator asks a model from another family to review its design, code quality, or security. `arena` and `interrogate` keep their cross-family seats (D6, D10).
5. Each concurrent writer works in its own git worktree and branch, and one integrator merges them (D2, `../git/design.md`).
6. No caps on depth, count, or concurrency, in policy or in Pi's subagent config; quota rerouting is the only bound (D3, D7).
7. The Task map in `models.md` is the default route. The orchestrator may pick another model when it has a reason, stated in the brief and the report, so the next review can update the map (D5).
8. Each harness has a thinking tier and a fast tier (`models.md`, Role map), starting at the tier's default effort; a task that fails twice is retried at the retry effort, then taken over by the orchestrator.
9. A fresh agent per task, in the task's outcome workspace. A finished tab stays open, marked done, until I close it. When open delegate tabs reach 10, the orchestrator sends related work to a finished agent or closes its oldest finished tabs, and asks before closing a workspace (2026-11-19).
10. A delegate's final reply carries `status:`, `harness:`, and `task:` lines and a handover; the rest is free (D9).
11. `long-run` frames an agent-written team plan (roles, models, agent count, each writer's worktree) and starts without waiting for approval unless I name a gate (D8).
12. `bin/model-usage` also counts Claude Code subagent runs, read from `~/.claude/projects/*/*/subagents/*.jsonl` (D11).

## Open questions

1. Whether pi-subagents applies its own depth, spawn, or parallelism defaults when `pi/subagents.json` sets none (UNVERIFIED; the package is not installed on this Mac).
2. A Pi-to-Claude seat through Herdr, end to end (UNVERIFIED; `herdr agent start --help` lists `claude`).
3. Whether `how` and `recall`, which split reading across delegate tabs, keep enough context in the orchestrator under decision 3.
