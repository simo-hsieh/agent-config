---
name: ship
description: Playbook for turning finished topic branches into pull requests and landing them. Routed from AGENTS.md or forced with /ship.
disable-model-invocation: true
---

# Playbook: ship

1. **Ready.** Each topic is a branch of small commits whose messages follow `~/.agents/skills/technical-writing/SKILL.md` and `~/.agents/skills/unslop/SKILL.md`, its checks are green, and `interrogate` ran on it (or the report says "not interrogated").
2. **Ask before pushing**, naming each branch and the remote. That approval covers re-pushing those branches during this ship run, with `--force-with-lease` after a rewrite. Then `git push -u <remote> <branch>`.
3. **Open PRs** with `gh pr create`, ready rather than draft. A topic stacked on another targets its parent's branch; independent topics target trunk. Body sections, dropping empty ones: `## Why` (problem and approach, 1–3 sentences), `## What changed` (1–3 bullets), `## Scope` (what it covers and leaves out), `## Blast radius` (who or what it touches, and why that is safe), `## Verification` (each a real run and its outcome). Post the URLs and keep working; watch CI only when I ask.
4. **Fix CI failures** in the commit that owns them (`git commit --fixup=<sha>`, then `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>`), not in follow-up commits, then re-push. After a land, restack the rest with `git rebase --update-refs <trunk>` from the top branch, and compare `git patch-id` before trusting an earlier verification of a moved commit.
5. **Land only when I ask**: bottom-up, each PR with an independent verdict (`interrogate` from the other model family) covering its current head; `gh pr merge <pr> --squash`, then read the PR back to confirm it merged into trunk before landing the next.
