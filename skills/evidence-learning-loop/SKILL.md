---
name: evidence-learning-loop
description: Track material claims and reusable engineering knowledge across research, planning, implementation, testing, and review. Use for non-trivial work involving unfamiliar or evolving systems, experiments, conflicting evidence, architecture, safety, compatibility, or an explicit learning goal; skip purely mechanical changes.
---

# Evidence learning loop

Build knowledge from the complete engineering loop, not from research summaries alone. Treat explanations as scoped claims that can be supported, challenged, narrowed, rejected, superseded, or made stale by later evidence.

## Choose the level

Use the lightest level that preserves correctness:

- **Level 0 — evidence hygiene:** For ordinary bounded work, distinguish claims from observations and verify material behavior. Do not create a knowledge artifact.
- **Level 1 — task learning:** For non-trivial work, track assumptions, predictions, verification, discoveries, and claim-state changes in the task handoff.
- **Level 2 — durable knowledge:** Persist a reviewed knowledge packet only when the result is likely to be reused and an authorized location is provided.
- **Level 3 — knowledge portfolio:** Use only when an explicitly owned catalog spans many tasks or projects. This may justify a separate curator role; it is not the default.

Skip the full loop for typo fixes, formatting, exact text replacement, established mechanical refactors, or known commands with no material uncertainty.

## Separate kinds of statements

Classify statements before deciding how to verify them:

- **Requirement or policy:** an authorized user or owner decides what should happen.
- **Source claim:** code, tests, documentation, or a person describes behavior or intent.
- **Observation:** an execution, experiment, or production signal records what happened under stated conditions.
- **Inference:** available evidence suggests an explanation that has not been directly demonstrated.
- **Preference:** the user chooses presentation or workflow behavior.

Do not "verify" a preference. Do not treat a hypothesis as a decision. Do not treat intended architecture as proof of current behavior.

## Match evidence to the question

There is no universal source ranking.

For current behavior, prefer reproducible execution, behavior tests, implementation, and operational evidence. For intended architecture, prefer approved decisions and canonical interface contracts. For product requirements, prefer authorized owner decisions. For production behavior, prefer production observations and reproducible environment-specific experiments.

Treat search snippets as leads. Open the canonical source. If intended design and current implementation conflict, preserve the conflict rather than choosing silently.

## Claim lifecycle

Use these states internally:

- `PROPOSED` — initial hypothesis or source claim.
- `SUPPORTED` — relevant evidence agrees, but behavior is not directly demonstrated.
- `VERIFIED_IN_SCOPE` — direct evidence confirms the claim under recorded conditions.
- `GENERALIZATION_CANDIDATE` — a mechanism may be reusable but lacks broad testing.
- `REUSABLE_PATTERN` — the claim survives tests across multiple relevant cases or systems.
- `CHALLENGED` — new evidence conflicts with the current claim.
- `REJECTED` — direct evidence disproves the claim in its stated scope.
- `SUPERSEDED` — the claim was valid but a newer implementation or decision replaced it.
- `STALE` — relevant sources or environments changed and require revalidation.

Never write an unscoped `VERIFIED` claim. Record the component, revision, environment, input class, and other conditions that limit it.

## Run the loop

### 1. Frame material claims

Before substantial action, identify only assumptions capable of changing the approach or conclusion.

For each material claim record:

```text
Claim
Statement kind
Scope
Current status
Supporting evidence and provenance
Evidence dependencies or shared origin
Conflicting evidence
Prediction
What would falsify or narrow it
Verification plan
```

Avoid tracking obvious facts merely to add ceremony.

### 2. Gather corroborating evidence

Track provenance and dependencies between sources. Tests, comments, documentation, and reports that derive from the same assumption form one evidence chain, not independent confirmation. Seek genuinely independent corroboration when the claim's consequence warrants it; otherwise state the limitation.

Use local inspection and authorized research to find:

- canonical definitions and ownership;
- current implementation;
- behavior tests;
- approved future direction;
- legacy behavior;
- relevant operational observations;
- contradictions and missing evidence.

Separate `CURRENT`, `INTENDED`, `LEGACY`, `CONFLICTED`, and `UNKNOWN` behavior.

### 3. Convert explanations into predictions

A mechanism becomes testable when it predicts an observable result.

```text
Hypothesis: Missing privileged capability metadata is rejected.
Prediction: A target with absent metadata will be excluded.
Test: Run selection with controlled absent metadata.
Falsifier: The target is selected.
```

If no practical observation could challenge a claim, keep it as an interpretation rather than established engineering knowledge.

### 4. Connect plans to verification

A plan should state:

- material assumptions it depends on;
- expected observable behavior;
- checks that distinguish success from accidental passage;
- how failure changes the explanation or plan.

Do not design tests that merely reproduce implementation details when a requirement or boundary behavior is the real contract.

### 5. Capture implementation discoveries

During implementation, record when actual behavior differs from the plan:

- unexpected call paths or constraints;
- assumptions supported or challenged;
- new failure mechanisms;
- workarounds that should not be generalized;
- tests or experiments added because of the discovery.

Do not silently adapt around a false assumption.

### 6. Treat tests and experiments as scoped observations

For consequential experiments record:

```text
Question
Prediction
Setup and environment
Candidate and source revisions
Input
Expected result
Actual result
Repetitions, when relevant
Artifacts or evidence references
Affected claims
Limitations
```

A passing test supports a claim within its scope. It does not prove a universal principle.

### 7. Challenge through review

Review both the change and the explanation. Look for:

- unsupported claims;
- evidence that cannot prove the stated mechanism;
- missing counterexamples;
- confirmation-only tests;
- hidden environment assumptions;
- generalization from one case;
- stale or conflicting sources.

The reviewer reports findings; it does not silently become the knowledge or implementation writer.

### 8. Update claim states

At completion, explicitly list meaningful transitions:

```text
C-01: SUPPORTED → VERIFIED_IN_SCOPE
C-02: PROPOSED → REJECTED
C-03: GENERALIZATION_CANDIDATE, unchanged; only one use case tested
```

Preserve rejected and superseded claims when they affected prior decisions. Record what replaced them and which artifacts may need correction.

### 9. Promote abstractions conservatively

Use these layers:

1. **Observation:** one recorded event.
2. **Scoped finding:** a conclusion tied to a component and conditions.
3. **Mechanism:** a tested explanation of why the behavior occurs.
4. **Reusable pattern:** a mechanism that survives multiple relevant contexts and counterexample search.
5. **Engineering principle:** a broad rule with explicit applicability and exceptions.

Do not skip layers. Promote only when evidence supports the wider scope. A useful local finding may remain local indefinitely.

### 10. Decide whether to persist

Persist knowledge only when it is likely to be reused, affects consequential decisions, explains a recurring mechanism, or protects against repeating a costly mistake.

Before writing a durable artifact, confirm:

- the output location is authorized for the source sensitivity;
- source references will remain access-controlled appropriately;
- raw internal results, credentials, customer data, and transcripts are excluded;
- an owner or refresh trigger exists;
- rejected and conflicting evidence remains visible.

Keep ephemeral research ephemeral by default.

## Role checkpoints

When delegating, include the relevant checkpoint in the task because child agents may not inherit loaded skills.

- **Scout:** observations, candidate claims, contradictions, source locations, and unknowns. Do not promote abstractions.
- **Researcher:** source claims, canonical ownership, current/intended/legacy distinctions, freshness, conflicts, and testable predictions.
- **Planner:** material assumptions, predictions, verification steps, and how failures alter the plan.
- **Worker:** expected versus actual behavior, experiments, discoveries, supported/challenged claims, and counterexamples.
- **Reviewer:** unsupported explanations, weak tests, missing counterexamples, and overgeneralization.
- **Primary:** integrate evidence, update claim states, decide persistence, and escalate consequential unresolved decisions.

## Task completion output

For Level 1 or higher, include a concise section:

```markdown
## Learning

### Initial material claims
- ...

### Evidence gathered
- ...

### What implementation and tests demonstrated
- ...

### Claim transitions
- C-01: SUPPORTED → VERIFIED_IN_SCOPE (...scope...)
- C-02: PROPOSED → REJECTED

### Reusable knowledge
- Confirmed patterns, with limits
- Generalization candidates that need more evidence

### Counterevidence and unresolved questions
- ...

### Persistence decision
- Ephemeral, or artifact path and reason

### Optional deep dives
1. Topic — value and expected depth
```

Keep routine syntax and unimportant discoveries out of this section.

## Durable knowledge packet

When Level 2 is authorized, prefer:

```text
<topic>/
├── README.md           readable mental model and five-minute summary
├── claims.md           scoped claims and current states
├── evidence.md         source and observation ledger
├── experiments.md      predictions, setups, and outcomes
├── counterexamples.md  limitations and rejected generalizations
├── abstractions.md     patterns and promotion evidence
└── history.md          claim transitions and freshness changes
```

Include source revisions, last verification date, volatility (`stable`, `evolving`, or `experimental`), and refresh triggers. Store workflow templates in portable configuration repositories; store generated internal knowledge only in an authorized private or project-specific location.

## Human escalation

Ask for a decision when evidence cannot resolve product intent, architecture, ownership, security, safety, compatibility, release policy, or a consequential conflict. Present one focused question with evidence, options, consequences, and a recommendation.

Do not ask the human to reconfirm facts already established by canonical evidence.
