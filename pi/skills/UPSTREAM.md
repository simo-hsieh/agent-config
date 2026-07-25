# Vendored Google Workspace CLI skills

The `gws-shared` and `gws-drive-upload` skill files are based on [`googleworkspace/cli`](https://github.com/googleworkspace/cli) at commit `a3768d0e82ad83cca2da97724e46bea4ff0e6dbd` (release `0.22.5`). `gws-shared` includes a reviewed correction to its zsh quoting example; `gws-drive-upload` is copied without modification.

They are licensed under Apache-2.0; see [`googleworkspace-cli.LICENSE`](googleworkspace-cli.LICENSE).

Only the shared reference and upload skill are vendored. The upload skill's optional `gws-drive` “See Also” target is therefore absent; it is not a runtime prerequisite.

## Reviewed integration notes

- Pi follows skill-directory symlinks and discovers both `~/.pi/agent/skills/` and `~/.agents/skills/`; see Pi's [skills documentation](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md).
- Use an explicit Drive scope URL for OAuth. Google Workspace CLI [issue #138](https://github.com/googleworkspace/cli/issues/138) reports that the `--services`/`-s` selector can still request broader scopes.
- `gws drive +upload` does not provide an interactive confirmation prompt. Confirmation is an agent-workflow requirement in the vendored skill, not a CLI enforcement boundary.
