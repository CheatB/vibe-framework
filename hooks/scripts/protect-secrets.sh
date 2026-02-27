#!/bin/bash
# Защита критических файлов от перезаписи
# Блокирует: .env (не .env.example), credentials, ключи

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# Разрешённые env файлы
SAFE_ENV="\.env\.example|\.env\.sample|\.env\.template|\.env\.local\.example"

# Блокируемые файлы
if echo "$BASENAME" | grep -E '^\.(env|env\.local|env\.production|env\.staging)$' > /dev/null 2>&1; then
  if ! echo "$BASENAME" | grep -E "($SAFE_ENV)" > /dev/null 2>&1; then
    echo "{\"decision\": \"block\", \"reason\": \"⛔ ЗАБЛОКИРОВАНО: попытка изменить $BASENAME. Секреты редактируй вручную.\"}"
    exit 0
  fi
fi

# Приватные ключи
if echo "$FILE_PATH" | grep -E '(id_rsa|id_ed25519|\.pem|\.key|credentials\.json|service-account)' > /dev/null 2>&1; then
  if ! echo "$FILE_PATH" | grep -E '\.pub$' > /dev/null 2>&1; then
    echo "{\"decision\": \"block\", \"reason\": \"⛔ ЗАБЛОКИРОВАНО: попытка изменить приватный ключ/credentials.\"}"
    exit 0
  fi
fi
