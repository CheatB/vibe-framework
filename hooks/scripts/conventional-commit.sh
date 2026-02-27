#!/bin/bash
# Auto Conventional Commit — проверяет формат коммит-сообщения

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Проверяем что это git commit
if ! echo "$COMMAND" | grep -E '^git commit' > /dev/null 2>&1; then
  exit 0
fi

# Извлекаем сообщение коммита
MSG=$(echo "$COMMAND" | grep -oP '(?<=-m\s["\x27])[^"\x27]+' 2>/dev/null)

if [ -z "$MSG" ]; then
  exit 0
fi

# Проверяем conventional commit формат
if ! echo "$MSG" | grep -E '^(feat|fix|refactor|docs|style|test|chore|perf|ci|build|revert)(\(.+\))?!?:\s.+' > /dev/null 2>&1; then
  echo "{\"decision\": \"block\", \"reason\": \"⛔ Коммит-сообщение не соответствует Conventional Commits. Используй формат: feat|fix|refactor|docs|style|test|chore|perf|ci|build|revert(scope): описание\"}"
fi
