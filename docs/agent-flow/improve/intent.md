# Intent: agent improvement pipeline

Status: draft.

## Problem

When an agent falls short in any repo, the fix is ad hoc or lost. Claude Code memory is stored per project, so a lesson learned in one repo never reaches a `/reflect` run in `~/code/_agent`; Pi has no memory; and only my corrections are captured, not the agent's own friction.

## Desired outcome

Improvements flow through stages, each producing an artifact the next consumes:

```text
1 found ─► 2 collect ─► 3 propose ─► 4 verify ─► 5 apply
```

1. **Found**, in any repo and either harness: when I correct the agent, or it hits friction (a skill that misfired or was missing, a repeated workaround), it writes one issue note to a central local inbox: the repo, the transcript path, what happened, and a suggested change.
2. **Collect**, in a batch I start in `~/code/_agent`: group notes into issue classes; a class seen twice or more ranks first.
3. **Propose**, per class: the exact file and line in the rule's one home, the behavior it should change, and the cases it must fix. A proposal can be a check or script instead of prose. I pick which proposals go forward.
4. **Verify**, for now by a human run: I try the proposed jj change in real work by publishing it to `~/.agents/src` and roll back with `jj -R ~/.agents/src new <previous change>` if it falls short. A benchmark that replays each case against the current and proposed config replaces this later.
5. **Apply**: the jj change's description records the cases and how they were verified; it stays published only with my approval.

## Constraints

- The inbox is local, outside this repo and the live workspace, and never published: notes cite private transcripts.
- Nothing becomes live config without my approval.
- Each proposal edits a rule in its one home and keeps every line behavior-changing.

## Open questions

1. How to run Claude Code and Pi against an unpublished candidate config, for the later benchmark stage (research pending).
2. Which benchmark design fits personal agent config, as opposed to a team benchmark framework.
3. How the agent reliably notices its own friction without noise.
4. Inbox note format and location (proposed `~/.agents/inbox/<date>-<slug>.md`).
5. Where the collect and propose procedure lives, given the proposed move of this repo's conventions into its own project instructions.
