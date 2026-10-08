# Deleting or moving blocks with images or files

1. Fetch the page and rebuild its full markdown with a script, leaving out or reordering the blocks you mean to change.
2. Send it with `replace_content`. `notion-file-block://` sources in that markdown keep the existing files. To move blocks to another page, put their markdown in `create-pages` or `insert_content` on that page first (the same sources copy the files there), verify, then remove them from the original.
3. Fetch again with `include_file_urls: true` (the result goes to a file) and check with a script: removed text is absent, kept sections are present, and the `notion-file-block://` count matches the expected number of files.
4. Tell the user that comments on rewritten blocks may be lost.
