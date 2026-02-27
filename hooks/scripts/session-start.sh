#!/bin/bash
# Контекст-инжекция при старте сессии
# Автоматически подгружает состояние проекта чтобы Claude начинал "в теме"

CONTEXT=""

# Git состояние
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  STATUS=$(git status --short 2>/dev/null | head -15)
  LAST_COMMITS=$(git log --oneline -5 2>/dev/null)
  STASH_COUNT=$(git stash list 2>/dev/null | wc -l | tr -d ' ')

  CONTEXT="🔀 Ветка: $BRANCH"

  if [ -n "$STATUS" ]; then
    CONTEXT="$CONTEXT\n📂 Изменённые файлы:\n$STATUS"
  else
    CONTEXT="$CONTEXT\n📂 Рабочая директория чистая"
  fi

  CONTEXT="$CONTEXT\n📝 Последние коммиты:\n$LAST_COMMITS"

  if [ "$STASH_COUNT" -gt 0 ]; then
    CONTEXT="$CONTEXT\n📦 Stash: $STASH_COUNT шт."
  fi
fi

# Проект (package.json или pyproject.toml)
if [ -f "package.json" ]; then
  PROJECT_NAME=$(jq -r '.name // empty' package.json 2>/dev/null)
  NODE_VER=$(node -v 2>/dev/null)
  CONTEXT="$CONTEXT\n🏗️ Проект: $PROJECT_NAME (Node $NODE_VER)"
elif [ -f "pyproject.toml" ]; then
  PROJECT_NAME=$(grep -m1 'name' pyproject.toml 2>/dev/null | sed 's/.*= *"\(.*\)"/\1/')
  PY_VER=$(python3 --version 2>/dev/null | cut -d' ' -f2)
  CONTEXT="$CONTEXT\n🏗️ Проект: $PROJECT_NAME (Python $PY_VER)"
fi

# Docker (если есть docker-compose)
if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
  SERVICES=$(grep -E '^\s+\w+:$' docker-compose.y*ml 2>/dev/null | sed 's/://;s/^ *//' | tr '\n' ', ')
  CONTEXT="$CONTEXT\n🐳 Docker сервисы: $SERVICES"
fi

# Nemp Memory (если есть)
if [ -f ".nemp/memories.json" ]; then
  MEM_COUNT=$(jq 'length' .nemp/memories.json 2>/dev/null)
  CONTEXT="$CONTEXT\n🧠 Nemp: $MEM_COUNT сохранённых фактов"
fi

if [ -n "$CONTEXT" ]; then
  echo "{\"systemMessage\": \"📍 СОСТОЯНИЕ ПРОЕКТА:\n$(echo -e "$CONTEXT")\"}"
fi
