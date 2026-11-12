---
name: maintain-formal-verification-skill
description: Brings a project's formal verification back in line with code that changed without rechecking it, and separates drift from real bugs. Use for /maintain-formal-verification-skill.
disable-model-invocation: true
---

# Maintain a formal verification skill

A check that passes while describing code that no longer exists looks like a proof and isn't.

Give each check one outcome: **in sync**, **updated**, **bug** (the verification describes the current code and the code breaks the property), or **blocked**. A check can be both updated and bug.

Edit only the verification (models, harnesses, properties, the verify skill). Never weaken a property or model to pass, and never edit product code unless I ask.

1. **Find the checks**: project skills that run a model checker, prover, or verifier against named code. For each, collect the property, covered code, bounds, assumptions, command, and sync commit (if none is recorded, use the last commit that changed the verification files and say so). None found: point at `/create-formal-verification-skill`.
2. **Run each as it is** and record the result before changing anything.
3. **Read every change to covered code** since the sync commit, including renamed, split, or moved functions and new code that touches the guarded state. Classify each: no effect; the verification no longer describes the code; the promise changed on purpose (cite the evidence); the promise may be broken.
4. **Update from the code, not from the result**: each changed part again points to openable code, one code step stays one model step. Change a property only for an intended promise change, recording old wording, new wording, and evidence. Keep bounds, or report any reduction.
5. **Rerun and judge**. On pass, break the new code the way the property guards against and confirm the check catches it. On fail, replay the counterexample against the code step by step: an impossible step means the verification is wrong (fix it and say what was wrong); otherwise it is a bug (name the commit that introduced it, the steps, and the harm).
6. **Update the verify skill**: coverage, commands, bounds, assumptions, and the sync commit (not for a blocked check). Follow it once as the next agent would.

Report per check: outcome and commits read, what changed in the verification and why, rerun result and the break used, each bug in plain words, and what is still uncovered. Say which failures were drift and which were bugs. Verification updates go in their own jj change, separate from any product fix.
