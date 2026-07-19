# Pi packages

`settings.json` is the canonical package manifest. Use Pi's native `packages` array rather than cloning extensions into this repository or maintaining a second lock file.

## Policy

- Pin Git packages to a full commit SHA and npm packages to an exact version.
- Never track a floating branch such as `main` for an extension that executes code.
- Review the manifest, extension entry points, process execution, credential access, network destinations, and changes since the previously pinned revision.
- Try upgrades ephemerally before changing the pin.
- Keep globally installed packages few; use project-local packages for capabilities needed by only one trusted repository.
- Use package resource filters to exclude bundled skills, prompts, themes, or extensions that are not needed.
- Keep package credentials and runtime configuration outside this repository.
- Do not install network-enabled packages on managed or internal machines unless organizational policy permits their data flows.

## Update workflow

For a Git package:

```sh
# Inspect upstream and identify a candidate commit or release.
git clone https://github.com/OWNER/REPO /tmp/REPO
git -C /tmp/REPO diff OLD_SHA..NEW_SHA

# Try it for one Pi run without changing settings.
pi -e git:github.com/OWNER/REPO@NEW_SHA

# After review, update the exact SHA in pi/settings.json, then reconcile.
pi update --extensions
pi list
```

Do not use `pi update --all` as a substitute for reviewing upgrades. Pinned packages do not advance automatically; update the pin deliberately.

## Approved packages

### pi-subagents

- Source: `nicobailon/pi-subagents`
- Pin: `d6e8005e3958adea634bf27c615abac7407aedc4`
- Upstream release at review: `v0.35.1`
- Purpose: explicit delegation to focused child Pi sessions for second opinions, research, planning, implementation, and review
- Enabled resources: extension only
- Disabled resources: bundled `pi-subagents` skill and prompt templates
- Verification: upstream unit suite passed locally (`1285` passed, `1` skipped)

The bundled skill and prompts are intentionally filtered out. The skill is almost 1,000 lines and promotes a broad “Fable mode,” mandatory clarification, and multi-agent review loops. Those policies would compete with this repository's concise global instructions and could encourage unnecessary delegation. The extension's tool description and built-in agents are sufficient for explicit, task-driven use; individual prompts can be enabled later if they prove valuable.

Important behavior:

- It spawns child Pi processes with their own model calls, so delegation can multiply token usage, latency, and cost.
- Worker and reviewer agents may edit files according to their effective tool permissions.
- Parallel writers can conflict unless worktree isolation is explicitly used; prefer one writer and parallelize read-only analysis.
- It can create and remove temporary Git worktrees and branches when `worktree: true` is requested.
- Session forking shares parent conversation context with a child; use fresh context when history is unnecessary or sensitive.
- Gist session sharing, scheduled runs, browser-independent watchdog reviews, and nested delegation are not reasons to enable defaults. Keep optional automation off until deliberately configured.
- Tool restrictions are not an operating-system sandbox.

Start with explicit delegation such as “ask oracle for a second opinion” or “use reviewer to review this diff.” Do not add a global instruction requiring subagents for every task.

### pi-web-access

- Source: `nicobailon/pi-web-access`
- Pin: `7bdc30a65cf77273eb9c0034647b373bda4060d7`
- Upstream release at review: `v0.13.0`
- Purpose: child-only web search and content extraction for the read-only `researcher` subagent
- Enabled resources: none in the parent Pi process; `pi/agents/researcher.md` loads `index.ts` only in researcher children
- Disabled resources: package extension and bundled `librarian` skill in the parent
- Review notes: package manifest, documentation, SSRF guard, process execution, cookie opt-in, credential paths, production dependencies, and tests were reviewed; this is not a complete security audit

This package remains in the manifest so Pi installs its pinned source and dependencies, but package filters prevent it from registering web tools in the main coding session. The managed researcher points to Pi's documented Git package checkout path at `~/.pi/agent/git/github.com/nicobailon/pi-web-access/index.ts` through `subagentOnlyExtensions`.

Important behavior:

- It runs as a Pi extension with the user's full permissions.
- Searches and fetched content are sent to external providers.
- It can reuse Pi's OpenAI/Codex authentication for search.
- Browser-cookie access is disabled by default; keep `allowBrowserCookies` false unless explicitly needed and understood.
- It can invoke `git`, `gh`, `ffmpeg`, `ffprobe`, and `yt-dlp` for supported operations.
- Local video analysis may upload the selected file to a configured provider.
- Its SSRF protection blocks private/reserved addresses by default; do not broaden `ssrf.allowRanges` casually.
- Child-only tool visibility is a harness boundary, not an operating-system sandbox; the extension still executes with the user's permissions inside the researcher process.

The researcher has no local file, Bash, or mutation tools, uses fresh context, does not inherit project instructions or skills, and is instructed to use `workflow: "none"`. Invoke it with `/research <question>` or explicitly ask the parent to use the researcher. Research requests must contain only sanitized public technical context.

Store API keys in environment variables or the package's machine-local `~/.pi/web-search.json`, never in this repository. Restrict that file to the user when it contains secrets:

```sh
chmod 600 ~/.pi/web-search.json
```
