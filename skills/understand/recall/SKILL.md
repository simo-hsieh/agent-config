---
name: recall
description: Briefs where my work on a topic stands, from my recent Claude Code and Pi session transcripts plus jj state. Use before starting or resuming a topic, or for "what was I doing on X", "where did we leave X". Read-only.
---

# Recall

1. **Scope.** Window (default 7 days), topic, and the current project only. State the scope back before searching.
2. **Transcripts.**
   - Claude Code: `~/.claude/projects/<cwd with / and _ replaced by ->/*.jsonl`
   - Pi: `~/.pi/agent/sessions/--<cwd with / replaced by ->--/<ISO-time>_<id>.jsonl`

   Order by modification time, grep the topic, read only matching regions, and skip the current session. With more than 3 matching sessions, give each subagent one slice.
3. **Verify** every thread against live `jj log` and `jj status`.
4. **Brief:**
   - Capsule: at most 5 bullets.
   - Threads, each tagged `[pushed <bookmark>]`, `[local <change-id>]`, `[abandoned]`, or `[planned]`.
   - Problems: at most 5, including reverted attempts.
   - Next move: one action.
