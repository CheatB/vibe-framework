# /status — Мониторинг всех сервисов

Проверь состояние всех сервисов на всех VPS серверах.

## Проверки для каждого VPS

### vps-main (<SERVER_IP>)
```bash
echo "=== VPS-MAIN ==="
# Контейнеры Docker
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker не запущен"
# Диск
df -h / | tail -1
# RAM
free -h | grep Mem
# Load
uptime
# Systemd сервисы (если есть)
systemctl list-units --state=running --type=service --no-pager | grep -E '(bot|app|web|api)' 2>/dev/null || true
```

### vps-second, vps-n8n, vps-dev-server
Аналогичные проверки через соответствующие SSH MCP.

## Сводная таблица
Покажи результат как:
```
━━━ 📊 STATUS: Все сервисы ━━━

VPS-MAIN (<SERVER_IP>)
  🟢 project-1-bot      — Up 3 days    — :8443
  🟢 project-1-db       — Up 3 days    — :5432
  ⚪ Диск: 45% (12G/25G)
  ⚪ RAM: 1.2G / 4G
  ⚪ Load: 0.15

VPS-SECOND
  🟢 project-app-api  — Up 7 days    — :3000
  🔴 project-app-worker — Exited 2h ago
  ⚪ Диск: 67% (8G/12G)

VPS-N8N
  🟢 n8n             — Up 14 days   — :5678
  ⚪ Диск: 23% (3G/12G)

Проблемы: 1 сервис упал (project-app-worker на vps-second)
```

## Правила
- 🟢 = работает, 🟡 = перезапускался недавно, 🔴 = не работает
- Если сервис упал — предложи `docker compose restart <service>` или посмотреть логи
- Проверяй ВСЕ VPS, не пропускай
- Показывай предупреждения если диск > 80% или RAM > 90%
