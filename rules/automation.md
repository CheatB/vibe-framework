# Правила автоматизации

## Что покрыто хуками (НЕ дублируй инструкциями)

Следующее реализовано как настоящие Claude Code hooks в проектных `.claude/settings.json`:
- **PostToolUse Edit/Write → prettier/black/isort** — хук `post-edit-format.sh`
- **Stop → console.log/debugger/print()** — хук `stop-check-debug.sh`
- **Stop → незакоммиченные изменения + ПРОГРЕСС** — хук `stop-check-progress.sh`
- **SessionStart → загрузка прогресса** — хук `session-start-progress.sh`
- **PostToolUse Edit/Write → логирование файлов** — хук `track-changes.sh`
- **Stop → code-simplifier** — глобальный prompt hook

## Что остаётся правилами (нужно суждение LLM)

### Долгие команды
Перед запуском `npm install`, `cargo build`, `pytest`, `pnpm install`:
- Напомни про `tmux` для сохранения сессии

### Git push
Перед `git push`:
- Проверь, что нет незакоммиченных изменений
- Если protected branch — предложи PR

### Создание .md файлов
Перед созданием `.md` (кроме README.md, CLAUDE.md):
- Спроси: "Точно нужен этот .md файл?"

## Auto-Fix Pipeline

### Уровень 1: Коммит упал
git commit упал → читай ошибку → исправляй → коммить заново (макс 3 попытки)

### Уровень 2: Push отклонён
git push rejected → rebase для конфликтов, PR для protected branch

### Уровень 3: CI/CD упал
После push проверяй `gh run list --limit 1`. Упал → логи → fix-коммит → повтор (макс 3)

### Уровень 4: Деплой упал
Логи → fix → рестарт. Макс 3 попытки, потом `git revert HEAD && git push`

### Общее правило
- Сначала пытайся исправить сам
- Макс 3 попытки на каждом уровне
- Fix-коммиты с префиксом `fix:`
- Всегда сообщай что произошло
