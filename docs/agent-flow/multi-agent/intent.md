# Intent: multi-agent settings

Status: draft; decisions below, role map awaiting approval.

## Problem

Compared with pstack's poteto-mode, setup-pstack, and orchestrate, delegation here has no role-to-model map, no effort tiering, reuses Pi agents across tasks, and caps work at one subagent.

## Decisions

1. One set of suggested model families per role, as a starting point: the delegating agent may pick another family when evidence (a benchmark, a past run, research) shows it does the role better, and a long task's agent may change it in its plan.
2. Either harness reaches the other family through Herdr: `herdr agent start --kind pi` from Claude Code, `--kind claude` from Pi.
3. A fresh agent per task; reuse only to keep expensive built state.
4. Each harness has a thinking tier and a fast tier, each a model and effort level (`models.md`, Role map). The delegating agent picks the tab from the task type (`models.md`, Task map) and starts at the tier's default effort; a task that fails twice is retried on the same model at `xhigh`, then taken over by the orchestrator (README, Models).
5. Several subagents are allowed when tasks are independent and touch disjoint files.
6. `long-run` starts with an agent-written team plan: roles, model and effort per role, agent count, and file ownership.

## Open questions

1. Resolved: the role map and task map live in `models.md`; harness and agent config keep only their own defaults.
2. The cap on concurrent subagents (`docs/agent-flow/harnesses/intent.md`, open question 2).
3. Whether the user approves a `long-run` team plan before work starts.
4. A Pi-to-Claude seat through Herdr, end to end (UNVERIFIED; `herdr agent start --help` lists `claude`).
