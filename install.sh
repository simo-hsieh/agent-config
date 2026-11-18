#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC=${AGENT_SRC:-$HOME/.agents/src}
RELEASES=${SRC%/*}/releases
REV=HEAD
REV_GIVEN=0
DRY_RUN=0
WITH_SETTINGS=0
SELECTED=""
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_ROOT=${XDG_STATE_HOME:-$HOME/.local/state}/agent-config-installer/backups/$STAMP-$$
KEEP_BACKUPS=10

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--with-settings] [--rev <commit>] [claude] [pi] [agy]

Publishes one git commit: exports it read-only to <releases>/<sha>, points
$AGENT_SRC (default ~/.agents/src) at that export, and links installed paths
into $AGENT_SRC. Only the commit last installed is live. Without --rev it
installs HEAD and refuses uncommitted changes; --rev <older commit> rolls back.
With no component arguments, installs all supported adapters.
Full Pi settings are opt-in. Subagent definitions are linked, and Agent, Task,
and TeamCreate denies left by earlier installs are removed from Claude settings,
preserving other settings. Replaced files are backed up outside harness discovery directories;
only the 10 newest timestamped backup runs are kept.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --with-settings) WITH_SETTINGS=1 ;;
    --rev) [ $# -ge 2 ] || { usage >&2; exit 2; }; REV=$2; REV_GIVEN=1; shift ;;
    --rev=*) REV=${1#--rev=}; REV_GIVEN=1 ;;
    -h|--help) usage; exit 0 ;;
    claude|pi|agy) SELECTED="$SELECTED $1 " ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

want() {
  [ -z "$SELECTED" ] || case "$SELECTED" in *" $1 "*) return 0;; *) return 1;; esac
}

note() {
  printf '%s\n' "$*"
}

make_dir() {
  [ -d "$1" ] && return 0
  note "mkdir  $1"
  [ "$DRY_RUN" -eq 1 ] || mkdir -p "$1"
}

backup_item() {
  dst=$1
  case "$dst" in
    "$HOME"/*) relative=${dst#"$HOME"/} ;;
    *) echo "Refusing to back up destination outside HOME: $dst" >&2; exit 2 ;;
  esac
  backup="$BACKUP_ROOT/$relative"
  make_dir "${backup%/*}"
  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="$backup-next"
  done
  note "backup $dst -> $backup"
  [ "$DRY_RUN" -eq 1 ] || mv "$dst" "$backup"
}

# link_item <path relative to the source root> <installed path>
link_item() {
  target="$SRC/$1"
  dst=$2
  make_dir "${dst%/*}"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$target" ]; then
    note "ok     $dst"
    return 0
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup_item "$dst"
  fi
  note "link   $dst -> $target"
  [ "$DRY_RUN" -eq 1 ] || ln -s "$target" "$dst"
}

# Skill directories are skills/<intent>/<skill>/ and install flat by name.
skill_dirs() {
  find "$LIST/skills" -mindepth 3 -maxdepth 3 -name SKILL.md | sed "s#^$LIST/##; s#/SKILL.md\$##" | sort
}

check_unique_names() {
  dupes=$(skill_dirs | sed 's#.*/##' | sort | uniq -d)
  if [ -n "$dupes" ]; then
    echo "Duplicate skill names across intents: $dupes" >&2
    exit 2
  fi
}

link_skills() {
  dir=$1
  make_dir "$dir"
  for rel in $(skill_dirs); do
    link_item "$rel" "$dir/${rel##*/}"
  done
}

# Remove links into the source root whose target no longer exists.
prune_dangling() {
  dir=$1
  [ -d "$dir" ] || return 0
  for link in "$dir"/*; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
      "$SRC"/*) target=$(readlink "$link"); [ -e "$LIST/${target#"$SRC"/}" ] && continue
        note "unlink $link"
        [ "$DRY_RUN" -eq 1 ] || rm "$link" ;;
    esac
  done
}

# Playbooks moved into skills/playbooks/; retire their old copied files.
retire_legacy() {
  for name in bugfix feature; do
    legacy="$HOME/.agents/playbooks/$name.md"
    if [ -f "$legacy" ] && [ ! -L "$legacy" ]; then
      backup_item "$legacy"
    fi
  done
}

# A release is an immutable export of one commit, so live files never change
# under a running agent and no edit is live until it is committed and installed.
resolve_commit() {
  COMMIT=$(git -C "$ROOT" rev-parse --verify --quiet "$REV^{commit}") || {
    echo "Unknown revision: $REV" >&2; exit 2; }
  if [ "$REV_GIVEN" -eq 0 ]; then
    dirty=$(git -C "$ROOT" status --porcelain)
    if [ -n "$dirty" ]; then
      printf '%s\n' "$dirty" >&2
      echo "Uncommitted changes in $ROOT would not be installed. Commit them, or pass --rev <commit>." >&2
      exit 2
    fi
  fi
  RELEASE=$RELEASES/$COMMIT
}

# Sets LIST to the release contents; a dry run exports to a temporary directory.
export_release() {
  if [ -d "$RELEASE" ]; then
    LIST=$RELEASE
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    LIST=$(mktemp -d)
    trap 'chmod -R u+w "$LIST" && rm -rf "$LIST"' EXIT
  else
    mkdir -p "$RELEASES"
    LIST=$RELEASES/.tmp-$COMMIT-$$
    mkdir "$LIST"
  fi
  git -C "$ROOT" archive "$COMMIT" | tar -x -C "$LIST"
  chmod -R a-w "$LIST"
  note "export $(git -C "$ROOT" log -1 --format='%h %s' "$COMMIT") -> $RELEASE"
  if [ "$DRY_RUN" -eq 0 ]; then
    chmod u+w "$LIST"
    mv "$LIST" "$RELEASE"
    chmod a-w "$RELEASE"
    LIST=$RELEASE
  fi
}

# Swaps the live link in one rename, so readers see the old or new release, never a mix.
publish_release() {
  if [ -L "$SRC" ] && [ "$(readlink "$SRC")" = "$RELEASE" ]; then
    note "ok     $SRC -> $RELEASE"
    return 0
  fi
  if [ -e "$SRC" ] && [ ! -L "$SRC" ]; then
    backup_item "$SRC"
  fi
  note "live   $SRC -> $RELEASE"
  [ "$DRY_RUN" -eq 1 ] || python3 -c '
import os, sys
release, src = sys.argv[1:]
staged = src + ".new"
if os.path.lexists(staged):
    os.remove(staged)
os.symlink(release, staged)
os.replace(staged, src)
' "$RELEASE" "$SRC"
}

# Remove the subagent tool denies earlier installs merged in; leave every other
# machine-local permission and hook alone.
allow_subagents() {
  dst=$1
  [ -f "$dst" ] || return 0
  note "check  $dst (allow native subagents)"
  python3 - "$dst" "$BACKUP_ROOT" "$DRY_RUN" <<'PY'
import json
import os
import sys
from pathlib import Path

filename, backup_root, dry_run = sys.argv[1:]
path = Path(filename)
config = json.loads(path.read_text())
before = json.dumps(config, sort_keys=True)
deny = config.get("permissions", {}).get("deny")
if deny is not None:
    config["permissions"]["deny"] = [t for t in deny if t not in ("Agent", "Task", "TeamCreate")]
if before == json.dumps(config, sort_keys=True):
    print(f"ok     {path} (subagents allowed)")
else:
    print(f"update {path} (subagents allowed)")
    if dry_run != "1":
        if path.exists() or path.is_symlink():
            backup = Path(backup_root) / path.relative_to(Path.home())
            backup.parent.mkdir(parents=True, exist_ok=True)
            while backup.exists() or backup.is_symlink():
                backup = backup.with_name(backup.name + "-next")
            print(f"backup {path} -> {backup}")
            os.rename(path, backup)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(config, indent=2) + "\n")
PY
}

# Run folders are named <YYYYMMDD-HHMMSS>-<pid>, so name order is age order;
# folders named otherwise (e.g. manual-*) are left alone.
prune_backups() {
  dir=${BACKUP_ROOT%/*}
  [ -d "$dir" ] || return 0
  find "$dir" -mindepth 1 -maxdepth 1 -type d -name '[0-9]*-[0-9]*-[0-9]*' | sort -r |
    tail -n +$((KEEP_BACKUPS + 1)) | while IFS= read -r old; do
      note "prune  $old"
      [ "$DRY_RUN" -eq 1 ] || { chmod -R u+w "$old" && rm -rf "$old"; }
    done
}

# Link each agent definition in <repo dir> into <harness dir>.
link_agents() {
  for agent in "$LIST"/$1/*.md; do
    [ -f "$agent" ] || continue
    link_item "$1/${agent##*/}" "$2/${agent##*/}"
  done
  prune_dangling "$2"
}

resolve_commit
export_release
check_unique_names
make_dir "${SRC%/*}"
publish_release

link_skills "$HOME/.agents/skills"
prune_dangling "$HOME/.agents/skills"
link_item rules/coding.md "$HOME/.agents/rules/coding.md"
retire_legacy

if want claude; then
  link_item AGENTS.md "$HOME/.claude/CLAUDE.md"
  link_skills "$HOME/.claude/skills"
  prune_dangling "$HOME/.claude/skills"
  link_agents claude/agents "$HOME/.claude/agents"
  allow_subagents "$HOME/.claude/settings.json"
fi

if want pi; then
  link_item AGENTS.md "$HOME/.pi/agent/AGENTS.md"
  if [ "$WITH_SETTINGS" -eq 1 ]; then
    link_item pi/settings.json "$HOME/.pi/agent/settings.json"
  fi
  link_agents pi/agents "$HOME/.pi/agent/agents"
  link_item pi/subagents.json "$HOME/.pi/agent/extensions/subagent/config.json"
fi

if want agy; then
  link_item AGENTS.md "$HOME/.gemini/config/AGENTS.md"
  link_skills "$HOME/.gemini/config/skills"
  prune_dangling "$HOME/.gemini/config/skills"
  for plugin in "$LIST"/agy/plugins/*; do
    [ -d "$plugin" ] || continue
    link_item "agy/plugins/${plugin##*/}" "$HOME/.gemini/config/plugins/${plugin##*/}"
  done
  prune_dangling "$HOME/.gemini/config/plugins"
fi

prune_backups
note "Done. Restart active agent sessions to reload configuration."
