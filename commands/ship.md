# /ship — Полный цикл доставки кода

Выполни полный цикл доставки от коммита до продакшна:

## Шаги:

### 1. Предварительные проверки
- Запусти линтер (`npx eslint .` или `ruff check .` в зависимости от проекта)
- Запусти typecheck (`npx tsc --noEmit` для TS или `mypy .` для Python)
- Запусти тесты (`npm test` или `pytest`)
- Если что-то упало — ИСПРАВЬ АВТОМАТИЧЕСКИ и повтори (макс 3 попытки)

### 2. Git commit
- `git add -A`
- Предложи сообщение коммита в формате Conventional Commits
- Спроси подтверждение у пользователя
- `git commit -m "..."` 

### 3. Git push
- `git push origin <текущая_ветка>`
- Если push отклонён — `git pull --rebase`, разреши конфликты, push снова

### 4. Проверка CI/CD (если есть GitHub Actions)
- Подожди 30 секунд
- Проверь: `gh run list --limit 1 --json status,conclusion`
- Если fail — получи логи `gh run view <id> --log-failed`, исправь, повтори с шага 1

### 5. Отчёт
Покажи итог:
```
━━━ 📦 SHIP COMPLETE ━━━
✅ Lint: passed
✅ Types: passed
✅ Tests: [X] passed, [Y] failed
✅ Commit: <hash> — <message>
✅ Push: origin/<branch>
✅ CI/CD: passed
```

## Важно
- НЕ пушь если тесты не прошли (после 3 попыток автоисправления — покажи ошибку)
- ВСЕГДА жди подтверждения коммит-сообщения от пользователя
- Используй маркеры из workflow-markers.md
