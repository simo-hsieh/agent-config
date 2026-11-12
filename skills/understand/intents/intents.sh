#!/bin/sh
# Prints each docs/**/intent.md in a repo: its Status line and its open questions.
set -eu
root=${1:-.}
find "$root" -path '*/node_modules' -prune -o -path '*/.jj' -prune -o -path '*/.git' -prune -o \
  -name intent.md -path '*docs/*' -print | sort | while read -r f; do
  awk -v file="${f#"$root"/}" '
    NR == 1 { sub(/^# */, ""); title = $0 }
    /^Status:/ { status = substr($0, 9) }
    /^## / { inq = ($0 ~ /^## Open questions/); next }
    inq && /^[0-9]+\. / { n++; q[n] = $0; next }
    inq && /^   / && n { q[n] = q[n] " " substr($0, 4) }
    END {
      printf "## %s\n%s\nStatus: %s\nOpen questions: %d\n", title, file, (status ? status : "none"), n
      for (i = 1; i <= n; i++) print q[i]
      print ""
    }' "$f"
done
