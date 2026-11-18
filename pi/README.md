# Pi adapter

`./install.sh pi` installs `shared/AGENTS.md` followed by `pi/harness.md` as `~/.pi/agent/AGENTS.md`, the `researcher` agent definition, and `subagents.json` (no depth, spawn, or parallelism caps) as the subagent extension's config. Pi runs GPT-6.1 Sol (thinking) and Terra (fast) per `models.md`.

`settings.json` is a template. `--with-settings` links it as `~/.pi/agent/settings.json`, but Pi writes changelog fields into that file at runtime, so on this Mac the live file is a copy kept in step by hand. The template pins `pi-web-access` with no `extensions` or `skills` filter; an empty filter (`[]`) loads nothing, which is how `web_search` went missing before 2026-11-19. Sessions start with only `web_enable`; calling it adds `web_search` and the fetch tools. `~/.pi/web-search.json` (the legacy path the package still reads when `~/.pi/agent/web-search.json` is absent) must set `"provider": "openai"` so `web_search` uses OpenAI search through the ChatGPT subscription; with `brave` it searches the same index as Claude Code and `auto-research` loses an engine. The installer does no network installs; after a package change run `pi update --extensions`.

Pi has no built-in subagents. `pi-subagents` is not in the template and has no checkout on this Mac, so Pi has no `subagent` tool; if it is added back, apply the chord patch below and check its defaults, since `subagents.json` sets no limits. Sessions persist as JSONL under `~/.pi/agent/sessions/`. These are tool boundaries, not sandboxes: Pi has no command deny list.

Restart Pi or run `/reload` after changes, with the session owner's approval.

## Apply the chord compatibility patch

After installing the pinned packages, run these commands from this repository. Reapply the patch after any package reconciliation that resets the checkout. Do not reset a checkout with local changes to force the patch through.

```sh
subagents="$HOME/.pi/agent/git/github.com/nicobailon/pi-subagents"
patch_file="$PWD/pi/patches/pi-subagents-chord.patch"
patch -d "$subagents" -p1 --forward --dry-run < "$patch_file" &&
  patch -d "$subagents" -p1 --forward < "$patch_file"
(cd "$subagents" && node --experimental-strip-types \
  --import ./test/support/isolated-temp-root.mjs --test \
  --test-name-pattern='chord is omitted' test/unit/host-peer-runtime-imports.test.ts)
```

If the dry run reports an already-applied patch, verify it with `patch -d "$subagents" -p1 --reverse --dry-run < "$patch_file"`. Do not apply it in reverse.

With the session owner's approval, run `/reload`, then retry the same async `researcher` launch through `subagent`. A passing alias test alone does not verify child startup. Keep chord mandatory for Pi `0.85` through `1.1`, unknown versions, and prereleases; do not install a second chord copy to satisfy the check.
