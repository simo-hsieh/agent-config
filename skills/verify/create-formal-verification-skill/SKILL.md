---
name: create-formal-verification-skill
description: Picks the promise in a repo that most needs formal verification, verifies one property of it, and leaves a project-local skill that rechecks it on every relevant change. Use for /create-formal-verification-skill.
disable-model-invocation: true
---

# Create a formal verification skill

The user must be able to trust and act on the result without learning the verification language.

1. **Choose the target from the code** (or start from the area or bug I name): a promise whose break harms users and that tests rarely reach. Take the strongest target, not the easiest.
2. **Let the question choose the tool**, at the lowest cost: bad orderings of events suit a model checker over a small model (TLA+ by default, read with `statechart`); behavior of the code for every input (memory safety, overflow, a data-structure invariant) suits a verifier that runs on the code; with no verifier for the language, test the real code with generated inputs; a property needed at every size may need a proof. Prefer a tool the repo's developers can install, and say why you chose it.
3. **Make it good:**
   - True to the code: every part points to code a reviewer can open, one indivisible code step is one model step, names come from the repo.
   - Able to fail: show each property failing on a broken variant (a removed check, a reordered step).
   - Findings stay findings: report a break with its counterexample in the code's terms; never weaken the property or model; change product code only if I ask.
   - Honest scope: what is verified, under which bounds and assumptions, and what is left out.
   - Cheap to rerun: one command, a pinned tool version, a short run.
   - Kept in step: record the files and functions each check covers and the commit where you last confirmed the model describes them.
4. **Generate** a project-local skill (in `.claude/skills/` and `.agents/skills/`) that lets the next agent tell whether a change touches the verified code, run the check, tell a real bug from a modeling error, and update the verification for an intended change. It holds the coverage record and sync commit, and moves the sync commit only after confirming the model describes the new code. No placeholders.
5. **Prove it**: on a scratch change that breaks the property in the real code, the generated skill must catch the break. Drop the scratch change and confirm the check is back where it started.
6. **Hand off**: what was verified, the tool and why, the bounds, findings in plain words, how to run it, what it doesn't cover. Point me at `/maintain-formal-verification-skill`.
