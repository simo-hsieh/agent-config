---
name: ship
description: Playbook for turning finished jj topics into pull requests and landing them. Routed from AGENTS.md or forced with /ship.
disable-model-invocation: true
---

# Playbook: ship

1. **Ready.** Each topic is one jj change whose description follows `~/.agents/skills/technical-writing/SKILL.md` and `~/.agents/skills/unslop/SKILL.md`, its checks are green, and `interrogate` ran on it (or the report says "not interrogated").
2. **Ask before pushing**, naming each bookmark, its change, and the remote. That approval covers re-pushing those bookmarks during this ship run. Then `jj bookmark create <name> -r <change>` and `jj git push -b <name>`.
3. **Open PRs** with `gh pr create`, ready rather than draft. A topic stacked on another targets its parent's bookmark; independent topics target trunk. Body sections, dropping empty ones: `## Why` (problem and approach, 1–3 sentences), `## What changed` (1–3 bullets), `## Scope` (what it covers and leaves out), `## Blast radius` (who or what it touches, and why that is safe), `## Verification` (each a real run and its outcome). Post the URLs and keep working; watch CI only when I ask.
4. **Fix CI failures** in the owning topic (`jj squash --into <change>`), not in follow-up changes, then re-push.
5. **Land only when I ask**: bottom-up, each PR with an independent verdict (`interrogate` from the other model family) covering its current head; `gh pr merge <pr> --squash`, then read the PR back to confirm it merged into trunk before landing the next.
