---
name: decision-doc
description: Lays out a design doc around its decisions (Objective, Background, Design, Detailed design, Alternatives considered) and publishes an interactive decision page for my choices. Use when writing design.md, reviewing a design after something changed, or when I ask for a decision page.
---

# Decision doc

A design doc in five sections. Decisions live in Alternatives considered; Design and Detailed design are what the chosen options add up to, and each paragraph names the decisions it rests on, so a changed decision shows which paragraphs to rewrite.

1. **Objective.** The problem in the requester's words; goals R1…Rn, each testable; non-goals; one end-to-end success run. No solutions.
2. **Background**, built from source and runs before any decision is drafted. One entry per fact: the claim, its citation (`file:line`, commit, or run id), and a state: current, stale (contradicts another source), open, or UNVERIFIED with the check that settles it. Never state a fact from names or docs alone when code exists.
3. **Design.** Opens with "Decisions that need you" (lane A). Then the approach in one or two paragraphs and one diagram of at most six boxes. End each paragraph with its tags, such as `[D1=worktree, D3=raise]`; mark a paragraph resting on an undecided entry provisional.
4. **Detailed design.** One part per component or flow, tagged with its decisions: interfaces, state and failures, measured numbers next to what they measure, pending checks.
5. **Alternatives considered.** One entry per decision:
   - the question and why it matters now;
   - lane: A needs me, B a default I can override, C mine to settle;
   - two to four options, each with what you get, what it costs, and one marked suggested;
   - evidence citations, the paragraphs it changes, and an observable "reopen if".

When a decision changes: update its entry first, rewrite every paragraph tagged with it in the same change, and reopen any decision citing a Background fact that went stale.

## Decision page

When decisions need me, also publish the doc as an interactive page (`Artifact` tool), with the five sections in order:

- Header chips count decisions by lane and name the commit or branch the facts were read at.
- Alternatives is a rail of decisions plus one panel: radio options with gets/costs, the suggested chip, evidence, changes, reopen-if, and a note box. Open on the first lane A decision.
- Design and Detailed design re-render from the current picks, so I see what each choice changes.
- End with a summary to copy and paste back, marking each pick as suggested or changed, with my notes. Keep picks in `localStorage` only.

After I paste the summary back, record the decisions in the doc and apply them.
