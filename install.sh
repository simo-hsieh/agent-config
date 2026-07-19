#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DRY_RUN=0
WITH_SETTINGS=0
SELECTED=""
STAMP=$(date +%Y%m%d-%H%M%S)

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--with-settings] [claude] [pi] [codex] [antigravity]

With no component arguments, installs all supported adapters.
Settings are opt-in because replacing a harness configuration can disable local
hooks or permissions. Existing files are backed up; they are never deleted.
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

link_item() {
  src=$1
  dst=$2
  parent=${dst%/*}
  make_dir "$parent"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    note "ok     $dst"
    return 0
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup="$dst.backup-$STAMP-$$"
    note "backup $dst -> $backup"
    [ "$DRY_RUN" -eq 1 ] || mv "$dst" "$backup"
  fi

  note "link   $dst -> $src"
  [ "$DRY_RUN" -eq 1 ] || ln -s "$src" "$dst"
}

install_shared_skills() {
  make_dir "$HOME/.agents/skills"
  for skill in "$ROOT"/skills/*; do
    [ -d "$skill" ] || continue
    link_item "$skill" "$HOME/.agents/skills/${skill##*/}"
  done
}

install_tool_skills() {
  tool_dir=$1
  make_dir "$tool_dir"
  for skill in "$ROOT"/skills/*; do
    [ -d "$skill" ] || continue
    link_item "$skill" "$tool_dir/${skill##*/}"
  done
}

install_shared_skills

if want claude; then
  link_item "$ROOT/AGENTS.md" "$HOME/.claude/CLAUDE.md"
  if [ "$WITH_SETTINGS" -eq 1 ]; then
    link_item "$ROOT/claude/settings.json" "$HOME/.claude/settings.json"
  fi
  install_tool_skills "$HOME/.claude/skills"
  make_dir "$HOME/.claude/agents"
  for agent in "$ROOT"/claude/agents/*.md; do
    [ -f "$agent" ] || continue
    link_item "$agent" "$HOME/.claude/agents/${agent##*/}"
  done
fi

if want pi; then
  link_item "$ROOT/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
  if [ "$WITH_SETTINGS" -eq 1 ]; then
    link_item "$ROOT/pi/settings.json" "$HOME/.pi/agent/settings.json"
  fi
  make_dir "$HOME/.pi/agent/prompts"
  for prompt in "$ROOT"/prompts/*.md; do
    [ -f "$prompt" ] || continue
    link_item "$prompt" "$HOME/.pi/agent/prompts/${prompt##*/}"
  done
  make_dir "$HOME/.pi/agent/agents"
  for agent in "$ROOT"/pi/agents/*.md; do
    [ -f "$agent" ] || continue
    link_item "$agent" "$HOME/.pi/agent/agents/${agent##*/}"
  done
  link_item "$ROOT/pi/subagents.json" "$HOME/.pi/agent/extensions/subagent/config.json"
fi

if want codex; then
  link_item "$ROOT/AGENTS.md" "$HOME/.codex/AGENTS.md"
  install_tool_skills "$HOME/.codex/skills"
fi

if want antigravity; then
  link_item "$ROOT/AGENTS.md" "$HOME/.gemini/config/AGENTS.md"
  install_tool_skills "$HOME/.gemini/config/skills"
  make_dir "$HOME/.gemini/config/agents"
  for agent_dir in "$ROOT"/antigravity/agents/*; do
    [ -d "$agent_dir" ] || continue
    name=${agent_dir##*/}
    make_dir "$HOME/.gemini/config/agents/$name"
    link_item "$agent_dir/agent.md" "$HOME/.gemini/config/agents/$name/agent.md"
  done
fi

note "Done. Restart active agent sessions to reload configuration."
