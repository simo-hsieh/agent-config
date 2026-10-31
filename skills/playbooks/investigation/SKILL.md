---
name: investigation
description: Playbook for a question about code, a decision, prior work, or an unclear request. Routed from AGENTS.md or forced with /investigation.
disable-model-invocation: true
---

# Playbook: investigation

Answer; change no code and no VCS state.

1. **Route** each question to one skill, running two in parallel when it needs both:

   | Question | Skill |
   |---|---|
   | How does it work, where does it go | `how` |
   | Why is it this way | `why` |
   | Where does my work on X stand | `recall` |
   | What could this change break | `blast-radius` |
   | What do others do, best practice | `auto-research` |
   | Teach me, help me understand | `teach` |

2. **Answer** inline with `file:line` citations and UNVERIFIED marks. For a choice between alternatives, give a recommendation with a trade-off table and your judgment. Only `auto-research` saves a report.
3. **Hand off**: when the answer leads to a code change, stop and route to `bugfix` or `feature`.
