#!/bin/bash
# Branch-guard — блокирует push в main/master без PR
# Активен только если в проекте есть .branch-guard файл (opt-in)

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Только git push
if ! echo "$COMMAND" | grep -E '^git push' > /dev/null 2>&1; then
  exit 0
fi

# Opt-in: только если есть маркер-файл
if [ ! -f ".branch-guard" ]; then
  exit 0
fi

# Проверяем ветку
BRANCH=$(git branch --show-current 2>/dev/null)
if echo "$BRANCH" | grep -E '^(main|master|production)$' > /dev/null 2>&1; then
  echo "{\"decision\": \"block\", \"reason\": \"⛔ BRANCH-GUARD: push в $BRANCH заблокирован. Создай feature-ветку и PR. Отключить: удали .branch-guard\"}"
fi
