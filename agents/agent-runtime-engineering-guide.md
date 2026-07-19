# Agent runtime engineering guide

This guide explains how to build the runtime that discovers agent definitions, resolves their permissions and context, launches child model sessions, supervises execution, and evaluates results.

For designing the role definitions consumed by a runtime, see [`agent-role-design-guide.md`](agent-role-design-guide.md). For using this repository's existing roles, see [`USER_GUIDE.md`](USER_GUIDE.md).

## Scope and reference implementation

The local reference implementation is the pinned `pi-subagents` package:

```text
pi-subagents 0.35.1
commit d6e8005e3958adea634bf27c615abac7407aedc4
Pi 0.80.10
```

The package is a useful source study, not a template to copy wholesale. Its runtime supports many features and is much larger than a minimal internal harness.

## Mental model

An agent runtime is a policy-enforcing process supervisor:

```text
agent definition
  → discover
  → parse and validate
  → apply precedence and policy
  → resolve a concrete run
  → create an isolated child session
  → supervise lifecycle
  → collect structured evidence
  → evaluate acceptance
  → return the result to the parent
```

Markdown supplies behavior and declarative metadata. The runtime supplies the operational boundary.

## Core architecture

Keep the runtime divided into modules with narrow responsibilities:

```text
Definitions     parse trusted role configuration
Discovery       locate definitions and select precedence
Resolution      produce one immutable execution contract
Context         prepare fresh/forked inputs and prompt material
Capabilities    select tools, extensions, credentials, and filesystem scope
Execution       spawn and supervise a child process
Protocol        consume events and carry parent-child messages
Orchestration   single, parallel, or sequential execution
Acceptance      distinguish claims from independently checked evidence
Artifacts       retain only necessary logs and outputs
```

The most important separation is between pure resolution and effectful execution.

## Start with typed contracts

```ts
type ContextMode = "fresh" | "fork";
type ThinkingLevel = "low" | "medium" | "high";
type AcceptanceRole = "read-only" | "writer";

interface AgentSpec {
  name: string;
  description: string;
  systemPrompt: string;
  tools: string[];

  model?: string;
  thinking?: ThinkingLevel;
  context: ContextMode;
  inheritProjectContext: boolean;
  inheritSkills: boolean;

  acceptanceRole: AcceptanceRole;
  maxRuntimeMs: number;
  maxTurns: number;
}

interface RunRequest {
  agent: string;
  task: string;
  cwd: string;
  parentSession?: string;
  signal?: AbortSignal;
}

interface ResolvedRun {
  runId: string;
  agent: string;
  task: string;
  cwd: string;
  model: string;
  thinking?: ThinkingLevel;
  tools: string[];
  context: ContextMode;
  systemPrompt: string;
  maxRuntimeMs: number;
  maxTurns: number;
}

interface AgentEvidence {
  changedFiles: string[];
  commandsRun: string[];
  validationOutput: string[];
  residualRisks: string[];
}

interface AgentResult {
  status: "completed" | "failed" | "cancelled" | "rejected";
  output: string;
  evidence?: AgentEvidence;
  model?: string;
  error?: string;
  durationMs: number;
}
```

Keep these contracts independent from any specific model provider. Provider translation belongs at the execution adapter boundary.

## Definition parsing and validation

Treat agent files and settings as trusted executable configuration, but still validate them strictly. A definition may name extensions, tools, output paths, or commands that become runtime capabilities.

Validation should reject:

- Unknown required fields or malformed types.
- Duplicate runtime names at the same precedence.
- Unsupported context or thinking values.
- Invalid model identifiers when strict resolution is requested.
- Relative paths that escape their allowed base.
- Tool names that are unavailable.
- Negative or unbounded budgets.

Prefer a real parser plus schema validation for new systems. The reference package's partial frontmatter parser is intentionally limited, so unusual YAML should not be assumed to work.

## Deterministic discovery and precedence

A useful precedence model is:

```text
builtin < package < user < trusted project
```

Make selection explicit:

```ts
function selectAgent(
  builtin: AgentSpec | undefined,
  packageAgent: AgentSpec | undefined,
  user: AgentSpec | undefined,
  project: AgentSpec | undefined,
): AgentSpec | undefined {
  return project ?? user ?? packageAgent ?? builtin;
}
```

Only load project definitions after project trust is established. Report collisions rather than silently depending on filesystem order.

Distinguish three operations:

- **Replacement:** a higher-precedence definition owns the complete role.
- **Override:** selected fields change while the original role remains authoritative.
- **Default:** fills only fields the role did not specify.

Document precedence per field. Ambiguous object spreading becomes a security problem when it changes tools or context inheritance.

## Pure resolution before execution

```ts
function resolveRun(
  spec: AgentSpec,
  request: RunRequest,
  policy: RuntimePolicy,
): ResolvedRun {
  validateRequest(request, policy);

  return Object.freeze({
    runId: crypto.randomUUID(),
    agent: spec.name,
    task: request.task,
    cwd: resolveAllowedCwd(request.cwd, policy),
    model: resolveModel(spec.model, policy),
    thinking: spec.thinking,
    tools: resolveTools(spec.tools, policy),
    context: spec.context,
    systemPrompt: buildSystemPrompt(spec, request, policy),
    maxRuntimeMs: Math.min(spec.maxRuntimeMs, policy.maxRuntimeMs),
    maxTurns: Math.min(spec.maxTurns, policy.maxTurns),
  });
}
```

Resolution should be deterministic and unit-testable without starting a model.

## Capabilities: reject broadening

An invocation may narrow a role's tools but should not silently broaden them:

```ts
function narrowTools(allowed: string[], requested?: string[]): string[] {
  if (!requested) return allowed;

  const unauthorized = requested.filter(tool => !allowed.includes(tool));
  if (unauthorized.length > 0) {
    throw new Error(`Unauthorized tools: ${unauthorized.join(", ")}`);
  }

  return requested;
}
```

Apply the same principle to:

- Extensions
- Network access
- Model providers
- Filesystem roots
- Credential sets
- Nested delegation
- Verification commands

An allowlist is meaningful only if lower-trust configuration cannot replace it with a broader list.

## Context construction

### Fresh context

Use for independent review, external research, privacy isolation, and tasks that need only an explicit brief.

A fresh child should receive:

- Its role prompt
- The assigned task
- Explicitly attached files or facts
- Required runtime metadata

It should not implicitly receive parent history.

### Forked context

Use when a worker or decision advisor must preserve prior requirements and approved decisions. Filter orchestration metadata and previous child transcripts that do not help the child.

Do not claim that prompt-section removal creates a security boundary. If sensitive context must not cross, do not place it in the child session.

## Process execution

Spawn a child with argument arrays rather than a shell command:

```ts
import { spawn } from "node:child_process";

function spawnAgent(run: ResolvedRun) {
  const promptPath = writeSecurePromptFile(run.systemPrompt);
  const args = [
    PI_CLI_PATH,
    "--mode", "json",
    "--model", run.model,
    "--tools", run.tools.join(","),
    "--system-prompt", promptPath,
    `Task: ${run.task}`,
  ];

  return spawn(process.execPath, args, {
    cwd: run.cwd,
    shell: false,
    stdio: ["ignore", "pipe", "pipe"],
    env: buildChildEnvironment(run),
  });
}
```

Security and reliability requirements:

- Avoid shell interpolation.
- Use secure temporary files for large or sensitive prompts.
- Set temporary-file permissions to user-only.
- Use an explicit working directory.
- Do not inherit stdin.
- Truncate captured output.
- Remove temporary files in `finally`.

## Environment and credentials

Treat environment variables as a versioned internal protocol. Namespace them and document each field.

```ts
function buildChildEnvironment(run: ResolvedRun): NodeJS.ProcessEnv {
  return {
    PATH: process.env.PATH,
    HOME: process.env.HOME,
    AGENT_RUNTIME_CHILD: "1",
    AGENT_RUNTIME_RUN_ID: run.runId,
    AGENT_RUNTIME_AGENT: run.agent,
    AGENT_RUNTIME_MAX_TURNS: String(run.maxTurns),
  };
}
```

Do not copy the complete parent environment by default. Explicitly provide the credentials required by the role. A read-only role that inherits cloud credentials may have more authority than its tool list suggests.

## Event protocol

Use structured events rather than scraping terminal prose:

```ts
type ChildEvent =
  | { type: "started"; runId: string }
  | { type: "message"; text: string }
  | { type: "tool-start"; name: string; callId: string }
  | { type: "tool-end"; name: string; callId: string; failed: boolean }
  | { type: "usage"; input: number; output: number }
  | { type: "completed"; output: string }
  | { type: "failed"; error: string };
```

Bound line length, total bytes, malformed-event count, and buffered output. Protocol limits are part of denial-of-service protection.

## Cancellation and cleanup

Cancellation is a lifecycle, not one `kill()` call:

```text
abort requested
  → stop accepting new work
  → SIGINT and grace period
  → SIGTERM and grace period
  → SIGKILL
  → close streams
  → remove temporary resources
  → release semaphore capacity
```

Connect cancellation to:

- User abort
- Parent shutdown
- Timeout
- Turn or tool budget
- Protocol overflow
- Chain failure when fail-fast is enabled

Every resource acquired before spawn must have a cleanup owner.

## Budgets and recursion

Enforce budgets before reserving work and again at the child boundary:

```ts
function assertDepth(current: number, maximum: number): void {
  if (current >= maximum) {
    throw new Error(`Subagent depth ${current} reached maximum ${maximum}`);
  }
}
```

Useful limits:

- Maximum depth
- Spawns per parent session
- Concurrent children
- Parallel task count
- Runtime
- Assistant turns
- Tool calls
- Output bytes

Use one global semaphore across single, parallel, and chained paths so no orchestration mode bypasses capacity.

## Orchestration shapes

Implement in this order:

1. **Single child** — the essential primitive.
2. **Bounded parallel reads** — independent tasks with a shared semaphore.
3. **Sequential chain** — explicit output passed to the next stage.
4. **Isolated writers** — worktrees or another mergeable workspace.
5. **Dynamic fanout** — only after a demonstrated need.

Do not build a graph engine before the single-child lifecycle is reliable.

## Supervisor communication

Use a structured, correlated channel:

```ts
interface SupervisorRequest {
  requestId: string;
  runId: string;
  agent: string;
  reason: "need-decision" | "progress";
  message: string;
}

interface SupervisorReply {
  requestId: string;
  decision: string;
}
```

Validate run ownership and capability tokens. A child should not be able to guess another parent's communication target. Decision requests may block with timeout and cancellation; progress updates should normally be fire-and-forget.

## Acceptance and evidence

Separate levels of confidence:

```text
attested  child returned a parseable structured report
checked   runtime validated required criteria and structure
verified  runtime independently executed configured checks
reviewed  a separate reviewer supplied a no-blocker result
```

A child's statement that tests passed is not independent verification.

```ts
async function evaluateAcceptance(
  report: AgentEvidence,
  policy: AcceptancePolicy,
): Promise<AcceptanceResult> {
  validateEvidenceShape(report);
  validateRequiredCriteria(report, policy.criteria);

  const verifyRuns = [];
  for (const command of policy.verify) {
    verifyRuns.push(await runVerification(command));
  }

  return verifyRuns.every(run => run.exitCode === 0)
    ? { status: "verified", verifyRuns }
    : { status: "rejected", verifyRuns };
}
```

Verification commands are executable configuration. Keep them trusted, bounded, and visible.

## Artifacts and privacy

Record enough to diagnose failures:

- Run identity and role
- Resolved model
- Duration and usage
- Exit and cancellation reason
- Tool count
- Acceptance ledger
- Optional transcript

Do not persist full prompts, source code, environment variables, or web research by default. Make sensitive artifacts opt-in, user-scoped, permission-restricted, and easy to delete.

## Testing strategy

### Unit tests

- Definition parsing and validation
- Precedence and override behavior
- Tool narrowing
- Model resolution
- Depth and budget calculations
- Acceptance state transitions

### Integration tests

- Child starts and emits valid events
- Cancellation kills the process tree
- Timeout escalates correctly
- Temporary resources are removed
- Fresh context excludes parent history
- Unavailable tools fail preflight
- Parallel paths respect the global semaphore

### Adversarial tests

- Project definition requests unauthorized extensions
- Child emits oversized or malformed events
- Nested child attempts to bypass depth through another mode
- Reviewer attempts a mutating tool
- Network child receives sensitive inherited context
- Acceptance report claims commands that were never independently run

### End-to-end tests

- Worker changes a temporary repository and produces evidence
- Reviewer receives the final diff without mutation tools
- Researcher receives only a sanitized task and child-only network extension
- Parent cancellation leaves no child process or temporary worktree

## Incremental implementation roadmap

### Stage 1: reliable single child

```text
discover → validate → resolve → spawn → cancel → collect
```

### Stage 2: boundaries

```text
tool allowlists → context modes → credential selection → budgets
```

### Stage 3: evidence

```text
structured result → acceptance ledger → independent verification
```

### Stage 4: coordination

```text
supervisor requests → bounded parallelism → explicit chains
```

### Stage 5: optional complexity

```text
worktrees → resumability → background jobs → dynamic fanout
```

Stop at the earliest stage that solves the real work problem.

## Reference source map

Within the pinned `pi-subagents` repository:

| Topic | File |
|---|---|
| Frontmatter | `src/agents/frontmatter.ts` |
| Discovery and overrides | `src/agents/agents.ts` |
| Precedence | `src/agents/agent-selection.ts` |
| Main resolved execution | `src/runs/foreground/execution.ts` |
| Child arguments/environment | `src/runs/shared/pi-args.ts` |
| Executable selection | `src/runs/shared/pi-spawn.ts` |
| Prompt/context runtime | `src/runs/shared/subagent-prompt-runtime.ts` |
| Chains and bounded parallelism | `src/runs/foreground/chain-execution.ts` |
| Depth limits | `src/shared/types.ts` |
| Acceptance | `src/runs/shared/acceptance.ts` |
| Supervisor channel | `src/intercom/native-supervisor-channel.ts` |

## Runtime review checklist

- [ ] Definitions are schema-validated.
- [ ] Precedence is deterministic and documented.
- [ ] Project configuration requires trust.
- [ ] Invocation can narrow but not silently broaden capabilities.
- [ ] Resolution is pure and separately testable.
- [ ] Child processes do not use shell interpolation.
- [ ] Credential inheritance is explicit.
- [ ] Fresh context truly omits parent history.
- [ ] Cancellation terminates the process tree and cleans resources.
- [ ] All execution modes share central capacity limits.
- [ ] Output and event streams are bounded.
- [ ] Acceptance distinguishes claims from independent evidence.
- [ ] Parent-child messages are authenticated and correlated.
- [ ] Sensitive artifacts are opt-in.
- [ ] Optional orchestration exists only for demonstrated use cases.
