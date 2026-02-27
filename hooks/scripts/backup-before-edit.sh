#!/bin/bash
# Backup Before Edit — создаёт .bak копию файла перед изменением

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Создаём директорию для бэкапов
BACKUP_DIR="$HOME/.claude/backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

# Имя файла: оригинальное_имя.timestamp.bak
BASENAME=$(basename "$FILE_PATH")
BACKUP_FILE="$BACKUP_DIR/${BASENAME}.$(date +%H%M%S).bak"

cp "$FILE_PATH" "$BACKUP_FILE" 2>/dev/null

# Чистим старые бэкапы (старше 7 дней)
find "$HOME/.claude/backups" -type f -name "*.bak" -mtime +7 -delete 2>/dev/null
find "$HOME/.claude/backups" -type d -empty -delete 2>/dev/null
