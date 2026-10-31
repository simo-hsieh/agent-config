# Playbook: skill-agent-change

For edits to a skill, agent, rule, playbook, or AGENTS.md. Not for scripts or hooks (use `bugfix` or `feature`).

1. **Edit the source** in `~/code/_agent`, never the installed copies. Prefer editing or replacing a line over adding one; remove what the change makes dead.
2. **Keep it thin.** Every line must change behavior. No emphasis words, no duplicated rules, no instructions the model follows by default.
3. **Check.** Run `./install.sh --dry-run`, and re-read the diff against the request.
4. **Report.** What behavior changes and why.
