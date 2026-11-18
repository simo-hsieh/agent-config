# ~/code/_agent

This repo is the source of the agent instructions, skills, and harness adapters that `./install.sh` publishes. Every session already has the shared rules from `shared/AGENTS.md`; these lines add only what is true in this repo.

- Edit sources here, never installed copies: `shared/AGENTS.md` for rules every harness follows, `<harness>/harness.md` for rules true in one harness (a tool, flag, path, mode, search engine, or model list only it has; at most about 12 lines), and `<harness>/README.md` for versions, log paths, and repair steps.
- When a harness keeps overriding a shared rule (through its memory or built-in prompt), fix the shared rule instead of adding an exception.
- Skills live in `skills/<intent>/<name>/SKILL.md`; names are unique across intents.
- Record decisions in `docs/agent-flow/<topic>/intent.md` and `design.md`, and update them in the same commit as the change they describe.
- Before committing, run `./install.sh --dry-run`. `./install.sh` publishes only committed work; `--rev <commit>` rolls back.
