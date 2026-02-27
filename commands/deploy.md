# /deploy — Деплой на VPS

Деплой текущего проекта на VPS.

## Определи окружение
Проверь наличие:
- `docker-compose.yml` / `docker-compose.yaml` → Docker деплой
- `ecosystem.config.js` → PM2 деплой
- `systemd/` или `.service` файлы → Systemd деплой

## Docker деплой (по умолчанию)

### 1. Подключись к VPS через SSH MCP
Определи нужный сервер по проекту:
- Zachot → vps-main
- Grambotica → vps-second
- Другие → спроси пользователя

### 2. Обнови код
```bash
cd /home/deploy/<project>
git pull origin main
```

### 3. Пересобери и перезапусти
```bash
docker compose build --no-cache
docker compose up -d
```

### 4. Проверь health
```bash
# Подожди 10 секунд на старт
sleep 10
# Проверь контейнеры
docker compose ps
# Проверь логи на ошибки
docker compose logs --tail 20 2>&1 | grep -iE '(error|exception|fatal|traceback)' || echo "✅ Ошибок не найдено"
# Если есть endpoint — проверь curl
curl -sf http://localhost:<port>/health 2>/dev/null && echo "✅ Health OK" || echo "⚠️ Health check недоступен"
```

### 5. Если деплой упал
- Прочитай логи: `docker compose logs --tail 50`
- Определи причину
- Исправь (макс 3 попытки)
- Если не удалось: `git revert HEAD && git push && docker compose up -d` (откат)

### 6. Отчёт
```
━━━ 🚀 DEPLOY COMPLETE ━━━
Сервер: <vps-name>
Проект: <project>
Контейнеры: [N] running
Health: OK/FAIL
Время: ~[X] мин
```
