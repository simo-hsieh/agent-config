---
name: jj
description: Use before editing or organizing changes in a Jujutsu (jj) repository. Maintain coherent topic changes, a dependency-driven graph, and descriptions mapping intent to design and contents.
---

# jj workflow

## Inspect and preserve

- Read repository instructions and inspect `jj status`, `jj log`, and relevant diffs and descriptions before editing. In colocated repositories, use jj rather than Git to manage history.
- Identify task-owned changes, unrelated user work, real dependencies, and shared revisions. Do not infer ownership merely because a change is mutable or unpublished.
- Split, squash, describe, and rebase local task-owned work as needed without asking at each step. Ask before rewriting shared work, moving bookmarks, or pushing; never discard unrelated work.
- Use stable change IDs when targeting revisions. For flags, read installed `jj help <command>`; for concepts, read `jj help -k <topic>` or the `docs/` of jj-vcs/jj at the installed version's tag (`jj --version`). Never translate Git commands by analogy.

## Structure by topic, not chronology

- Keep one coherent, reviewable change per intent. Fold corrections and refinements into that topic with `jj squash`, updating its description; do not accumulate “fix previous change” commits for the same intent.
- Prefer `jj split` to separate work collected in the working copy over repeatedly using `jj new` to record chronological checkpoints. Use `jj new` when a new working copy or integration head is actually needed.
- Keep independent topics as siblings on their common base. Stack a topic only when it requires another topic's contents; touching the same file alone is not a dependency.
- A split alone does not establish independence: inspect the resulting parent edges and rebase independent changes onto their common base when needed.
- When working across topics, keep a merge working-copy head joining the active topic tips. Make edits there, then split new topics out or squash refinements into their owning topic with explicit source and destination revisions.
- Keep the integration head free of unassigned edits when handing off finished work. Do not duplicate topic patches in the merge or flatten independent siblings into a stack merely to simplify command execution.
- Keep a topic's implementation, tests, and necessary documentation together. Split distinct intents, not arbitrary file groups or implementation/test phases.

Preferred shape (arrows run from parent to child):

```text
base ── topic A ──┐
  └──── topic B ──┴── @ integration
```

If B actually depends on A, use `base → A → B` instead. A single topic needs no merge head.

## Describe the current change

- Write descriptions for someone reviewing the resulting patch without reading earlier versions. Replace stale descriptions after splitting, squashing, or changing the approach.
- Use a specific outcome-focused title, then concise sections mapping the patch to its intent, design, and actual changes. Cite existing intent/design requirement IDs when available; do not invent rationale or claim unrun checks passed.

```text
<Specific outcome of this topic>

Intent: <Problem or desired behavior; requirement IDs if available.>
Design: <Approach and important constraint or trade-off.>
Changes: <Concrete behavior, implementation, tests, and docs in this patch.>
```

## Verify and recover

- After graph edits, inspect `jj log`, `jj status`, and each affected change's diff and description. Check parent relationships, conflicts, missing or duplicated edits, and preservation of unrelated work; run relevant checks on changed topics and the integrated result.
- Use `jj op log` to inspect operations and `jj undo` to recover from a mistaken local operation after checking for intervening work. Do not create backup commits solely to preserve every editing step; operation recovery does not replace tests, protect external side effects, or justify discarding someone else's work.
- At handoff, report the topic change IDs, graph shape, verification, and any unresolved conflicts or unassigned edits.
