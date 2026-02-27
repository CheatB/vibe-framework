#!/bin/bash
# Security Scan — проверка unsafe-паттернов перед записью файла
# Блокирует: SQL injection, XSS, command injection, hardcoded secrets

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Получаем содержимое которое будет записано
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_str // empty' 2>/dev/null)

if [ -z "$CONTENT" ]; then
  exit 0
fi

WARNINGS=""

# SQL injection: raw string formatting в SQL запросах
if echo "$CONTENT" | grep -E "(f['\"].*SELECT|f['\"].*INSERT|f['\"].*UPDATE|f['\"].*DELETE|\.format\(.*SELECT|%s.*SELECT)" > /dev/null 2>&1; then
  WARNINGS="$WARNINGS\n🔴 SQL INJECTION: Найден raw string formatting в SQL запросе. Используй параметризованные запросы."
fi

# XSS: прямая вставка пользовательского ввода в HTML
if echo "$CONTENT" | grep -E "(innerHTML\s*=|\.html\(|dangerouslySetInnerHTML|v-html=)" > /dev/null 2>&1; then
  WARNINGS="$WARNINGS\n🔴 XSS: Прямая вставка HTML. Используй sanitize или текстовые методы."
fi

# Command injection: пользовательский ввод в shell-командах
if echo "$CONTENT" | grep -E "(os\.system\(.*\+|subprocess\.\w+\(.*\+|exec\(.*\+|eval\(.*\+|\$\(.*\$)" > /dev/null 2>&1; then
  WARNINGS="$WARNINGS\n🔴 COMMAND INJECTION: Конкатенация строк в shell-команде. Используй массив аргументов."
fi

# Hardcoded secrets
if echo "$CONTENT" | grep -E "(password\s*=\s*['\"][^'\"]+['\"]|api_key\s*=\s*['\"][^'\"]+['\"]|secret\s*=\s*['\"][^'\"]+['\"]|token\s*=\s*['\"][A-Za-z0-9])" > /dev/null 2>&1; then
  # Исключаем env/example файлы
  if ! echo "$FILE_PATH" | grep -E '\.(env|example|sample|template)' > /dev/null 2>&1; then
    WARNINGS="$WARNINGS\n🔴 HARDCODED SECRET: Найден захардкоженный секрет. Вынеси в .env."
  fi
fi

# Unsafe deserialization
if echo "$CONTENT" | grep -E "(pickle\.loads?|yaml\.load\(|eval\(request|exec\(request)" > /dev/null 2>&1; then
  WARNINGS="$WARNINGS\n🔴 UNSAFE DESERIALIZATION: Используй безопасные альтернативы (yaml.safe_load, json)."
fi

if [ -n "$WARNINGS" ]; then
  echo "{\"decision\": \"block\", \"reason\": \"⛔ Security Scan нашёл проблемы в $FILE_PATH:$(echo -e $WARNINGS)\"}"
fi
