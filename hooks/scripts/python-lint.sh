#!/bin/bash
# Авто-линт Python файлов через Ruff после редактирования

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_result.file_path // .tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Только Python файлы
if ! echo "$FILE_PATH" | grep -E '\.py$' > /dev/null 2>&1; then
  exit 0
fi

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Ruff fix + format (если установлен)
if command -v ruff >/dev/null 2>&1; then
  ruff check --fix --quiet "$FILE_PATH" 2>/dev/null || true
  ruff format --quiet "$FILE_PATH" 2>/dev/null || true
fi
