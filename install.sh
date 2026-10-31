#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DRY_RUN=0
WITH_SETTINGS=0
SELECTED=""
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_ROOT=${XDG_STATE_HOME:-$HOME/.local/state}/agent-config-installer/backups/$STAMP-$$

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--with-settings] [claude] [pi] [codex] [antigravity]

With no component arguments, installs all supported adapters.
Settings are opt-in because replacing a harness configuration can disable local
hooks or permissions. Existing files are backed up outside harness discovery
directories; they are never deleted.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --with-settings) WITH_SETTINGS=1 ;;
    -h|--help) usage; exit 0 ;;
    claude|pi|codex|antigravity) SELECTED="$SELECTED $arg " ;;
    *) echo "Unknown argument: $arg" >&2; usage >&2; exit 2 ;;
  esac
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

items_match() {
  src=$1
  dst=$2

  # Existing symlinks must be replaced even when they currently resolve to the
  # same content, otherwise later working-tree edits remain globally active.
  [ ! -L "$dst" ] || return 1
  if [ -f "$src" ] && [ -f "$dst" ]; then
    cmp -s "$src" "$dst"
  elif [ -d "$src" ] && [ -d "$dst" ]; then
    diff -qr "$src" "$dst" >/dev/null 2>&1
  else
    return 1
  fi
}

copy_item() {
  src=$1
  dst=$2
  parent=${dst%/*}
  make_dir "$parent"

  if items_match "$src" "$dst"; then
    note "ok     $dst"
    return 0
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    case "$dst" in
      "$HOME"/*) relative=${dst#"$HOME"/} ;;
      *) echo "Refusing to back up destination outside HOME: $dst" >&2; exit 2 ;;
    esac
    backup="$BACKUP_ROOT/$relative"
    backup_parent=${backup%/*}
    make_dir "$backup_parent"
    while [ -e "$backup" ] || [ -L "$backup" ]; do
      backup="$backup-next"
    done
    note "backup $dst -> $backup"
    [ "$DRY_RUN" -eq 1 ] || mv "$dst" "$backup"
  fi

  note "copy   $src -> $dst"
  if [ "$DRY_RUN" -ne 1 ]; then
    if [ -d "$src" ]; then
      cp -Rp "$src" "$dst"
    else
      cp -p "$src" "$dst"
    fi
  fi
}

install_shared_skills() {
  make_dir "$HOME/.agents/skills"
  for skill in "$ROOT"/skills/*; do
    [ -d "$skill" ] || continue
    copy_item "$skill" "$HOME/.agents/skills/${skill##*/}"
  done
}

install_shared_docs() {
  for dir in rules playbooks; do
    make_dir "$HOME/.agents/$dir"
    for doc in "$ROOT/$dir"/*.md; do
      [ -f "$doc" ] || continue
      copy_item "$doc" "$HOME/.agents/$dir/${doc##*/}"
    done
  done
}

install_tool_skills() {
  tool_dir=$1
  make_dir "$tool_dir"
  for skill in "$ROOT"/skills/*; do
    [ -d "$skill" ] || continue
    copy_item "$skill" "$tool_dir/${skill##*/}"
  done
}

install_shared_skills
install_shared_docs

if want claude; then
  copy_item "$ROOT/AGENTS.md" "$HOME/.claude/CLAUDE.md"
  if [ "$WITH_SETTINGS" -eq 1 ]; then
    copy_item "$ROOT/claude/settings.json" "$HOME/.claude/settings.json"
  fi
  install_tool_skills "$HOME/.claude/skills"
  make_dir "$HOME/.claude/agents"
  for agent in "$ROOT"/claude/agents/*.md; do
    [ -f "$agent" ] || continue
    copy_item "$agent" "$HOME/.claude/agents/${agent##*/}"
  done
fi

if want pi; then
  copy_item "$ROOT/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
  if [ "$WITH_SETTINGS" -eq 1 ]; then
    copy_item "$ROOT/pi/settings.json" "$HOME/.pi/agent/settings.json"
  fi
  make_dir "$HOME/.pi/agent/agents"
  for agent in "$ROOT"/pi/agents/*.md; do
    [ -f "$agent" ] || continue
    copy_item "$agent" "$HOME/.pi/agent/agents/${agent##*/}"
  done
  copy_item "$ROOT/pi/subagents.json" "$HOME/.pi/agent/extensions/subagent/config.json"
fi

if want codex; then
  copy_item "$ROOT/AGENTS.md" "$HOME/.codex/AGENTS.md"
  install_tool_skills "$HOME/.codex/skills"
fi

if want antigravity; then
  copy_item "$ROOT/AGENTS.md" "$HOME/.gemini/config/AGENTS.md"
  install_tool_skills "$HOME/.gemini/config/skills"
  make_dir "$HOME/.gemini/config/agents"
  for agent_dir in "$ROOT"/antigravity/agents/*; do
    [ -d "$agent_dir" ] || continue
    name=${agent_dir##*/}
    make_dir "$HOME/.gemini/config/agents/$name"
    copy_item "$agent_dir/agent.md" "$HOME/.gemini/config/agents/$name/agent.md"
  done
fi

note "Done. Restart active agent sessions to reload configuration."
