# Intent: PII in agent context

Status: idea, not started.

## Problem

Skills send session transcripts and repo content to model providers: `reflect` sends the full transcript to Pi on GPT, `recall` and `why` read transcripts, `interrogate` and `arena` send code to the other model family. Transcripts can contain personal data, credentials pasted by mistake, or internal information.

## Open questions

1. Which content counts as PII or internal for my work, and which providers may see it.
2. Whether to redact before cross-provider sends, and how (deterministic scrub, a digest, or an allowlist).
3. Whether improvement inbox notes need the same treatment.
