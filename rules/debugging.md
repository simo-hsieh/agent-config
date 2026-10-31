# Debugging rules

Read when a fix fails twice or a command keeps failing.

- Stop after two consecutive failures of the same command. Do root-cause analysis (read the actual error, inspect inputs and state) and record what you learned before retrying.
- After five failed fixes for one build or test, stop and tell the user what you tried and what you think is wrong. A command that hangs for over a minute is often a credential or network stall; check that first.
- Fix the root cause rather than layering a workaround. Make the smallest change that makes the failing test pass without weakening it.
- Report a task done only after you checked it with a real command or read of the result, and cite it.
- When a lesson would recur, propose a rule change in your reply instead of editing rules mid-task.
