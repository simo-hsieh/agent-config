# Intent: delegate tabs across Claude Code, Pi, and agy

Status: draft; awaiting review of the role map and the open questions. Replaces the 2026-11-08 draft that ran Codex and agy headless and Hermes as an operator.

## Problem

Delegation reaches only Pi, through `pi-delegate`, and only from Claude Code. Each harness has one model setting, so a delegate cannot be sent to a cheaper model for mechanical work or a stronger one for hard work. agy (Google Gemini) is installed but unused, so the setup has two model families instead of three. Skills that need a seat from another family (`arena`, `interrogate`, `reflect`) assume exactly Claude and Pi.

## Desired outcome

1. Three harnesses, one per model family and paid subscription: Claude Code (Anthropic), Pi (OpenAI through the ChatGPT subscription), and agy (Google Antigravity).
2. Each harness has a thinking tier and a fast tier, each a model and effort level, started in its own Herdr tab.
3. Each task goes to the model that does that kind of task best, per a task-type reference backed by measured runs; when models are equal, to the subscription with more quota left.
4. One `delegate` skill replaces `pi-delegate` and drives all three harnesses the same way. Group work in named outcome workspaces, start a fresh delegate per task, send a brief, wait, and read a status-lined report that ends in a handover. Close each finished tab once its handover is collected, so open tabs show only live work.
5. AGENTS.md and the shared skills behave correctly in every harness, both as orchestrator and as delegate.
6. The user can watch and steer delegate work from a browser or phone through Claude Code Remote Control.
7. Delegation keeps working when one or two subscriptions are out of quota: work moves to the harnesses that still have quota, and the user can continue from any harness's session.

## Constraints

- Delegates never push, merge, open PRs, or move bookmarks.
- Delegation is communication between models, guided by patterns rather than limits. Any agent, including a delegate, may use native subagents, Herdr tabs, or another harness, and quality comes before cost (decided 2026-11-18: with capable models, the old flat, Herdr-only, benefit-versus-overhead rules blocked useful work).
- Pending migration: `../git/design.md` replaces the next two rules with a git worktree per writer.
- Independent whole files/subtrees may be written concurrently in one checkout with explicit writable and forbidden paths. Ownership is cooperative convention, not locking or isolation; no jj workspace per worker is required.
- One integrator stages shared interfaces and owns shared files, manifests/lockfiles, snapshots/history, repo-wide formatting/codegen, and integrated tests. During a write wave, it avoids competing edits and history operations; all delegates, including readers, run no jj or broad mutating commands. Worker tests require independent inputs/output resources.
- Integration waits until writers and background mutating commands have stopped; Herdr `--wait` alone is insufficient. On overlap, stop affected writers, preserve edits, and reassign or serialize without auto-reverting others. Reader findings are revalidated at integration; each shared app instance has one live driver.
- Files a harness rewrites at runtime (settings, trust lists, auth) stay machine-local.
- Pi, Codex, opencode, and Hermes share one ChatGPT quota and model family, so only one of them earns a tab: Pi.
- Each paid subscription needs its own harness, so none can be dropped without wasting a subscription: Opus runs only in Claude Code (README, Models), and Pi 0.71.0 removed its built-in Antigravity login (Pi CHANGELOG), so the Google subscription is reachable only through agy.

## Out of scope

- Codex: dropped. Same quota and models as Pi, and Herdr tabs replace its headless `codex exec` mode.
- Hermes: deferred. Remote Control covers steering from the phone; Hermes would add only scheduled watchers and Telegram alerts.
- Google Drive access: done separately with `gog-readonly` (AGENTS.md, Tools).

## Success criteria

- From Claude Code, one task each to `claude-fast`, `pi-thinking`, and `agy-fast` returns a parseable report with a handover, and its tab is then closed. Related work stays in its outcome workspace; a live conversation continues only for an immediate dependent follow-up, otherwise the next task starts a fresh agent from the handover.
- A delegate tab asked to start another Herdr agent refuses.
- `arena` runs with three families and names the model behind each seat.
- One frontend task through `arena` across the three thinking tiers records which family gets UI work.

## Open questions

1. Resolved: any harness orchestrates, one level deep (design, Orchestration; Alternatives, A4).
2. The cap on concurrent delegate tabs: Claude suggested about 4, Pi suggested 3 including native subagents.
3. The Pi fast-tier model, a guess until a timed run. The agy fast model is assumed equal to Sonnet 5.5 and Sol.
4. Resolved: no ledger; `bin/model-usage` reads the harness session logs (design, Usage review; Alternatives, A2).
