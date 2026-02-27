#!/bin/bash
# 🔎 Dependency Audit — проверка зависимостей при изменении package.json/requirements.txt
# Триггер: PostToolUse на Write|Edit для файлов зависимостей

# Получаем путь к файлу из CLAUDE_TOOL_INPUT
FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // .path // empty' 2>/dev/null)

# Проверяем что это файл зависимостей
if ! echo "$FILE_PATH" | grep -qE '(package\.json|requirements\.txt|pyproject\.toml|Pipfile|Cargo\.toml)$'; then
  exit 0
fi

WARNINGS=""
DIR=$(dirname "$FILE_PATH")

# Для Node.js проектов
if echo "$FILE_PATH" | grep -q 'package.json'; then
  # Проверка: есть ли lock-файл
  if [ ! -f "$DIR/package-lock.json" ] && [ ! -f "$DIR/pnpm-lock.yaml" ] && [ ! -f "$DIR/yarn.lock" ]; then
    WARNINGS="$WARNINGS\n⚠️ Нет lock-файла — версии зависимостей не зафиксированы!"
  fi

  # Проверка: npm audit (если npm доступен)
  if command -v npm &> /dev/null && [ -f "$DIR/package-lock.json" ]; then
    AUDIT=$(cd "$DIR" && npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities.critical // 0' 2>/dev/null)
    if [ "$AUDIT" != "0" ] && [ -n "$AUDIT" ]; then
      WARNINGS="$WARNINGS\n❌ npm audit: $AUDIT критических уязвимостей!"
    fi
  fi
fi

# Для Python проектов
if echo "$FILE_PATH" | grep -qE '(requirements\.txt|pyproject\.toml)'; then
  # Проверка: дубликаты зависимостей
  if [ -f "$FILE_PATH" ]; then
    DUPS=$(grep -v '^#' "$FILE_PATH" | grep -v '^$' | sed 's/[>=<].*//' | sort | uniq -d)
    if [ -n "$DUPS" ]; then
      WARNINGS="$WARNINGS\n⚠️ Дубликаты в зависимостях: $DUPS"
    fi
  fi
fi

# Вывод
if [ -n "$WARNINGS" ]; then
  echo "{\"systemMessage\": \"🔎 Dependency Audit:$(echo -e "$WARNINGS")\"}"
fi
