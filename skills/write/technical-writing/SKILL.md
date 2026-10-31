---
name: technical-writing
description: Standard for docs, READMEs, design docs, PR text, and jj descriptions. Loaded by path together with unslop when writing them.
disable-model-invocation: true
---

# Technical writing

Write so a tired engineer understands on the first read. Cut every word that does no work, use the short everyday word, and use the repo's real symbol, file, flag, or command name instead of a description of it. When a rule makes a sentence worse, fix the sentence another way.

## One mode per document

- **Tutorial** (learning by doing): say what the reader will build; every step shows a visible result and what they should see.
- **How-to** (steps to a goal): assume competence; action only; name it by the task ("How to rotate the key").
- **Reference** (facts for lookup): describe only, dry and complete; mirror the structure of the thing described.
- **Explanation** (understanding why): one bounded topic; design decisions, history, constraints, alternatives; opinion belongs only here.

Don't mix modes; split and link.

## Sentences

- Address the reader as "you", in the present tense; active voice.
- Instructions are commands, with the condition first: "To delete the file, run …".
- Common case first, exceptions after.
- One instruction per sentence; split instructions over about 20 words and other sentences over about 25.
- Put a warning before the step it guards.
- One word per meaning and one meaning per word; keep "the" and "a".
- Never "simply", "easy", or "quickly" in a procedure; no pre-announcing future work.
- Vary sentence length; be specific ("a column rename fails the build", not "schema changes can cause issues").

## Layout

- Headings carry the point, in sentence case; a task heading is a verb phrase.
- Numbered lists for sequences, bullets otherwise, introduced by a full sentence, items parallel.
- Code in code font; link text says where it goes, never "click here".
