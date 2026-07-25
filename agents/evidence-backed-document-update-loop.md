# Evidence-backed document update loop

Use this workflow for substantial internal design-document updates where the agent should proceed with minimal human involvement but must not invent architecture, ownership, framework behavior, or policy.

The workflow is harness-neutral. Invoke installed roles with intent-oriented instructions rather than depending on one orchestration syntax.

## Goals

- Verify the current system against local and authoritative internal evidence before editing.
- Continue automatically when evidence, scope, and remediation are unambiguous.
- Involve a human only for consequential or unresolved decisions.
- Keep one writer per working tree.
- Bound research and review loops to prevent endless rewriting.

## Required roles

| Role | Responsibility | Authority |
|---|---|---|
| Primary | Own scope, reconcile evidence, apply gates, and route work | Decision authority within the user's stated constraints |
| `scout` | Inspect the document and local workspace | Read-only |
| Internal research role | Verify claims against authoritative internal code and documentation | Read-only; supplied as `{{INTERNAL_RESEARCH_ROLE}}` (for example, `google_research`) |
| `planner` | Turn confirmed understanding into a targeted plan | Read-only |
| `worker` | Apply one approved, bounded document update | Sole writer |
| `reviewer` | Independently review the actual change and evidence | Read-only |
| `oracle` | Resolve decision drift or expose consequential contradictions | Advisory; use only when needed |

Do not use an external researcher for internal code, paths, infrastructure, customer data, or documentation.

Use the shared `evidence-learning-loop` skill across the workflow. Research establishes initial claims; planning turns claims into predictions; implementation and tests produce new observations; review challenges explanations; completion updates claim states and decides whether any learning should persist. Because child agents may not inherit skills, include the relevant role checkpoint in every delegation.

## Parameters

Supply these values when starting a loop:

```text
{{DOCUMENT_PATH}}           Document to update
{{WORKSPACE_ROOT}}          Workspace containing the document
{{FRAMEWORK_NAME}}          Existing framework whose contracts must remain canonical
{{CHANGE_GOAL}}             Desired document improvement
{{INTERNAL_RESEARCH_ROLE}}  Installed role authorized for internal sources, e.g. google_research
{{INTERNAL_RESEARCH_SCOPE}} Internal repositories, docs, symbols, or teams that may be searched
{{PROTECTED_SECTIONS}}      Sections that must not change
{{OUT_OF_SCOPE}}            Explicitly excluded work
{{LEARNING_LEVEL}}          evidence-hygiene | task-learning | durable-knowledge
{{KNOWLEDGE_OUTPUT_DIR}}    Authorized location when durable knowledge is requested
```

## State machine

```text
START
  ├─ scout: inspect document and local workspace
  └─ internal research role: verify internal code and documentation
       ↓
UNDERSTANDING
  ├─ evidence gate passes → PLAN
  ├─ narrow evidence gap → one additional research round
  └─ material conflict or missing decision → HUMAN
       ↓
PLAN
  ├─ plan gate passes → EDIT
  └─ architecture, ownership, safety, or policy decision → HUMAN
       ↓
EDIT
  └─ one worker changes only the approved document scope
       ↓
REVIEW
  ├─ no blockers → VERIFY
  ├─ unambiguous finding → same worker corrects → REVIEW
  └─ consequential or ambiguous finding → HUMAN
       ↓
VERIFY
  ├─ passes → DONE
  ├─ unambiguous failure → one correction → VERIFY
  └─ unresolved or loop limit reached → HUMAN
```

## Incremental learning checkpoints

Apply the `evidence-learning-loop` skill at four checkpoints:

1. **After research:** establish material claims, scope, evidence, conflicts, predictions, and falsifiers.
2. **After planning:** connect assumptions to observable verification and state how failures would change the explanation.
3. **After implementation and tests:** record expected versus actual behavior, experiments, discoveries, counterexamples, and challenged claims.
4. **After review:** update claim states and decide whether learning stays ephemeral, becomes a generalization candidate, or merits an authorized durable artifact.

Do not promote one successful case directly into a reusable principle. Preserve rejected, superseded, and stale claims when they influenced prior decisions.

## Evidence gate

The primary agent synthesizes scout and `{{INTERNAL_RESEARCH_ROLE}}` findings into an internal Understanding Contract. The gate passes only when:

- every material claim is supported by evidence appropriate to its statement kind, such as executable behavior, tests, implementation, approved decisions, explicit requirements, production observations, or canonical documentation;
- no authoritative sources materially conflict;
- component and framework ownership are supported;
- implemented behavior is distinguished from proposed behavior;
- unverified assumptions are non-material, omitted, or explicitly labeled;
- the understanding does not invent framework behavior.

Do not ask a human to confirm facts already demonstrated by canonical evidence.

When a narrow gap remains, run one additional query through `{{INTERNAL_RESEARCH_ROLE}}` containing only the unresolved question. If the result remains ambiguous, escalate.

### Source authority

Match evidence to the claim instead of applying one universal ranking:

- **Current behavior:** prefer reproducible execution, behavior tests, implementation, and relevant operational evidence.
- **Intended architecture:** prefer approved decisions, canonical interface contracts, and current design ownership.
- **Product requirements or policy:** prefer authorized owner decisions and explicit requirements.
- **Production behavior:** prefer production observations and reproducible environment-specific experiments.

Treat comments and search-result snippets as leads to canonical evidence. Do not resolve a conflict silently. Current implementation and intended architecture can legitimately differ.

## Understanding Contract

The synthesized contract should contain:

1. **System under evaluation** — stages, inputs, outputs, owners, and whether each stage is model-driven or deterministic.
2. **Evaluation-system boundary** — what the existing framework owns and what remains domain-specific.
3. **Supported use-case model** — one journey, registered journeys, or a supported class of journeys, based only on internal evidence.
4. **Canonical concepts** — definitions that the target document should define, summarize, or reference.
5. **Evaluation boundaries** — where contracts can be observed and independently evaluated.
6. **Measurement model** — dimensions, evidence, evaluators, metrics, and policy.
7. **Determinism model** — deterministic assertions, probabilistic candidates, model judges, repetitions, and enforcement.
8. **Conflicts and uncertainty** — disagreements and their required resolution.

Classify material claims with the `evidence-learning-loop` lifecycle, including scoped states such as `SUPPORTED`, `VERIFIED_IN_SCOPE`, `CHALLENGED`, or `PROPOSED` with an explicit evidence gap. Record inference as the statement kind, not as a substitute claim status. Do not put internal lifecycle labels into the final document unless they improve reader understanding.

## Plan gate

The planner may proceed directly to the worker only when:

- every edit serves `{{CHANGE_GOAL}}`;
- edits remain within `{{DOCUMENT_PATH}}` and avoid `{{PROTECTED_SECTIONS}}`;
- no code, schema, configuration, infrastructure, or release change is required;
- canonical `{{FRAMEWORK_NAME}}` concepts are referenced rather than duplicated;
- no architecture, ownership, security, safety, or release-policy decision is invented;
- the plan is targeted rather than a broad rewrite;
- every material edit traces to confirmed evidence;
- acceptance criteria are observable.

The plan should list sections, operation type, purpose, supporting evidence, content to preserve, semantic risk, and acceptance criteria.

## Editing rules

The worker is the only writer and must:

- read the complete document before editing;
- recheck cited internal evidence required for the change;
- stop if evidence changed or disappeared;
- modify only planned sections;
- preserve useful domain-specific details;
- distinguish implementation from proposal;
- keep candidate execution, evidence collection, evaluation, aggregation, and policy separate;
- avoid inventing internal APIs, ownership, or behavior;
- avoid sending internal content to external services;
- avoid modifying unrelated files;
- avoid initializing Git or committing unless explicitly requested.

If the workspace is not under version control, preserve a temporary baseline outside the workspace so the reviewer can inspect a precise before/after diff.

## Automatic review triage

Automatically accept a reviewer finding only when:

- it cites exact text and supporting evidence;
- the remediation is local and unambiguous;
- it remains within the change goal;
- it does not introduce a new product, architecture, ownership, security, safety, or policy decision.

Automatically reject:

- unsupported style preferences;
- broad rewrites outside the goal;
- findings contradicted by stronger canonical evidence.

Escalate:

- Critical findings;
- ambiguous High findings;
- internal-source conflicts;
- findings requiring consequential decisions.

Accepted corrections return to the same worker. The reviewer never becomes a second writer.

## Human escalation conditions

Stop and request a decision only when at least one condition applies:

1. Authoritative internal sources materially conflict.
2. A product or architecture decision is absent.
3. Component, framework, or team ownership is unclear.
4. The change affects security or safety policy.
5. The change affects release policy or risk tolerance.
6. The change creates or alters an implementation commitment.
7. The required work expands beyond documentation.
8. A Critical or High review finding has multiple valid remediations.
9. Internal information may cross an unapproved data boundary.
10. A configured loop limit is exhausted.

## Human decision packet

Ask one focused question at a time:

```markdown
## Decision required

**Workflow state:** <state>

**Blocking question:**
<one concrete question>

**Why a human is required:**
<missing decision, conflict, or consequential trade-off>

**Evidence:**
1. <source and conclusion>
2. <conflicting source and conclusion>

**Options:**

A. <option>
   - Document consequence: <effect>
   - System consequence: <effect>

B. <option>
   - Document consequence: <effect>
   - System consequence: <effect>

C. Preserve the issue as explicitly unresolved.

**Agent recommendation:** <option>

**Reason:** <evidence-based rationale>

**Reply with:**
- `DECISION: A`
- `DECISION: B`
- `DECISION: C`
- `CHANGE: <alternative direction>`
- `RESEARCH: <specific internal question or source>`
- `DEFER: <issue>`
- `STOP`
```

After an answer, resume from the blocked state. Do not repeat completed research unless the decision changes its assumptions.

## Loop limits

Default limits:

```text
Internal research rounds:       2
Planning attempts:              1
Worker/reviewer cycles:         2
Verification correction cycles: 1
```

Escalate when a limit is reached. Do not continue with stylistic churn.

## Master prompt

```text
Run an exception-driven document update using the installed managed agents.

Parameters:

Document: {{DOCUMENT_PATH}}
Workspace: {{WORKSPACE_ROOT}}
Canonical framework: {{FRAMEWORK_NAME}}
Change goal: {{CHANGE_GOAL}}
Internal research role: {{INTERNAL_RESEARCH_ROLE}}
Internal research scope: {{INTERNAL_RESEARCH_SCOPE}}
Protected sections: {{PROTECTED_SECTIONS}}
Out of scope: {{OUT_OF_SCOPE}}
Learning level: {{LEARNING_LEVEL}}
Authorized knowledge output: {{KNOWLEDGE_OUTPUT_DIR}}

Proceed autonomously unless a Human Escalation Condition is met. Load and follow the `evidence-learning-loop` skill for material claims and role checkpoints.

Workflow:

1. Run scout and {{INTERNAL_RESEARCH_ROLE}} as independent read-only tasks. Require observations, candidate claims, current/intended/legacy distinctions, conflicts, and testable predictions in their handoffs.
2. Synthesize their evidence into an Understanding Contract and initialize material claim states under the evidence-learning loop.
3. Apply the Evidence Gate.
4. If a narrow evidence gap remains, run at most one focused additional
   query through {{INTERNAL_RESEARCH_ROLE}}.
5. If the gate passes, ask planner for a targeted, evidence-backed plan.
   Require material assumptions, predictions, verification steps, and how
   failed checks would change the explanation or plan.
6. Apply the Plan Gate.
7. If the gate passes, assign one worker as the only writer. Require expected-versus-actual behavior, experiments, discoveries, challenged claims, and counterexamples in its handoff.
8. Ask reviewer to inspect the actual diff, supporting internal evidence, claim scope, test strength, and possible overgeneralization.
9. Automatically triage findings under the Automatic Review Triage policy and update claim states from accepted evidence.
10. Send accepted, unambiguous corrections to the same worker.
11. Repeat review at most once.
12. Perform final read-only verification.
13. If verification passes, report completion and stop.
14. If any escalation condition occurs, stop and return one Human Decision
    Packet.

Evidence requirements:

- Support material claims with evidence appropriate to the question: current
  behavior, intended architecture, product requirements, or production
  behavior.
- Treat search snippets as leads, not authority.
- Report source conflicts rather than resolving them silently.
- Distinguish verified facts, inference, and unresolved assumptions.
- Do not ask the human to confirm already verified facts.

Editing requirements:

- Do not replace or redefine {{FRAMEWORK_NAME}}.
- Reference canonical framework definitions rather than creating parallel
  schemas.
- Preserve useful domain-specific implementation detail.
- Do not force deterministic infrastructure into interactive-agent
  terminology.
- Separate supported use cases, system boundaries, cases and assertions,
  dimensions, evidence, evaluators, metrics, and policies.
- Distinguish deterministic assertions from probabilistic model judges.
- Do not invent ownership, internal behavior, implementation status, or
  release policy.
- Keep one writer.
- Do not modify unrelated files, initialize Git, or commit.
- Do not send internal material to external services.

Human Escalation Conditions:

1. material internal-source conflict;
2. unresolved product or architecture decision;
3. unclear ownership;
4. security or safety policy change;
5. release-policy change;
6. changed implementation commitment;
7. scope expansion beyond documentation;
8. ambiguous Critical or High finding;
9. sensitive-data boundary risk;
10. exhausted loop limit.

Use these limits:

- internal research rounds: 2;
- planning attempts: 1;
- worker/reviewer cycles: 2;
- verification correction cycles: 1.

Completion report:

- final confirmed understanding;
- initial material claims and their final states;
- what implementation and tests demonstrated;
- rejected or narrowed claims and counterexamples;
- reusable patterns versus generalization candidates;
- persistence decision and optional deep dives;
- internal sources consulted;
- sections changed;
- acceptance-criterion results;
- reviewer findings and dispositions;
- verification performed;
- remaining non-blocking uncertainty;
- recommendation: ready for human review or needs a decision.

Do not continue improving after the completion gate passes.
```

## Follow-up change loop

After a completed update, do not automatically repeat the full workflow. Start with a targeted scout and reuse confirmed evidence only when its source has not changed and the new request does not alter the system boundary.

```text
Run a follow-up document-update loop.

Previous completion summary:
{{PREVIOUS_COMPLETION_SUMMARY}}

New change request:
{{NEW_CHANGE_REQUEST}}

Document: {{DOCUMENT_PATH}}
Workspace: {{WORKSPACE_ROOT}}
Internal research role: {{INTERNAL_RESEARCH_ROLE}}

Reuse prior evidence and claim states only when:

- their source revisions and recorded scope are unchanged;
- the request introduces no new use case, component, evaluator, ownership,
  safety policy, or release policy;
- no new contradictory evidence exists.

Begin with a targeted scout of affected sections. Use
{{INTERNAL_RESEARCH_ROLE}} only for new claims, changed sources, prior
unresolved questions, or conflicts.
Then apply the same Plan, Edit, Review, Verify, and Escalation gates.
Do not reopen settled decisions without new evidence.
```

## Completion condition

Stop when:

- no Critical or High findings remain;
- every material claim is sourced or explicitly qualified;
- final verification passes;
- unresolved issues are listed;
- the document is ready for human review.

A completion report is not permission to publish, deploy, push, or change remote infrastructure.
