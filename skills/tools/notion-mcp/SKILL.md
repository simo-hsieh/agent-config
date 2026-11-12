---
name: notion-mcp
description: Reads and edits Notion pages through the Notion MCP - page layout for agent-maintained content, local image uploads, targeted edits and their limits, and verification. Use whenever a task writes to Notion.
---

# Notion MCP editing

Read `notion://docs/enhanced-markdown-spec` once per session before writing page content. Load a file next to this skill only when the task needs it: `upload-images.md` to add local images or files, `restructure.md` to delete or move blocks that contain images or files.

## Page layout

- Search for an existing page on the topic before creating one, and update it instead of adding a duplicate.
- Put content you generate and keep updating (bookings, summaries, screenshots) on its own child page, linked from the user's page. Rewrite that child page freely with `replace_content`; change the user's page only with `insert_content` or text-only `update_content`.
- Fetch a page before editing it. Delete user-authored blocks only when the user named them or approved the deletion.

## Edits

- `update_content` cannot match across an image or file block: `old_str` stops matching at the `![](` or `<file src=` URL, whatever URL form you use. Use `restructure.md` instead.
- Fetched text can contain non-breaking spaces (U+00A0). Build `old_str` from the raw fetch with a script instead of retyping it.
- A `content_updates` batch is all-or-nothing; send uncertain matches in their own call.
- The MCP cannot trash pages or rows, and `update-view` fails with `query.aggregate should be not present` on views that have a count aggregate. To remove rows, `move-pages` them into one private `creation_mode: "draft"` page the user can delete; replace old views with `create-view` and leave deleting them to the user.
- A fetch too large for context is saved to a file; parse it with `json.load` (`text`, `references`) instead of reading it in chunks.
