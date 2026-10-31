---
name: model-the-domain
description: Choosing a data structure that encodes the domain instead of scattered conditionals. Loaded by path from the feature design step.
disable-model-invocation: true
---

# Model the domain

Pick the structure that makes invalid states unrepresentable and deletes branches:

- a state machine instead of scattered booleans, phases, or lifecycle checks;
- a typed model instead of loose parameters or repeated shape assumptions;
- a map, registry, lookup table, or discriminated union instead of branching spread across files;
- a reducer or command/event model instead of ad hoc mutations;
- a module around one body of domain knowledge, not one per execution stage (load, validate, save);
- a queue, cache, index, graph, or normalized collection where the access pattern calls for it.

When none fits, write down what the code must never allow and how the data is read, then pick the structure that encodes exactly that.

Keep boring code when the current shape is clear, local, and unlikely to grow. Reject an abstraction that adds indirection without removing branches, duplicated rules, invalid states, or lifecycle risk.

You skipped this when a feature adds one more branch to an existing if/else chain, adds a second boolean that must stay in sync with the first, or repeats the same rule in several stage-named modules.
