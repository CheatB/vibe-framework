#!/bin/bash
# Блокировка деструктивных команд
# Ловит: rm -rf, DROP TABLE/DATABASE, truncate, format

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# rm -rf / или rm -rf ~ или rm -rf * (но разрешаем rm -rf node_modules, .next, dist, build, __pycache__)
SAFE_TARGETS="node_modules|\.next|dist|build|__pycache__|\.cache|\.tox|\.pytest_cache|coverage|\.nyc_output"
if echo "$COMMAND" | grep -E 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|--force\s+)' > /dev/null 2>&1; then
  if echo "$COMMAND" | grep -E "rm\s+.*(/|~|\*|\.\.)" > /dev/null 2>&1; then
    if ! echo "$COMMAND" | grep -E "($SAFE_TARGETS)" > /dev/null 2>&1; then
      echo "{\"decision\": \"block\", \"reason\": \"⛔ ЗАБЛОКИРОВАНО: деструктивная команда rm с опасным путём. Проверь что удаляешь.\"}"
      exit 0
    fi
  fi
fi

# DROP TABLE / DROP DATABASE
if echo "$COMMAND" | grep -iE '(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE)' > /dev/null 2>&1; then
  echo "{\"decision\": \"block\", \"reason\": \"⛔ ЗАБЛОКИРОВАНО: DROP/TRUNCATE команда. Используй миграции для изменений БД.\"}"
  exit 0
fi

# format disk
if echo "$COMMAND" | grep -iE '(mkfs\.|fdisk|dd\s+if=.+of=/dev)' > /dev/null 2>&1; then
  echo "{\"decision\": \"block\", \"reason\": \"⛔ ЗАБЛОКИРОВАНО: команда форматирования диска.\"}"
  exit 0
fi
