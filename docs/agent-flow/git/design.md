# Design: git instead of jj

Status: decided 2026-11-17; `install.sh`, `README.md`, and `docs/` done; the files in Migration wait for the integrator. Supersedes R8 "jj everywhere" in `../understand/design.md`.

## Why

jj cost more than it returned for agents:

- A second jj workspace served the live config. When its parent was another workspace's working copy, that workspace's next snapshot made it stale. It kept serving old files while `./install.sh` printed `ok`, and `update-stale` then published unreviewed drafts.
- Any jj command, even `jj log`, may snapshot and rewrite a change. That forced the rule that no delegate, readers included, runs jj during a write wave. Git reads never mutate.
- Agents misuse jj's CLI. In one session: `-q` does not exist, `describe` takes a positional revision instead of `-r`, and `description(x)` matches the whole text exactly.

jj's real benefit, cheap stacking and automatic rebasing of descendants, is covered by `git rebase --update-refs` (git 2.38 or later).

## Workflow

Adapted from pstack's Opening a PR, Autopilot-stack, Shipping, and Worktree cleanup playbooks (cursor/plugins `pstack/skills/poteto-mode/playbooks/`).

- **Topic = branch.** One coherent topic per branch, off trunk. Independent topics are sibling branches. Stack a branch on another only when it needs that code, and open its PR against the parent branch.
- **Worktree per writer.** Each concurrent writer, delegate or session, works in its own `git worktree add <path> -b <topic> <base>`, so no two writers share a checkout. The integrator merges or cherry-picks their branches. Read-only git commands (`status`, `log`, `diff`, `blame`) are allowed at any time.
- **Commits.** Small and landable. The message explains intent, design, and contents per `technical-writing` and `unslop`. Fold a follow-up into its topic with `git commit --fixup=<sha>`, then `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>`; the editor variable makes this non-interactive.
- **Restack.** `git rebase --update-refs <trunk>` from the top branch moves every branch in the stack. A rebase moves a verified commit to a new SHA, so compare `git patch-id` before trusting an older verification.
- **Push.** Only with approval, naming each branch and remote. Rewriting your own pushed branch uses `--force-with-lease`. Never force-push a shared branch.
- **Recover.** `git reflog` replaces `jj op log` and `jj undo`.
- **Cleanup.** Read paths from `git worktree list`, never type them. Removing a clean worktree is recoverable from its branch; uncommitted work is not, so show the diff and ask first.

## Live config

`./install.sh` publishes one commit. It exports the commit with `git archive` into a read-only `~/.agents/releases/<sha>/`, then renames a new symlink over `~/.agents/src`. Harness links point into `~/.agents/src` and never change. Without `--rev` it installs `HEAD` and refuses a dirty tree. `--rev <commit>` installs any commit, which is also how to roll back. Paths such as `~/.agents/src/models.md` keep working.

## Migration

Outside this change's writable paths, for the integrator:

| File | Change |
|---|---|
| `AGENTS.md` Version control | Replace the three jj bullets with: git only; one topic per branch; worktree per concurrent writer; ask before rewriting shared branches or pushing. Playbook row `ship`: "finished topic branches". |
| `AGENTS.md` Delegation | The shared-checkout bullet becomes: each concurrent writer gets its own worktree and branch, and the integrator merges them. |
| `skills/tools/jj/` | Delete. Add `skills/tools/git/SKILL.md` only if the Workflow section above is too long for AGENTS.md. |
| `skills/playbooks/ship/SKILL.md` | Branches instead of bookmarks; fix CI in the owning commit with `--fixup` and autosquash; land bottom-up and restack with `--update-refs`; `patch-id` check per pstack Shipping. |
| `skills/operate/delegate/SKILL.md` | The write wave becomes a worktree per writer. Drop "no jj commands"; keep "no Git mutations outside your worktree". The Contract text is in line 52. |
| `skills/understand/why/SKILL.md` | `git blame`, `git log --follow -- <path>`, `git log -L`, and `git reflog` for reworked commits. |
| `skills/understand/recall/SKILL.md` | Verify against `git status` and `git log`; status tags `[pushed <branch>]`, `[local <branch>]`, `[abandoned]`. |
| `skills/playbooks/long-run`, `verify/interrogate`, `write/unslop`, `write/technical-writing`, `build/tdd`, `learn/correct`, `design/arena`, `understand/auto-research`, `verify/maintain-*-verification-skill` | Replace "jj change/topic/description" with "commit/branch/commit message"; arena seats use `git worktree`. |
| `claude/delegate.json`, `agy/delegate.json` | Drop `jj git push` and `jj bookmark`; keep `git push`, `gh pr create`, `gh pr merge`. |
| `claude/README.md`, `agy/README.md` | Drop jj mentions; `agy/README.md` also needs the browser exception from `../harnesses/design.md`. |
| `README.md` layout | Drop `jj` from the `tools/` line when the skill is deleted. |
| Memory `jj-edit-in-head` | Delete. |

Repository conversion, which needs the user's approval because it deletes `.jj`:

1. Put the content live today on `main`. The jj change `mmsskunp` is git's working tree on top of detached `HEAD` `b1fdb45`, and `main` is at `a5af63d`: `git switch -c git-migration`, then commit.
2. `jj workspace forget stable cloudtop`, then remove `.jj`.
3. `./install.sh` on the Mac and in `cloudtop`. Each run backs up the old `~/.agents/src` workspace directory and replaces it with the release link.
