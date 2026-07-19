# Prompt-to-device evaluation and optimization platform

**Status:** Draft for review

**Owner:** Evaluation platform DRI (assignment required before Phase 0)

**Reviewers:** Product, provisioning, device infrastructure, evaluation, security/privacy

**Last updated:** 2026-07-19

## Review summary

This document proposes a reproducible platform for evaluating the pipeline:

```text
user prompt → generated template → device selection → provisioning → observed outcome
```

The platform separates deterministic experiment execution from agent-assisted diagnosis and optimization. It begins as a repeatable evaluation pipeline and can evolve into a bounded overnight research loop.

### Proposed decisions

1. Model the system as an **evaluation platform with an agent-assisted optimization loop**, not a fully agentic workflow.
2. Keep pipeline execution deterministic and stage-based; use agents only for semantic judgment, diagnosis, candidate proposals, and external research.
3. Evaluate template quality, provisioning reliability, and end-user outcome separately.
4. Version every input, implementation, device state, evaluator, and result.
5. Compare immutable baseline and candidate skill versions through paired experiments and holdout cases.
6. Allow overnight automation to run approved experiments and propose candidates, but not mutate or promote the active baseline initially.
7. Keep device selection policy-driven and reproducible rather than delegated to an LLM.

### Decisions requested from reviewers

- Is the proposed separation of generation, infrastructure, and outcome quality correct for the product?
- Which device states and end-user outcomes can be asserted deterministically?
- What prompt and device evidence is permitted to reach external model providers?
- Who owns candidate promotion, and which gates must always require human approval?
- What nightly model-token and device-hour budgets are acceptable?

## Context

The evaluated system transforms a user prompt into a template that is applied to a selected phone through a provisioning system. Today, a successful or failed provisioning run may not identify whether the cause was:

- Prompt-to-template generation quality
- Template validity
- Device compatibility or state
- Provisioning infrastructure
- Evidence collection
- Evaluation quality

A reliable evaluation system must preserve these distinctions. It must also support repeatable baseline-versus-candidate comparisons before any optimization loop is trusted.

### Assumption

This document assumes the evaluated system converts a user prompt into a provisionable template. Product-specific template fields, device APIs, and expected outcomes remain to be supplied by their owners.

## Goals

1. Reproduce an evaluation from an immutable manifest.
2. Attribute failures to the pipeline stage that produced them.
3. Measure prompt-to-template quality independently from device-lab reliability.
4. Compare a baseline generator or skill with candidate versions under equivalent conditions.
5. Preserve complete lineage for prompts, templates, models, code, devices, evaluators, and results.
6. Support scheduled overnight execution with bounded cost and safe stop conditions.
7. Introduce agents only where judgment or hypothesis generation adds value.
8. Produce reports that a human can use to decide whether a candidate is better.

## Non-goals

1. Automatically deploy or promote generated skill changes in the first versions.
2. Let an agent choose devices, metrics, or promotion criteria after observing results.
3. Replace deterministic validation with an LLM judge.
4. Optimize a single aggregate score at the expense of safety, compatibility, or stability.
5. Build a general-purpose workflow graph engine before the linear pipeline is reliable.
6. Run parallel writers that mutate the same active skill or experiment.
7. Provide production provisioning credentials to research or evaluator agents.

## Terminology

| Term | Definition |
|---|---|
| Test case | Immutable user prompt, constraints, expected invariants, and tags |
| Generator | Model, skill, prompt, parameters, and code that produce a template |
| Baseline | Currently accepted immutable generator version |
| Candidate | Immutable proposed generator or skill version under evaluation |
| Template artifact | Generated template plus schema version, hash, and lineage |
| Experiment manifest | Immutable declaration of cases, variants, devices, repetitions, evaluators, budgets, and policy |
| Run | Execution of one experiment manifest |
| Trial | One test case, generator variant, device profile, and seed combination |
| Attempt | One execution attempt for a trial stage; retries create new attempts |
| Evidence bundle | Logs, device observations, screenshots, state snapshots, and assertions collected from a trial |
| Evaluator suite | Versioned deterministic and semantic evaluators |
| Promotion | Decision to make a candidate the new baseline |

## Design principles

### Reproducibility over autonomy

A run must be explainable from stored inputs and versions. Agents may propose actions, but the experiment manifest determines what executes.

### Append-only evidence

Retries and failures are evidence. New attempts are appended; earlier attempts are never overwritten.

### Stage-specific attribution

Generation defects, device failures, provisioning failures, and evaluator failures remain distinct.

### Immutable candidates

An experiment never rewrites the baseline or candidate it is evaluating. Every modification creates a new candidate version.

### Observable acceptance

Promotion depends on measured gates and independent evidence, not an agent’s claim that its candidate improved.

### Adapter boundaries

Models, device labs, provisioners, artifact stores, and evaluator providers can change behind stable interfaces.

## Proposed architecture

```text
                         ┌──────────────────────────┐
                         │ Test case and skill      │
                         │ version registry         │
                         └────────────┬─────────────┘
                                      │
                                      v
┌───────────┐   ┌──────────────────────────────────────────┐
│ Scheduler │──>│ Experiment control plane                 │
└───────────┘   │ validate manifest / create trials        │
                │ advance state / enforce budgets          │
                └─────┬─────────────┬─────────────┬────────┘
                      │             │             │
                      v             v             v
              ┌─────────────┐ ┌───────────┐ ┌──────────────┐
              │ Generator   │ │ Device    │ │ Evaluator    │
              │ adapter     │ │ lab       │ │ suite        │
              └──────┬──────┘ └─────┬─────┘ └──────┬───────┘
                     │              │              │
                     v              v              v
              Template artifact  Provisioning   Evaluation results
                     │              evidence        │
                     └──────────────┬───────────────┘
                                    v
                         ┌──────────────────────────┐
                         │ Artifact and result      │
                         │ store                    │
                         └────────────┬─────────────┘
                                      v
                         ┌──────────────────────────┐
                         │ Aggregation, comparison, │
                         │ reports, agent analysis  │
                         └──────────────────────────┘
```

### Control plane

The control plane owns:

- Manifest validation
- Trial matrix creation
- State transitions
- Idempotency
- Device leases
- Retry classification
- Budgets and stop conditions
- Result aggregation
- Promotion-policy evaluation

It does not ask an LLM what stage should run next.

### Execution adapters

```ts
interface TemplateGenerator {
  generate(input: GenerationInput): Promise<TemplateArtifact>;
}

interface DeviceLab {
  reserve(request: DeviceRequest): Promise<DeviceLease>;
  reset(lease: DeviceLease): Promise<DeviceSnapshot>;
  release(lease: DeviceLease): Promise<void>;
}

interface Provisioner {
  provision(input: ProvisionInput): Promise<ProvisionResult>;
}

interface EvidenceCollector {
  collect(input: CollectionInput): Promise<EvidenceBundle>;
}

interface Evaluator {
  evaluate(input: EvaluationInput): Promise<EvaluationResult>;
}

interface ArtifactStore {
  put(artifact: Artifact): Promise<ArtifactRef>;
  get(ref: ArtifactRef): Promise<Artifact>;
}
```

Adapters isolate the domain model from model providers, device vendors, provisioning implementations, and storage products.

## Data model

### Test case

```ts
type DataClassification = "public" | "internal" | "restricted";

interface TestCase {
  id: string;
  datasetVersion: string;
  userPrompt: string;
  tags: string[];
  requiredInvariants: Invariant[];
  forbiddenOutcomes: Invariant[];
  privacyClassification: DataClassification;
}

interface ArtifactMetadata {
  id: string;
  contentHash: string;
  classification: DataClassification;
  retentionPolicyId: string;
  storageRegion: string;
  permittedEvaluatorClasses: string[];
}
```

Test cases are immutable within a dataset version. Corrections create a new version. Derived artifacts inherit the highest classification of their inputs unless an approved deterministic redaction step produces a separately classified artifact.

### Generator reference

```ts
interface GeneratorRef {
  codeCommit: string;
  skillVersion: string;
  promptVersion: string;
  modelProvider: string;
  modelId: string;
  modelParameters: Record<string, unknown>;
}
```

The platform must capture all parameters that can affect generation, including seed where supported.

### Template artifact

```ts
interface TemplateArtifact {
  id: string;
  testCaseId: string;
  generator: GeneratorRef;
  schemaVersion: string;
  contentHash: string;
  contentRef: ArtifactRef;
  createdAt: string;
}
```

Large or sensitive content should be stored in the artifact store rather than duplicated in result records.

### Device state

```ts
interface DeviceProfile {
  id: string;
  family: string;
  capabilities: string[];
}

interface DeviceSnapshot {
  deviceId: string;
  profileId: string;
  resetImageVersion: string;
  osVersion: string;
  firmwareVersion?: string;
  provisionerVersion: string;
  healthCheckVersion: string;
  capturedAt: string;
}
```

### Experiment manifest

```ts
interface CaseSelection {
  datasetVersion: string;
  testCaseIds: string[];
  selectionHash: string;
}

interface DeviceStratum {
  profileId: string;
  resetImageVersion: string;
  requiredCapabilities: string[];
  allocationPolicy: "paired" | "randomized-block";
  randomizationSeed: number;
}

interface ExecutionComponentVersions {
  controlPlane: string;
  generatorAdapter: string;
  deviceLabAdapter: string;
  resetController: string;
  provisioner: string;
  evidenceCollector: string;
  evaluatorSuite: string;
}

interface ExperimentManifest {
  id: string;
  createdAt: string;
  cases: CaseSelection;
  baseline: GeneratorRef;
  candidates: GeneratorRef[];
  deviceMatrix: DeviceStratum[];
  repetitions: number;
  generationSeeds: number[];
  expandedTrialPlanHash: string;
  components: ExecutionComponentVersions;
  promotionPolicyVersion: string;
  holdoutGovernancePolicyVersion: string;
  budget: ExperimentBudget;
  stopConditions: StopCondition[];
}
```

A manifest is immutable after execution begins. `selectionHash` commits to the exact ordered case set. `expandedTrialPlanHash` commits to the fully materialized trial matrix after deterministic expansion. The device matrix commits to reset state and allocation policy; component versions commit to the control plane and every adapter that can change execution or evidence.

### Trial and attempt

```ts
interface Trial {
  id: string;
  runId: string;
  testCaseId: string;
  generator: GeneratorRef;
  deviceProfileId: string;
  repetition: number;
  seed: number;
  state: TrialState;
}

interface Attempt {
  id: string;
  trialId: string;
  stage: TrialStage;
  attemptNumber: number;
  status: "running" | "succeeded" | "failed" | "cancelled";
  startedAt: string;
  completedAt?: string;
  failureKind?: FailureKind;
  artifactRefs: ArtifactRef[];
}
```

## Trial lifecycle

```text
QUEUED
  → TEMPLATE_GENERATED
  → TEMPLATE_VALIDATED
  → DEVICE_RESERVED
  → DEVICE_PREPARED
  → PROVISIONED
  → EVIDENCE_COLLECTED
  → EVALUATED
  → FINALIZED
```

Terminal failure classifications:

```text
GENERATION_FAILED
TEMPLATE_INVALID
DEVICE_UNAVAILABLE
DEVICE_UNHEALTHY
DEVICE_RESET_FAILED
PROVISION_FAILED
EVIDENCE_COLLECTION_FAILED
EVALUATION_FAILED
CANCELLED
BUDGET_EXCEEDED
```

### Retry policy

- Retry only errors classified as transient.
- Record every retry as a new attempt.
- Use bounded exponential backoff where applicable.
- Do not retry deterministic template validation failures.
- Release or quarantine an unhealthy device before another trial uses it.
- Preserve the original failure even if a later retry succeeds.

### Idempotency

Each logical stage operation receives a stable idempotency key that does not change across ambiguous retries:

```text
experiment / trial / stage / logical-operation-version
```

Attempts retain separate IDs for audit, but reuse the logical operation key until the control plane has proven that a new side effect is required. After a timeout or lost acknowledgement, the worker must reconcile provider and device state before retrying. Provisioning adapters must support provider-side idempotency or implement an explicit read-before-write reconciliation protocol.

## Device scheduling

Device selection is policy-driven:

1. Filter by required capabilities and approved profile.
2. Exclude unhealthy or quarantined devices.
3. Reserve through a lease with expiry and ownership.
4. Reset to the manifest’s required snapshot.
5. Record exact device state before provisioning.
6. Release or quarantine after evidence collection.

Baseline and candidate trials should use paired or randomized equivalent conditions. Record the randomization seed and candidate pool.

An LLM must not select a favorable device after seeing candidate results.

## Evaluation model

### Layer 1: template-generation quality

Evaluate before using a device where possible:

- Schema validity
- Required-field completeness
- Faithfulness to user intent
- Constraint adherence
- Unsupported assumptions
- Internal consistency
- Static safety policy

### Layer 2: template executability

Evaluate on a controlled device:

- Provisioning success
- Runtime errors
- Retry count
- Provisioning duration
- Device compatibility
- Expected configuration applied

### Layer 3: end-to-end outcome

Evaluate product behavior:

- Requested behavior exists
- Forbidden behavior is absent
- Important requirements are not missing
- Result is stable across repetitions
- Result generalizes across relevant device profiles
- Cost and latency remain acceptable

### Metric vector

```ts
interface MetricVector {
  templateValid: boolean;
  requirementCoverage: number;
  semanticFaithfulness: number;
  unsupportedAssumptions: number;
  provisionSucceeded: boolean;
  provisionRetries: number;
  provisionLatencyMs: number;
  deviceStateCorrectness: number;
  regressionCount: number;
  resultStability: number;
  modelCost: number;
  totalDurationMs: number;
}
```

The platform may present a summary score, but promotion uses the underlying vector and hard gates.

### Measurement contract

Before Phase 2, every metric must define:

- Unit and scale, including which direction is better.
- Trial-level numerator and denominator.
- Aggregation across cases, repetitions, and device strata.
- Treatment of missing results and infrastructure failures.
- Minimum sample size.
- Paired comparison method for baseline and candidate.
- Uncertainty interval and decision threshold.

Infrastructure failures are excluded from generator-quality denominators only when independently classified, but remain visible in platform-health metrics. Promotion comparisons use paired trial deltas within equivalent device strata. The initial statistical method and thresholds are an explicit Phase 2 review decision; reports must not claim significance before that contract is approved.

## Evaluator suite

### Deterministic evaluators

Preferred whenever the expected result can be expressed as code:

- Template schema validation
- Required and forbidden field checks
- Static safety checks
- Provisioning exit and error classification
- Device-state assertions
- Runtime health checks
- Latency, retries, and resource use

### Semantic evaluator

An LLM evaluator may assess faithfulness, missing intent, unsupported assumptions, and subjective usefulness.

Requirements:

- Blind to baseline/candidate identity.
- Receive equivalent evidence for every variant.
- Use a versioned rubric and structured result schema.
- Cite the evidence supporting each judgment.
- Report confidence and uncertainty.
- Be calibrated against human-labeled cases.
- Never be the sole safety or promotion gate.

### Failure attribution

Evaluation must separately classify:

```text
generator defect
invalid template
unsupported device capability
flaky device infrastructure
provisioner defect
evidence-collection defect
evaluator defect
unknown
```

Infrastructure failures do not count as generator-quality failures, but their rate remains visible as an operational metric.

## Dataset strategy

Maintain independently versioned sets:

| Dataset | Visibility and purpose |
|---|---|
| Development | Visible to candidate designers; fast iteration |
| Holdout | Hidden from candidate generation; promotion evidence |
| Regression | Cases derived from previous failures |
| Challenge | Periodically refreshed edge cases |
| Human calibration | Labeled cases used to validate semantic evaluators |
| Final promotion | Untouched cases used only for release-level promotion decisions |

Do not alter a dataset version after observing candidate performance. Do not expose holdout prompts or labels to candidate-generating agents.

### Holdout governance

- Candidate designers receive aggregate development results, not holdout case-level feedback.
- Holdout evaluation is limited to candidates that pass development hard gates.
- Repeated holdout access is counted and audited; exceeding the cadence in the versioned holdout governance policy retires the set from promotion use.
- Per-case holdout details are restricted to evaluation owners and are not returned to candidate agents.
- A final promotion set remains untouched until a release-level decision.
- Holdout and final-promotion sets are periodically refreshed under a new dataset version.

## Agent boundaries

Agents augment the platform; they do not own execution truth.

### Experiment designer

**Input:** Evaluation objective, available datasets, device profiles, and budget.

**Output:** Proposed immutable experiment manifest and rationale.

**May not:** Change a running manifest, metrics, or promotion criteria.

### Candidate designer

**Input:** Baseline, development failures, modification constraints.

**Output:** New immutable skill/prompt candidate, hypothesis, expected effect, and risks.

**May not:** Modify the active baseline or inspect holdout cases.

### Failure analyst

**Input:** Completed traces, stage failures, metrics, and evidence.

**Output:** Failure clusters, evidence-backed diagnosis, uncertainty, and candidate hypotheses.

**May not:** Reclassify failures without preserving original evidence.

### Semantic evaluator

**Input:** Blinded test case, template, and allowed outcome evidence.

**Output:** Structured rubric result with evidence and confidence.

**May not:** Know variant identity or promote a candidate.

### External researcher

**Input:** Sanitized public technical question.

**Output:** Version-aware evidence with primary-source citations.

**May not:** Receive private prompts, device traces, customer data, or internal identifiers.

## Optimization loop

```text
immutable baseline
  → analyze development results
  → propose immutable candidates
  → static validation
  → development-set comparison
  → eliminate clear losers
  → holdout comparison
  → evaluate quality, safety, cost, and stability gates
  → promotion recommendation
  → human decision
  → new immutable baseline
```

### Promotion policy

```ts
interface MetricGate {
  metric: keyof MetricVector;
  scope: "overall" | "device-stratum" | "test-case";
  operator: ">=" | "<=" | "no-regression";
  threshold?: number;
  minimumSamples: number;
  confidenceLevel?: number;
}

interface PromotionPolicy {
  qualityGates: MetricGate[];
  safetyGates: MetricGate[];
  compatibilityGates: MetricGate[];
  stabilityGates: MetricGate[];
  maximumCostIncreasePercent: number;
  maximumInfrastructureFailureRate: number;
  requireDevelopmentPass: boolean;
  requireHoldoutPass: boolean;
  requireFinalPromotionSetPass: boolean;
  requireHumanApproval: boolean;
}
```

A candidate cannot offset a hard safety, compatibility, or stability regression with improvements in another metric. Missing or under-sampled gates produce `insufficient-evidence`, never an automatic pass.

## Overnight execution

### Initial nightly mode

```text
scheduler
  → run approved immutable manifests
  → aggregate metrics
  → classify infrastructure failures
  → produce morning report
```

### Later bounded research mode

The overnight system may:

- Analyze completed development results.
- Propose at most a configured number of candidates.
- Run static validation.
- Execute approved development experiments.
- Eliminate candidates that fail hard gates.
- Produce a ranked morning report.

It may not initially:

- Change the active baseline.
- Deploy to production.
- Access unrestricted device pools.
- Change evaluation rubrics or promotion policy.
- Reveal holdout cases to candidate agents.
- Exceed model-token, device-hour, candidate-count, or runtime budgets.

## Reliability and operations

### Concurrency

- One active lease per physical device.
- Bounded generation and evaluation concurrency.
- Device capacity enforced centrally across experiments.
- Candidate trials randomized or balanced to avoid time-of-day and device-order bias.

### Stop conditions

An experiment stops when:

- Budget is exhausted.
- Infrastructure failure rate exceeds a threshold.
- A candidate violates a hard safety gate.
- Required device capacity is unavailable beyond the deadline.
- Cancellation is requested.

### Observability

Record:

- Stage duration and queue time
- Attempts and retry causes
- Device utilization and quarantine rate
- Generator and evaluator model usage/cost
- Provision success and failure taxonomy
- Artifact lineage
- Candidate versus baseline metric deltas
- Promotion-policy outcome

Dashboards should distinguish experiment quality from platform health.

## Security and privacy

1. Classify prompts and evidence before sending them to a model provider.
2. Propagate the highest input classification to templates, evidence, evaluator inputs, reports, and agent artifacts by default.
3. Permit classification downgrade only through an approved deterministic redaction transform that emits a new artifact and audit record.
4. Enforce provider, region, retention, and evaluator routing from artifact metadata in the control plane; fail closed when no route is approved.
5. Route restricted cases only to approved providers or local models.
6. Keep device and production credentials out of agent environments.
7. Redact secrets, user identifiers, and internal endpoints from model inputs and reports.
8. Treat generated templates and web content as untrusted inputs.
9. Restrict artifact access and retention by classification.
10. Audit manifest creation, candidate creation, experiment execution, classification changes, and promotion decisions.
11. Require project/device authorization independently from an agent’s request.

## Cost controls

Every manifest specifies:

- Maximum generated templates
- Maximum candidate count
- Maximum model tokens or spend
- Maximum device hours
- Maximum repetitions
- Maximum retries per stage
- Maximum wall-clock duration

The control plane enforces budgets. Agents cannot increase them.

## Reporting

A reviewable experiment report contains:

1. Manifest and lineage summary
2. Baseline and candidate definitions
3. Dataset and device coverage
4. Stage-specific failure counts
5. Metric vector comparison
6. Per-case regressions and improvements
7. Statistical uncertainty and repetition count
8. Infrastructure-health summary
9. Semantic evaluator calibration status
10. Agent diagnoses clearly labeled as inference
11. Promotion-policy result
12. Human decision and rationale, when made

## Rollout plan

### Phase 0: measurement contract

- Define template schema and invariant language.
- Define trial states and failure taxonomy.
- Define artifact lineage and privacy classification.
- Curate 10–30 representative development prompts.

**Exit criterion:** Reviewers agree that failures can be attributed consistently.

### Phase 1: reproducible single-profile pipeline

- Freeze one baseline generator.
- Support one simulator or controlled phone profile.
- Add deterministic device reset and health checks.
- Add template validation, provisioning, evidence collection, and reporting.
- Run one approved manifest repeatedly.

**Exit criterion:** Repeated runs produce explainable results and expose infrastructure flakiness.

### Phase 2: baseline/candidate experiments

- Add immutable candidate versions.
- Add paired trials, repetitions, and randomization.
- Add metric vectors and hard promotion gates.
- Introduce holdout and regression datasets.

**Exit criterion:** Candidate comparisons are stable enough to guide a human decision.

### Phase 3: nightly evaluation

- Schedule approved manifests.
- Add budgets and stop conditions.
- Produce morning reports and alerts.
- Add failure-analysis agent after evidence quality is reliable.

**Exit criterion:** Nightly runs complete unattended without changing baselines or hiding failures.

### Phase 4: bounded optimization research

- Add candidate-design agent.
- Limit candidate count and modification scope.
- Evaluate on development cases, then holdouts for survivors.
- Produce promotion recommendations.

**Exit criterion:** Agent-generated candidates improve human-reviewed outcomes without holdout degradation or metric gaming.

### Phase 5: policy-controlled promotion

Consider limited automatic promotion only after evaluator calibration, rollback, privacy, audit, and safety gates are independently validated.

## Alternatives considered

### Fully agentic orchestration

An agent chooses stages, devices, retries, evaluators, and next experiments.

**Rejected initially:** Difficult to reproduce, vulnerable to metric changes and favorable device selection, and hard to distinguish reasoning errors from infrastructure failures.

### Provision-success-only evaluation

Use successful provisioning as the quality signal.

**Rejected:** Conflates generation quality with device and provisioning reliability and misses semantically wrong but executable templates.

### Single aggregate reward

Optimize one weighted score.

**Rejected:** Hides regressions and invites evaluator gaming. Metric vectors with hard gates are easier to review.

### Immediate self-improving loop

Allow an agent to rewrite and promote the active skill overnight.

**Rejected:** Creates uncontrolled mutation, overfitting, weak auditability, and unsafe self-approval.

### General workflow engine first

Build arbitrary DAG orchestration before implementing the pipeline.

**Rejected:** Adds complexity before the domain states, failure taxonomy, and idempotency requirements are known.

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Device state confounds generator quality | Reset snapshots, paired trials, repetitions, recorded state |
| Infrastructure retries hide flakiness | Append-only attempts and separate infrastructure metrics |
| LLM evaluator rewards style | Deterministic checks, blinded rubric, human calibration |
| Candidate overfits visible cases | Hidden holdouts, regressions, refreshed challenges |
| Agent mutates active baseline | Immutable versions and separate promotion authority |
| Private data reaches external provider | Classification, redaction, provider policy, isolated research |
| Metrics change after results | Versioned evaluator suite and immutable manifest |
| Overnight cost becomes unbounded | Control-plane budgets and stop conditions |
| One score masks regression | Metric vector and hard gates |
| Multiple agents add coordination noise | Add roles only for named judgment or hypothesis gaps |

## Open questions

Questions marked Phase 0 or Phase 1 block that phase's exit criterion. Later questions may remain open until their target phase.

| Question | Decision owner | Target phase |
|---|---|---|
| Which user outcomes define a successful provisioned phone? | Product | Phase 0 |
| Which requirements can be expressed as deterministic invariants? | Product + Evaluation | Phase 0 |
| What constitutes a safety or compatibility blocker? | Product + Security | Phase 0 |
| Can every supported device be reset to a named reproducible snapshot? | Device infrastructure | Phase 1 |
| What health checks determine whether a device is eligible? | Device infrastructure | Phase 1 |
| Which device profiles must candidates generalize across? | Product + Device infrastructure | Phase 1 |
| What human-labeled data exists for semantic evaluator calibration? | Evaluation | Phase 2 |
| What paired comparison and uncertainty method will govern promotion? | Evaluation | Phase 2 |
| How many repetitions are required by device stratum? | Evaluation + Device infrastructure | Phase 2 |
| Which metric gates are absolute versus comparative? | Product + Evaluation | Phase 2 |
| How are prompts and collected evidence classified? | Privacy + Security | Phase 0 |
| Which model providers and regions are approved for each classification? | Privacy + Security | Phase 1 |
| What artifact retention period applies to each classification? | Privacy + Legal | Phase 1 |
| What nightly token, spend, and device-hour budgets are acceptable? | Operations + Finance | Phase 3 |
| Who responds to quarantined devices and infrastructure alerts? | Device infrastructure + Operations | Phase 3 |
| Who owns promotion and rollback decisions? | Product + Operations | Phase 2 |

## Review checklist

- [ ] Goals and non-goals match the intended product.
- [ ] Stage boundaries attribute failures correctly.
- [ ] Data lineage is sufficient to reproduce a result.
- [ ] Device scheduling removes avoidable confounding variables.
- [ ] Evaluation layers cover template, execution, and user outcome quality.
- [ ] Deterministic checks are preferred over semantic judgment where possible.
- [ ] Agents have explicit inputs, authority, and prohibited actions.
- [ ] Holdouts and immutable candidates prevent obvious overfitting.
- [ ] Nightly operation has budgets, stop conditions, and no implicit promotion.
- [ ] Security and privacy controls match prompt and device-data sensitivity.
- [ ] Rollout begins with the smallest reproducible pipeline.
- [ ] Open questions have named owners before implementation begins.
