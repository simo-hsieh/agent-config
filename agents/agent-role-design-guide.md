# Agent role design guide

This guide explains how to design and customize agent roles for different kinds of work. It focuses on role boundaries, prompts, tools, context, authority, outputs, and evaluation—not on the process runtime that executes them.

For runtime implementation, see [`agent-runtime-engineering-guide.md`](agent-runtime-engineering-guide.md). For using the roles currently available in this repository, see [`USER_GUIDE.md`](USER_GUIDE.md).

## Agent role versus agent runtime

An agent role is a declarative operating contract:

```text
role = purpose + knowledge + capabilities + authority + handoff
```

The runtime enforces the parts it can: available tools, context selection, budgets, and process lifecycle. The prompt communicates behavioral policy: priorities, escalation, evidence standards, and output shape.

Do not try to solve runtime security by adding more forceful prose.

## Roles as bounded contexts

The DDD bounded-context analogy is useful. A role should have:

1. **Purpose boundary** — the outcome it owns.
2. **Knowledge boundary** — context it receives and excludes.
3. **Capability boundary** — tools and side effects available.
4. **Authority boundary** — decisions it owns and must escalate.
5. **Handoff contract** — evidence or artifact it returns.

A role is justified when one of these boundaries is materially different from the primary agent. Do not create roles merely to assign different personalities.

## Decide whether a role is needed

| Work situation | Recommended role pattern |
|---|---|
| Small, bounded change | Primary agent; no child |
| Unknown codebase area | Read-only scout |
| Current external fact | Fresh, sanitized researcher |
| Complex approved implementation | Single writer/worker |
| Independent quality check | Read-only reviewer |
| Substantial ordered change | Planner, then explicit approval |
| Consequential or conflicting direction | Advisory oracle |
| Generic extra pair of hands | Do not create a role; clarify the actual boundary |

A role should be reusable across several real tasks. One-off instructions belong in the delegated task, not a permanent role.

## Definition anatomy

A Pi role currently combines harness-specific frontmatter with a Markdown behavioral contract:

```yaml
---
name: reviewer
description: Independently reviews a completed change and reports evidenced findings
tools: read, grep, find, ls, bash
thinking: high
systemPromptMode: replace
inheritProjectContext: true
inheritSkills: false
defaultContext: fresh
acceptanceRole: read-only
---

You are an independent reviewer.

## Purpose
...

## Boundaries
...

## Method
...

## Escalation
...

## Output
...
```

Keep harness metadata in its adapter directory. The behavioral body can remain model-neutral where practical.

## Write descriptions for routing

The description helps the parent select a role. It should state the trigger, responsibility, and differentiator.

Weak:

```yaml
description: Helpful expert agent
```

Strong:

```yaml
description: Read-only external researcher that returns a concise, version-aware brief with primary-source citations
```

Strong descriptions answer:

- When should this role be chosen?
- What output does it produce?
- What important boundary distinguishes it?

Avoid marketing adjectives such as “world-class,” “elite,” or “autonomous.” They do not improve routing.

## Define one owned outcome

A role should have one primary responsibility.

Good:

```text
The reviewer determines whether a completed change has evidenced blockers.
```

Too broad:

```text
The reviewer investigates requirements, chooses an architecture, edits code,
runs deployment, fixes findings, and writes documentation.
```

Broad roles hide authority changes and make independent evaluation impossible.

## Design the knowledge boundary

Ask what information is necessary and what must remain outside.

### Fresh context

Use when:

- Independence matters.
- Parent history would bias the role.
- Privacy requires a sanitized brief.
- The task can be fully stated on its own.

Examples: researcher, independent reviewer.

### Forked context

Use when:

- Earlier decisions are the contract.
- The child must preserve nuanced user requirements.
- Reconstructing context would be expensive or lossy.

Examples: worker executing an approved direction, oracle checking decision drift.

### Explicit handoff

Often better than either extreme:

```text
Goal
Relevant files
Approved decisions
Acceptance criteria
Known risks
Questions requiring escalation
```

Pass the smallest context that allows correct work.

## Design the capability boundary

Start with no tools and add only what the role needs.

| Role | Typical capabilities |
|---|---|
| Researcher | Public search and remote content fetching |
| Scout | Read, search, directory listing, read-only inspection commands |
| Planner | Read/search; optional plan artifact writing |
| Worker | Read, search, shell, edit, write |
| Reviewer | Read, search, read-only shell validation |
| Oracle | Read, search, read-only inspection |

Tool names are not the complete authority model:

- `bash` can mutate even in a read-only role.
- A network extension can read or transmit data if its API permits it.
- A filesystem tool may follow symlinks or access absolute paths.
- Inherited environment variables may contain credentials.

Write behavioral restrictions, but also strengthen the runtime boundary wherever the distinction matters.

## Define authority and escalation

Use concrete decision categories:

```text
The worker may choose local implementation details that follow existing patterns.
It must escalate new product behavior, architecture, compatibility, security,
data migration, dependency, or externally visible decisions.
```

Avoid asking children to escalate every uncertainty. That prevents useful work. Escalate decisions that are:

- Irreversible or expensive to reverse
- Externally visible
- Outside approved scope
- Security or privacy consequential
- Unsupported by available evidence

Progress updates and decision requests are different. Do not block the workflow for routine status messages.

## Specify a method without overscripting

A role needs enough process to be reliable, not a script for every token.

Good reviewer method:

```text
1. Read the request and actual diff.
2. Inspect relevant callers and tests.
3. Verify suspected issues against source or executable checks.
4. Report only substantiated findings, ordered by severity.
```

Overscripted methods become brittle when tasks differ. Keep true invariants in the role and task-specific steps in the delegation request.

## Design the output contract

The output should be directly consumable by the parent or next role.

A useful contract defines:

- Required sections
- Evidence expectations
- Severity or confidence vocabulary
- Whether files may be written
- What uncertainty must be surfaced
- What should be omitted

Example:

```text
## Findings
- Severity
- File and line
- Failure scenario
- Why it matters
- Remediation direction

## Verification
Commands actually run and results.

## Residual risks
Anything not verified.
```

Do not require ceremony that adds no decision value.

## Match model capability to the role

Keep model policy outside portable behavioral text when possible.

| Capability class | Suitable work |
|---|---|
| Fast/low-cost | Scouting, extraction, straightforward classification |
| Balanced | Research, bounded planning, ordinary implementation |
| Strong reasoning | Difficult review, architecture, decision consistency |

Use thinking levels similarly. More reasoning is not automatically better for simple retrieval. Record explicit model overrides because they can bypass cost policy.

## Acceptance is separate from role identity

`acceptanceRole: read-only` tells the runtime how to interpret completion; it does not remove tools.

Define acceptance from observable evidence:

### Researcher

- Claims cite accessible primary sources.
- Applicability identifies relevant versions.
- Conflicting evidence is visible.
- No private context was supplied.

### Worker

- Requested behavior exists.
- Relevant tests were added or updated.
- Verification commands actually ran.
- Changed files stay within scope.
- Residual risks are explicit.

### Reviewer

- Findings reference source evidence.
- No issues are invented to appear useful.
- The reviewer did not modify the implementation.
- Checks not run are disclosed.

The runtime should independently execute high-value verification where practical.

## Role templates by task

### Researcher

```yaml
---
name: researcher
description: Read-only external researcher that resolves sanitized public technical questions with primary-source citations
tools: web_search, fetch_content, get_search_content
defaultContext: fresh
inheritProjectContext: false
inheritSkills: false
acceptanceRole: read-only
---
```

Behavioral contract:

```text
Purpose: resolve one bounded external knowledge gap.
Knowledge: sanitized public question and versions only.
Authority: evaluate evidence; do not change implementation decisions.
Escalation: request sanitized missing facts; stop if private disclosure is required.
Handoff: conclusion, applicability, evidence, conflicts, recommendation.
```

### Scout

```text
Purpose: identify the minimum local code context needed for action.
Knowledge: repository and task; no external assumptions.
Authority: inspect only; do not design or implement unless explicitly requested.
Escalation: report gaps rather than widening scope indefinitely.
Handoff: relevant files, data flow, constraints, tests, start point.
```

### Planner

```text
Purpose: convert approved requirements and sufficient context into executable steps.
Knowledge: requirements, local architecture, scout findings.
Authority: order implementation work; do not invent product decisions.
Escalation: surface unresolved decisions before declaring the plan executable.
Handoff: steps, files, dependencies, risks, and acceptance checks.
```

### Worker

```text
Purpose: implement one approved bounded outcome.
Knowledge: approved task, relevant context, acceptance criteria.
Authority: local implementation choices within existing patterns.
Escalation: new product, architecture, security, compatibility, or scope decisions.
Handoff: changes, validation, residual risks, next step.
```

### Reviewer

```text
Purpose: independently identify evidenced blockers and risks.
Knowledge: request, completed diff, relevant code and tests.
Authority: inspect and report; do not silently fix.
Escalation: report missing requirements or unverifiable assumptions.
Handoff: severity-ordered findings and verification evidence.
```

### Oracle

```text
Purpose: test a proposed direction against inherited decisions and constraints.
Knowledge: decision history, proposal, relevant source evidence.
Authority: advise; do not implement or become the decision owner.
Escalation: ask when a recommendation depends on an unresolved user decision.
Handoff: inherited decisions, diagnosis, contradiction check, recommendation, risks.
```

## Design delegations as task envelopes

The permanent role should remain stable. Each invocation supplies a task envelope:

```text
Goal:
The concrete outcome for this run.

Context:
Only facts and files required by the role.

Constraints:
True invariants, not preferences disguised as requirements.

Success criteria:
Observable conditions for completion.

Escalation:
Specific decisions the child must return to the parent.

Output:
Expected evidence or artifact.
```

Example worker request:

```text
Implement the approved request validation change in the existing parser.
Preserve backward compatibility and do not add dependencies.
Success: targeted parser tests cover valid, invalid, and boundary inputs and pass.
Escalate if the existing public error format must change.
Return changed files, commands run, and residual risks.
```

## Evaluate a role empirically

Review several real runs and ask:

### Routing

- Was the role selected for the right tasks?
- Is its description distinct from other roles?

### Context

- Did it receive unnecessary sensitive or distracting context?
- Did missing context cause rediscovery or guessing?

### Capability

- Were tools missing?
- Were unused tools unnecessarily powerful?

### Authority

- Did it silently make decisions it should have escalated?
- Did it escalate routine implementation details unnecessarily?

### Output

- Could the parent act directly on the result?
- Was evidence distinguishable from claims?
- Did the format create unnecessary verbosity?

Change one dimension at a time. Otherwise model changes, prompt changes, and tool changes become impossible to evaluate separately.

## Portability across harnesses

Separate portable behavior from adapter metadata:

```text
agents/
  role contracts and shared design documentation

pi/agents/
  Pi frontmatter, tool names, context behavior, extension paths

claude/agents/
  Claude-specific permissions and discovery metadata

other adapters/
  harness-specific wrappers only when their contracts are known
```

Do not claim portability merely because two tools accept Markdown. Tool semantics, context inheritance, extension loading, and permission enforcement may differ.

Prefer a generation step only when at least two real adapters share enough behavior to justify it. Before then, small reviewed duplication is safer than a speculative abstraction.

## Patterns to avoid

### Persona without boundary

“Act as a senior expert” does not define context, authority, capabilities, or output.

### Mandatory pipelines

Do not run scout, planner, worker, and reviewer for every change. Each handoff must reduce a named uncertainty.

### Generic delegation

A second copy of the primary agent has no clear authority or specialization. State the actual role needed.

### Parallel writers

Separate agents editing one working tree create lost updates and unclear ownership. Use one writer or explicit isolated workspaces.

### Reviewer-as-fixer

A reviewer modifying the evidence it evaluates weakens independence. Send accepted fixes to the writer.

### Network plus private context by default

Keep external research isolated and sanitized. Do not rely only on a prompt telling a network-enabled child not to disclose data.

### Persistent memory by default

Research ages and prompts can contain untrusted content. Preserve only reviewed durable conclusions.

### Exact provider behavior in the role prompt

Model and provider identifiers change. Keep them in adapter configuration unless behavior truly depends on one provider.

## Role review checklist

- [ ] The description provides a clear routing trigger.
- [ ] The role owns one primary outcome.
- [ ] Its boundary differs materially from the primary agent.
- [ ] Necessary context is explicit; sensitive context is excluded.
- [ ] Tool permissions match the role's authority.
- [ ] Fresh versus forked context is intentional.
- [ ] Allowed decisions and escalation categories are concrete.
- [ ] The method contains invariants, not task-specific micromanagement.
- [ ] The output is directly consumable and evidence-oriented.
- [ ] Acceptance criteria are observable.
- [ ] Model cost matches task difficulty.
- [ ] The role does not duplicate another role.
- [ ] The role works without mandatory orchestration around it.
- [ ] Harness-specific metadata remains in the adapter.
