#!/bin/bash
# Re-inject контекста после compaction
# Когда Claude сжимает контекст, критические инструкции теряются
# Этот хук перечитывает ключевые правила и возвращает их в контекст

REINJECT=""

# CLAUDE.md проекта (если есть)
if [ -f "CLAUDE.md" ]; then
  PROJECT_CONTEXT=$(head -50 CLAUDE.md 2>/dev/null)
  REINJECT="$REINJECT\n\n📋 CLAUDE.md проекта:\n$PROJECT_CONTEXT"
fi

# Глобальные правила (критические секции)
if [ -f "$HOME/.claude/CLAUDE.md" ]; then
  GLOBAL_RULES=$(head -30 "$HOME/.claude/CLAUDE.md" 2>/dev/null)
  REINJECT="$REINJECT\n\n📋 Глобальные правила:\n$GLOBAL_RULES"
fi

# Текущая git-ветка и последние коммиты
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  LAST_COMMITS=$(git log --oneline -5 2>/dev/null)
  REINJECT="$REINJECT\n\n🔀 Ветка: $BRANCH\n📝 Последние коммиты:\n$LAST_COMMITS"
fi

if [ -n "$REINJECT" ]; then
  echo "{\"systemMessage\": \"🔄 КОНТЕКСТ ВОССТАНОВЛЕН ПОСЛЕ COMPACTION:$(echo -e "$REINJECT" | head -80)\"}"
fi
