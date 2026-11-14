---
name: interrogate
description: Adversaries from the other model family try to break a change, and a finding survives only when a run proves it. Loaded by path when a feature change is ready, or forced with /interrogate.
disable-model-invocation: true
---

# Interrogate

Run it in the background; the main session keeps working and merges the findings into its report.

1. **Scope**: the change named, otherwise the current topic's jj change. State its intent in your own words from the request, the change description, and any intent or design doc.
2. **Adversary**: a seat from a model family other than the author's, on its thinking tier through `delegate`; outside Herdr, a Claude Code subagent when the author is not Claude. Give it its own jj workspace at the change. If every other family is out of quota, stop and report "not interrogated".
3. **Brief**: the scope, the intent, and: "Break this change. Prove each finding with a run against the real code: a failing test, a repro script, or command output showing the wrong behavior. For a design, run a prototype or probe the current tree. Report each finding with a title, the exact command, its output, and the output the intent requires. Leave out anything you did not run, including style, naming, and risks that need a future change to matter. No findings is a valid result."
4. **Verify** each finding by rerunning its command. Keep it when the output shows a failure that breaks the intent; drop the rest; merge findings with one root cause.
5. **Report** the intent, then each verified finding with its command, output, and how it breaks the intent, or "no verified findings". Apply no fixes. Remove the workspace you created.
