# Uploading local images

1. Call `notion-create-file-upload` once per file, in parallel, with descriptive filenames.
2. POST each file with curl as multipart field `file`. Write the returned Authorization header to a temp file and pass `-H @file`; never put it on the command line. Delete the temp file afterwards.
3. Place each upload as `![caption](file-upload://<id>)` in `create-pages` or `insert_content` within the hour the upload stays valid.
4. Verify as in `restructure.md`: the `notion-file-block://` count rises by the number of files placed.
