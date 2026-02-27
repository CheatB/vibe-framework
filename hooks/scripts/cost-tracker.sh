#!/bin/bash
# Стоимость трекер — логирует расход токенов после каждой сессии
# Лог: ~/.claude/usage-log.csv

LOG_FILE="$HOME/.claude/usage-log.csv"

# Создаём файл с заголовком если не существует
if [ ! -f "$LOG_FILE" ]; then
  echo "date,time,project,branch,duration_hint,session_marker" > "$LOG_FILE"
fi

# Собираем данные
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
PROJECT=$(basename "$(pwd)" 2>/dev/null || echo "unknown")
BRANCH=$(git branch --show-current 2>/dev/null || echo "no-git")

# Записываем строку
echo "$DATE,$TIME,$PROJECT,$BRANCH,stop,session_end" >> "$LOG_FILE"

# Показываем сводку за сегодня
TODAY_COUNT=$(grep "^$DATE" "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')

echo "{\"systemMessage\": \"📊 Сессия записана. Сегодня сессий: $TODAY_COUNT | Лог: ~/.claude/usage-log.csv\"}"
