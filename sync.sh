#!/bin/bash
set -e
REPO="$HOME/vibe-framework"
CL="$HOME/.claude"

pull() {
  echo "Pull vibe-framework..."
  cd "$REPO" && git pull origin master
  echo "Sync to ~/.claude/"
  mkdir -p "$CL/commands" "$CL/rules" "$CL/skills/user"
  cp "$REPO/.claude/CLAUDE.md" "$CL/CLAUDE.md"
  cp "$REPO/.claude/commands/"*.md "$CL/commands/" 2>/dev/null || true
  cp "$REPO/.claude/rules/"*.md "$CL/rules/" 2>/dev/null || true
  cp -r "$REPO/.claude/skills/"* "$CL/skills/user/" 2>/dev/null || true
  echo "Done"
}
push() {
  echo "Push to vibe-framework..."
  cp "$CL/CLAUDE.md" "$REPO/.claude/CLAUDE.md"
  cp "$CL/commands/"*.md "$REPO/.claude/commands/" 2>/dev/null || true
  cp "$CL/rules/"*.md "$REPO/.claude/rules/" 2>/dev/null || true
  cd "$REPO"
  git add -A
  if git diff --cached --quiet; then
    echo "No changes"
  else
    git commit -m "sync: update from $(hostname)"
    git push origin master
    echo "Pushed"
  fi
}

case "${1:-pull}" in
  pull)  pull ;;
  push)  push ;;
  *)     echo "Usage: ./sync.sh [pull|push]" ;;
esac
