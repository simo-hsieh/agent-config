---
name: create-verification-skill
description: Generates a project-local verify-<app> skill that launches the real app, drives a feature the way a user would, and captures evidence. Use for /create-verification-skill.
disable-model-invocation: true
---

# Create a verification skill

Write for the next agent, who reads it cold mid-task and has never seen the app.

1. **Interview the repo**, asking me only what you can't observe:
   - **Surface:** what a user touches (web UI, CLI/TUI, desktop, API, library); pick the primary one.
   - **Run:** the repo's documented dev command, ports, env vars, seed data, auth.
   - **Drive:** existing harnesses first (Playwright, expect scripts, curl-able endpoints, a debug port), then a generic recipe (`agent-browser` for web, a tmux/PTY harness for CLI/TUI, HTTP for services).
   - **Observe:** screenshots, transcripts, response bodies, logs, exit codes, DB state.
   - **Isolate:** whether two instances can run side by side; if not, the skill refuses to drive a shared instance.

   If the checkout doesn't build or start, fix that or report it precisely first.
2. **Write** `verify-<app>/SKILL.md` in the project's `.claude/skills/` and `.agents/skills/`, with frontmatter naming the app, surface, and when to use it, and these sections, grounded in what you found:
   - **Launch:** the exact command, ready means usable (not just a process answering), from an empty data dir, with teardown.
   - **Doctor:** one read-only check that this instance is worth driving (process, version, port ownership, auth).
   - **Drive:** real selectors and commands from this repo, preferring stable handles.
   - **Evidence:** what to capture and where; exercise the real user path, capture the action and the resulting state, verify side effects; check what a dry-run actually skips by observing it.
   - **Cleanup:** kill only what you started; evidence survives cleanup at a named location.
   - **Helpers:** scripts are executable and their invocation is shown.
3. **Seed a feature map**: `features/README.md` plus one file for each of the top 3–5 user features, each with `Sub-features`, `How to get to it (user POV)`, `Driving it with <harness>`, and `Gotchas`. A journey whose precondition is missing reports a failure; never weaken it.
4. **Prove it**: follow the generated skill once end to end (launch, doctor, drive one mapped feature, capture evidence, clean up) and confirm the evidence survived. An unexecuted skill is a draft. List every setup step a stand-in environment did that the real target won't.
5. Point me at `/maintain-verification-skill`.
