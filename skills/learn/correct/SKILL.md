---
name: correct
description: Finds the mistakes agents keep repeating in a repo and makes each impossible, preferring architecture and checks over docs. Use for /correct.
disable-model-invocation: true
---

# Correct

Assume every contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that compiles.

1. **Find mistake classes** in recent changes, reverts, review comments, agent instruction files, and workaround comments. A class counts once it has happened twice.
2. **Fix each class at the highest level that works:**
   1. architecture: one owner per piece of state, one supported way per task, internals that fail to import, one source of truth instead of hand-synced lists, old ways deleted;
   2. types, so the bad state can't be written; otherwise a lint or CI check whose error names what to use instead (on a common pattern, fail only when a change adds more);
   3. a behavior test;
   4. docs or agent rules, only for judgment calls.
3. **Prove** each new check fails on a real past mistake, and runs the same locally and in CI. One jj change per class. An exception sits on the offending line with a reason, an expiry date, and my approval.
4. **Keep a rule table** in the project's agent instruction file pairing each rule with what enforces it. A repeated mistake whose rule nothing enforces gets fixed at a higher level in the same change. Drop a rule once its mistake can't happen.

Report each class with its evidence, the level chosen, and why a higher level didn't work.
