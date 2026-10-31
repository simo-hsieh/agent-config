---
name: unslop
description: Removes AI writing patterns from durable text. Loaded by path when writing or editing docs, PR text, jj descriptions, or skills.
disable-model-invocation: true
---

# Unslop

Scan for these patterns and rewrite, keeping the meaning and tone.

**Content**
- "-ing" tails that add nothing ("…, highlighting/ensuring/reflecting X"): delete them or back them with a source.
- Vague attribution ("experts believe", "reports suggest"): name the source or delete.
- Generic conclusions ("the future looks bright"): state the plan or fact.

**Words**
- AI vocabulary: additionally, crucial, delve, enhance, foster, garner, intricate, landscape, pivotal, showcase, tapestry, testament, underscore, vibrant. Use the plain word.
- "serves as", "stands as", "boasts", "features": say "is" or "has".
- Fancy words: utilize/leverage (use), facilitate (help), numerous (many), in the event that (if).
- Abstract metaphor nouns: substrate, vector, locus, nexus, primitive, harness or surface or scaffolding as metaphors, paradigm, north star, flywheel, ratchet, endgame. Use the concrete word.
- Synonym cycling: pick one term and repeat it.

**Shape**
- "Not just X, but Y" and forced groups of three: state the point with its natural count.
- False ranges ("from X to Y" off any scale): list the items.
- Em dashes: use a period or comma.
- Colons as mid-sentence connectors; they belong before a list or example.
- Bold on every term; bold-label lists that restate the line ("**Speed:** Speed improved"). A bold lead-in ending in a period followed by new detail is fine.
- Title Case headings: use sentence case. Decorative emojis, curly quotes: remove.

**Voice**
- Chatbot phrases and sycophancy ("Great question!", "I hope this helps"): delete.
- Filler ("in order to", "due to the fact that", "it is important to note"): cut.
- Stacked hedges: one qualifier at most.
- Say what it does, not how it feels: name the mechanism or the number. A sentence that could appear unchanged in another project's docs says nothing; cut it.
- One idea per sentence; split a sentence the reader must reparse.
- Active voice; name the actor. Passive only when the actor is unknown or irrelevant.
- Cut adverbs propping up weak verbs; use the number instead of "significantly".
- Literal over mannered: no aphorisms, personified code, or figurative verbs.
- Whole sentences: no dropped articles or verbless fragments. An arrow chain like `A → B` is fine when a sentence explains it.
