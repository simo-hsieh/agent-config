---
name: intents
description: Dashboard of the intents in a repo, their status, and the open questions worth taking up next. Use for /intents.
disable-model-invocation: true
---

# Intents

1. Run `intents.sh <repo root>` from this skill's directory. It prints each `docs/**/intent.md` with its `Status:` line and its `## Open questions`, the one home for both.
2. In `~/code/_agent`, also list changes that are not live: `jj log -r 'mine() & ~empty() & ~::stable@'`.
3. Show a table: topic, status, open-question count, and drafted changes not live. Flag a status the repo contradicts (a doc says draft while its change is live) without editing it.
4. Recommend at most three items to take up next, each with one line on why now, ranking blockers (an item that stops a publish or another topic) first, then items with a decision ready to make.
