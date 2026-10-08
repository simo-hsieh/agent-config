# Browser flows

A flow is a tested recipe for one recurring browser task, written so a cheaper model can run it without improvising. One file per flow, named `<site>-<task>.md`, using these sections:

- **Description**: what the flow does, then `Use for` with the words a request would use, in every language and spelling the user might write. Agents pick a flow from this line alone.
- **Inputs**: values the caller supplies, or `none`.
- **Steps**: numbered. Each step gives the exact command, then `Expect:` with what the output must contain. Prefer direct URLs and `batch --bail` over clicking through menus. A flow that reaches a hand-off ends with a step that stops there and reports the URL.
- **Output**: the exact report format.
- **Tested**: date and agent-browser version of the last successful run.

Rules for the runner: follow the steps in order and do not add steps. If an `Expect:` check fails, stop, close the session, and report `status: BLOCKED`, the failing step, and its output; do not try another route. Write a new flow only after doing the task once by hand and rerunning its exact commands.
