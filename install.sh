#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC=${AGENT_SRC:-$HOME/.agents/src}
DRY_RUN=0
WITH_SETTINGS=0
SELECTED=""
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_ROOT=${XDG_STATE_HOME:-$HOME/.local/state}/agent-config-installer/backups/$STAMP-$$

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--with-settings] [claude] [pi] [agy]

Links installed paths into the stable jj workspace at $AGENT_SRC
(default ~/.agents/src), so only the change checked out there is live.
With no component arguments, installs all supported adapters.
Full Pi settings are opt-in. Native subagent controls are always applied:
merge Claude tool denies and remove Pi's subagent package, preserving other
settings. Replaced files are backed up outside harness discovery directories.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --with-settings) WITH_SETTINGS=1 ;;
    -h|--help) usage; exit 0 ;;
    claude|pi|agy) SELECTED="$SELECTED $arg " ;;
    *) echo "Unknown argument: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

if [ ! -d "$SRC/.jj" ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "note   $SRC is not a jj workspace yet; listing from $ROOT" >&2
    LIST=$ROOT
  else
    echo "Missing stable workspace $SRC. Create it with: jj -R $ROOT workspace add $SRC" >&2
    exit 2
  fi
else
  LIST=$SRC
fi

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
      "$SRC"/*) [ -e "$link" ] && continue
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

# Merge only single-agent controls; never replace machine-local hooks or permissions.
disable_subagents() {
  kind=$1
  dst=$2
  note "check  $dst (disable native subagents)"
  python3 - "$kind" "$dst" "$ROOT/claude/settings.json" "$BACKUP_ROOT" "$DRY_RUN" <<'PY'
import json
import os
import sys
from pathlib import Path

kind, filename, policy, backup_root, dry_run = sys.argv[1:]
path = Path(filename)
config = json.loads(path.read_text()) if path.exists() else {}
before = json.dumps(config, sort_keys=True)
if kind == "claude":
    deny = config.setdefault("permissions", {}).setdefault("deny", [])
    for tool in json.loads(Path(policy).read_text())["permissions"]["deny"]:
        if tool not in deny:
            deny.append(tool)
else:
    config.pop("subagents", None)
    for resource in ("packages", "extensions"):
        if resource in config:
            config[resource] = [
                item for item in config[resource]
                if "pi-subagents" not in (item["source"] if isinstance(item, dict) else item)
            ]
if before == json.dumps(config, sort_keys=True):
    print(f"ok     {path} (single-agent controls)")
else:
    print(f"update {path} (single-agent controls)")
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

# Retire only definitions and runtime links owned by this installer.
retire_subagents() {
  dir=$1
  [ -d "$dir" ] || return 0
  for item in "$dir"/*; do
    [ -L "$item" ] || continue
    case "$(readlink "$item")" in
      "$SRC"/claude/agents/*|"$SRC"/pi/agents/*|"$SRC"/pi/subagents.json)
        backup_item "$item" ;;
    esac
  done
}

check_unique_names

link_skills "$HOME/.agents/skills"
prune_dangling "$HOME/.agents/skills"
link_item rules/coding.md "$HOME/.agents/rules/coding.md"
retire_legacy

if want claude; then
  link_item AGENTS.md "$HOME/.claude/CLAUDE.md"
  link_skills "$HOME/.claude/skills"
  prune_dangling "$HOME/.claude/skills"
  retire_subagents "$HOME/.claude/agents"
  disable_subagents claude "$HOME/.claude/settings.json"
fi

if want pi; then
  link_item AGENTS.md "$HOME/.pi/agent/AGENTS.md"
  if [ "$WITH_SETTINGS" -eq 1 ]; then
    link_item pi/settings.json "$HOME/.pi/agent/settings.json"
  fi
  retire_subagents "$HOME/.pi/agent/agents"
  retire_subagents "$HOME/.pi/agent/extensions/subagent"
  disable_subagents pi "$HOME/.pi/agent/settings.json"
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

note "Done. Restart active agent sessions to reload configuration."
