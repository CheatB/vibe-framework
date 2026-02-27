#!/bin/bash
# 🔍 Migration Check — проверка безопасности миграций при работе с файлами миграций
# Триггер: PreToolUse на Write|Edit файлов в папках migration/migrations/alembic

# Получаем путь к файлу из CLAUDE_TOOL_INPUT
FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // .path // empty' 2>/dev/null)

# Проверяем что это файл миграции
if ! echo "$FILE_PATH" | grep -qiE '(migration|migrate|alembic|prisma/migrations)'; then
  exit 0
fi

WARNINGS=""

# Получаем содержимое (новое или существующее)
CONTENT=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.content // .new_string // empty' 2>/dev/null)

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Проверка 1: DROP TABLE без бэкапа
if echo "$CONTENT" | grep -qiE 'drop\s+table'; then
  WARNINGS="$WARNINGS\n⚠️ DROP TABLE обнаружен — убедись что есть бэкап!"
fi

# Проверка 2: DROP COLUMN
if echo "$CONTENT" | grep -qiE 'drop\s+column|drop_column'; then
  WARNINGS="$WARNINGS\n⚠️ DROP COLUMN — данные будут потеряны необратимо!"
fi

# Проверка 3: TRUNCATE
if echo "$CONTENT" | grep -qiE 'truncate'; then
  WARNINGS="$WARNINGS\n⚠️ TRUNCATE обнаружен — все данные будут удалены!"
fi

# Проверка 4: Нет downgrade/rollback
if echo "$CONTENT" | grep -qiE 'def upgrade|exports\.up'; then
  if ! echo "$CONTENT" | grep -qiE 'def downgrade|exports\.down'; then
    WARNINGS="$WARNINGS\n❌ Нет downgrade/rollback функции в миграции!"
  fi
fi

# Проверка 5: ALTER TABLE без CONCURRENTLY для индексов
if echo "$CONTENT" | grep -qiE 'create\s+index' && ! echo "$CONTENT" | grep -qiE 'concurrently'; then
  WARNINGS="$WARNINGS\n⚠️ CREATE INDEX без CONCURRENTLY — может заблокировать таблицу!"
fi

# Проверка 6: NOT NULL без DEFAULT
if echo "$CONTENT" | grep -qiE 'not\s+null' && ! echo "$CONTENT" | grep -qiE 'default'; then
  WARNINGS="$WARNINGS\n⚠️ NOT NULL без DEFAULT — может сломать существующие данные!"
fi

# Вывод
if [ -n "$WARNINGS" ]; then
  echo "{\"systemMessage\": \"🔍 Migration Check:$(echo -e "$WARNINGS")\"}"
fi
