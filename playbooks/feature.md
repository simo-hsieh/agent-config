# Playbook: feature

For new behavior, a new interface, a cross-module change, or when a design doc is the deliverable.

1. **Context.** Read the code yourself. Use `scout` or `researcher` only when the evidence is wide (many modules, external APIs).
2. **Plan.** Write a short inline plan: approach, risks, and alternatives only when a real trade-off exists. For a design doc, keep it decision-focused: objective, design, alternatives with rejection reasons, risks. Wait for approval on a design doc or a change that touches more than a few files.
3. **Implement.** Red-green per step, inline or via `worker` for a bounded step. Update tests as behavior changes.
4. **Report.** What changed, how it was checked, open risks.
