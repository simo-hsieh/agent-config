---
name: why
description: Recovers the intent behind code from git history, committed intent and design docs, and my past prompts. Use for "why is this built this way", "why did we choose X", or before changing code whose rationale is unclear. Read-only.
---

# Why

1. **Anchor** on the target lines and their history: `git blame <path>`, `git log --follow -- <path>`, `git log -L <start>,<end>:<path>`, and `git reflog` for a commit that was reworked.
2. **Search sources in this order:** change descriptions; `docs/**/intent.md` and `design.md` that touch the target; my prompts in this project's Claude Code and Pi transcripts (paths in the `recall` skill). Never read another project's transcripts.
3. **Date every prompt you cite.** A later prompt, change, or doc overrides an earlier prompt. State each conflict as "on <date> you said X; <change> on <date> did Y", and do not resolve it silently.
4. **Label each claim** *stated* (a source says it, cited), *inferred* (give the reasoning), or UNVERIFIED. List the sources you searched that returned nothing.

Change no code and no VCS state.
