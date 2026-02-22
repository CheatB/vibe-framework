#!/bin/bash
# Vibe Framework — скрипт синхронизации
# Единый источник правды: github.com/CheatB/vibe-framework
#
# Использование:
#   sync.sh install  — первая установка (репо → ~/.claude/)
#   sync.sh pull     — обновить ~/.claude/ из репо
#   sync.sh push     — скопировать из ~/.claude/ в репо для коммита
#   sync.sh status   — показать различия

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

log() { echo "[sync] $1"; }

sync_to_claude() {
    log "Копирую из репо в $CLAUDE_DIR..."
    
    cp "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    
    mkdir -p "$CLAUDE_DIR/commands"
    cp "$REPO_DIR/commands/"*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true
    
    mkdir -p "$CLAUDE_DIR/rules"
    cp "$REPO_DIR/rules/"*.md "$CLAUDE_DIR/rules/" 2>/dev/null || true
    
    mkdir -p "$CLAUDE_DIR/hooks/scripts"
    cp "$REPO_DIR/hooks/hooks.json" "$CLAUDE_DIR/hooks/" 2>/dev/null || true
    cp "$REPO_DIR/hooks/scripts/"* "$CLAUDE_DIR/hooks/scripts/" 2>/dev/null || true
    chmod +x "$CLAUDE_DIR/hooks/scripts/"*.sh 2>/dev/null || true
    
    mkdir -p "$CLAUDE_DIR/skills/user"
    cp -r "$REPO_DIR/skills/user/"* "$CLAUDE_DIR/skills/user/" 2>/dev/null || true
    
    log "Готово:"
    echo "  CLAUDE.md:  $(wc -l < "$CLAUDE_DIR/CLAUDE.md") строк"
    echo "  commands:   $(ls "$CLAUDE_DIR/commands/"*.md 2>/dev/null | wc -l) файлов"
    echo "  rules:      $(ls "$CLAUDE_DIR/rules/"*.md 2>/dev/null | wc -l) файлов"
    echo "  hooks:      $(ls "$CLAUDE_DIR/hooks/scripts/" 2>/dev/null | wc -l) скриптов"
    echo "  skills:     $(ls -d "$CLAUDE_DIR/skills/user/"*/ 2>/dev/null | wc -l) скиллов"
}

sync_from_claude() {
    log "Копирую из $CLAUDE_DIR в репо..."
    
    cp "$CLAUDE_DIR/CLAUDE.md" "$REPO_DIR/CLAUDE.md"
    
    mkdir -p "$REPO_DIR/commands" "$REPO_DIR/rules" "$REPO_DIR/hooks/scripts" "$REPO_DIR/skills/user"
    
    cp "$CLAUDE_DIR/commands/"*.md "$REPO_DIR/commands/" 2>/dev/null || true
    cp "$CLAUDE_DIR/rules/"*.md "$REPO_DIR/rules/" 2>/dev/null || true
    cp "$CLAUDE_DIR/hooks/hooks.json" "$REPO_DIR/hooks/" 2>/dev/null || true
    cp "$CLAUDE_DIR/hooks/scripts/"* "$REPO_DIR/hooks/scripts/" 2>/dev/null || true
    cp -r "$CLAUDE_DIR/skills/user/"* "$REPO_DIR/skills/user/" 2>/dev/null || true
    
    log "Готово. Проверь git diff и закоммить:"
    cd "$REPO_DIR"
    git status --short
}

case "${1:-help}" in
    install)
        log "Первая установка фреймворка"
        sync_to_claude
        log "Перезапусти Claude Code."
        ;;
    pull)
        sync_to_claude
        ;;
    push)
        sync_from_claude
        ;;
    status)
        log "Различия между репо и ~/.claude/:"
        for comp in CLAUDE.md commands rules hooks skills/user; do
            if [ -e "$REPO_DIR/$comp" ] && [ -e "$CLAUDE_DIR/$comp" ]; then
                DIFF=$(diff -rq "$REPO_DIR/$comp" "$CLAUDE_DIR/$comp" 2>/dev/null || true)
                if [ -z "$DIFF" ]; then
                    echo "  ✅ $comp"
                else
                    echo "  ⚠️  $comp — есть различия"
                fi
            fi
        done
        ;;
    *)
        echo "sync.sh {install|pull|push|status}"
        echo "  install  — репо → ~/.claude/"
        echo "  pull     — обновить ~/.claude/ из репо"
        echo "  push     — ~/.claude/ → репо для коммита"
        echo "  status   — показать различия"
        ;;
esac
