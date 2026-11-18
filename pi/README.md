# Pi adapter

`./install.sh pi` installs `AGENTS.md` followed by `pi/harness.md` as `~/.pi/agent/AGENTS.md`, the `researcher` subagent, and the subagent runtime limits in `subagents.json`. The `--with-settings` flag also installs `settings.json`, which activates the pinned third-party packages (`pi-web-access`, `pi-subagents`); review the manifest and revisions first, then run `pi update --extensions`. The installer does no network installs.

Pi runs GPT-6.1 Sol (thinking tier) or Terra (fast tier), per `models.md`; Opus 5.5 is not allowed in Pi. Subagents inherit the tab's model: `subagents.defaultModel` is unset and the `researcher` uses `model: inherit`, while `subagents.modelScope` allows only Sol and Terra. `defaultThinking` and a `worker` override set subagents to `medium` (pi-subagents does not inherit the parent's thinking level), and `scout` keeps its builtin `low`. Pi keeps `worker`, `scout`, and the custom `researcher` (fresh context, only `web_search`, `fetch_content`, and `get_search_content`); the review, oracle, auditor, delegate, and external-CLI builtins are disabled because Claude Code does that work. `subagents.json` sets no depth, spawn, or parallelism cap; whether pi-subagents applies its own defaults when they are absent is UNVERIFIED. The `delegate` skill drives Pi in Herdr tabs from any harness. Pi's machine-local `~/.pi/web-search.json` should set `"provider": "openai"` so `web_search` uses OpenAI search through the ChatGPT subscription; with `brave` it searches the same index as Claude Code, and the `auto-research` fan-out loses an engine. These are harness tool boundaries, not sandboxes. Targets Pi `1.1.0`, pi-subagents `0.76.1`, and pi-web-access `0.37.0`. Pi `1.2` and later `1.x` releases also need the [chord compatibility patch](patches/pi-subagents-chord.patch) below because Pi removed chord in `1.2.0`, but this pi-subagents revision still requires it.

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
