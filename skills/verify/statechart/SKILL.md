---
name: statechart
description: Model-checks a stateful flow (a product flow, protocol, service, or retry loop) with TLA+ and draws it as a statechart with the shortest path to each broken rule. Use for /statechart to understand, review, or design a stateful flow.
disable-model-invocation: true
---

# Statechart

The tool is pstack's `statechart` script, pinned to cursor/plugins commit `4dd1d05818d19792e7cd6e818f1667f95f7e1dbe`.

1. **Get the tool** once, outside any repo:

   ```sh
   T=~/.cache/pstack-4dd1d058
   [ -d "$T" ] || { git clone --filter=blob:none --no-checkout https://github.com/cursor/plugins "$T" && git -C "$T" checkout 4dd1d05818d19792e7cd6e818f1667f95f7e1dbe; }
   ```

   Read `$T/pstack/skills/statechart/SKILL.md` for the spec, view, and report rules. Its first run installs TLC and Java with mise and needs the network.
2. **Rules and events with me.** I state each rule as "never X" in my words. List every event, including failures: crash, timeout, retry, a concurrent actor. A missing event means missing paths.
3. **Model** in a scratch folder: the TLA+ spec (each rule an INVARIANT, `Next` a disjunction of actions, a `Done` action for correct end states, small constants or a CONSTRAINT) and a view module that labels states and arrows in my words.
4. **Run** `$T/pstack/skills/statechart/scripts/statechart SPEC.tla --config SPEC.cfg --view view.mjs --out <dir>`.
5. **Show** `chart.mmd` as a Mermaid block and, for each broken rule, the rule, its sentence, and the numbered path. Say what the model leaves out and which steps the chart hides.
6. **Replay** each bug path against the real code as a test, one step per action. A path that does not reproduce means the model is wrong until shown otherwise.

Never weaken a rule to make it hold; change the design.
