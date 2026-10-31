# Version control rules

- Use the repository's own VCS (jj or git); never initialize or convert one.
- In jj repos, leave edits in the working-copy change so the user can review with `jj diff`. Do not run `jj new`, `squash`, `abandon`, move bookmarks, or push unless asked. Prefer `jj split` with filesets for separation, and warn that it may move a bookmark.
- In git repos, a local commit is fine when it is a coherent unit and checks passed. Never push, force-push, amend, rebase, reset, or discard unless asked.
- One logical change per commit, with a concise imperative message following the repo's convention. Never include unrelated changes.
- Run VCS commands non-interactively.
