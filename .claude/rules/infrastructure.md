# Инфраструктура — карта VPS и правила работы

## Философия

**Один VPS для разработки, остальные — только продакшен.**

Весь код пишется и тестируется на **dev-server**. На продакшен-серверы код попадает ТОЛЬКО через git (push → GitHub Actions runner → SSH → docker compose up). Никакого ручного редактирования кода на проде.

**Зачем:**
- Единая точка правды — все исходники, конфиги, секреты в одном месте
- Безопасность — SSH-ключи для деплоя только на dev-server
- Контроль — любое изменение в проде проходит через git history
- Откат — всегда можно вернуться к предыдущему коммиту

---

## Карта серверов

### dev-server (DEV) — центральный узел

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-dev-server__exec` |
| Hostname | <YOUR_HOSTNAME> |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Разработка, CI/CD runners, инфра-сервисы |

**Что живёт:**
- GitHub Actions self-hosted runners (6 шт.): runner-1, runner-2, runner-3, runner-4, runner-5, runner-6
- Obsidian CouchDB (синхронизация заметок)
- SearXNG (поисковый движок)
- Uptime Kuma (мониторинг доступности)
- Project-2 dev-инстанс (для тестирования)
- Project-4 исходники (Gradle-проект)
- Claude Framework (`~/.claude/` + `~/claude-config/`)

**SSH-ключи к остальным VPS:** `~/.ssh/id_ed25519` + конфиг в `~/.ssh/config`

---

### vps-project-1 — Project-1

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-project-1__exec` |
| Hostname | <YOUR_HOSTNAME> |
| IP | <YOUR_SERVER_IP> |
| ОС | Ubuntu 22.04 |
| Пользователи | claude, deploy |
| Роль | Продакшен Project-1 |

**Что живёт:** Project-1 (API + Worker на systemd, без Docker)
**Путь проекта:** `/home/deploy/project-1` (деплой) + `/home/claude/project-1` (копия)
**Деплой:** `git pull` → `deploy_backend.sh` → `deploy_frontend.sh` → systemd restart

**Особенность:** Docker установлен, но у пользователя `claude` нет прав на docker socket. Project-1 работает через systemd, не через Docker.

---

### project-4 — Project-4

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-project-4__exec` |
| Hostname | <YOUR_HOSTNAME> |
| IP | <YOUR_SERVER_IP> |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Продакшен Project-4 |

**Что живёт (Docker):**
- project-4-bot-main (Telegram-бот)
- project-4-bot-server (сервер)
- tbank-proxy (прокси платежей)
- project-4-postgres
- project-4-redis
- Watchdog-скрипты (event, payment, proxy)

**Особенность:** Docker установлен, но у пользователя `claude` нет прав. Деплой через runner на dev-server.

---

### project-5 — Project-5

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-project-5__exec` |
| Hostname | <YOUR_HOSTNAME> |
| IP | <YOUR_SERVER_IP> |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Продакшен Project-5 |

**Что живёт (Docker):** SearXNG (часть функционала Project-5)

---

### vps-project-3 — Project-3

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-vps-project-3__exec` |
| Hostname | <YOUR_HOSTNAME> |
| IP | <YOUR_SERVER_IP> |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Продакшен Project-3 |

**Что живёт (Docker):**
- project-3-nginx (reverse proxy)
- project-3-web (Django)
- project-3-celery-worker
- project-3-celery-beat
- project-3-flower (мониторинг Celery)
- project-3-postgres
- project-3-redis

---

### vps-project-2 — Project-2

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-vps-project-2__exec` |
| Hostname | <YOUR_HOSTNAME> |
| IP | <YOUR_SERVER_IP> |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Продакшен Project-2 |

**Что живёт (Docker):**
- project-2-app
- project-2-postgres

---

## SSH-топология

```
              ┌──────────────┐
              │  dev-server │  ← DEV (код пишется тут)
              │  (центр)     │
              └──────┬───────┘
                     │ SSH (~/.ssh/id_ed25519)
        ┌────────────┼────────────────┬──────────────┐
        │            │                │              │
   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
   │project-1 │  │project-4 │  │project-5 │  │project-3 │  │project-2 │
   │ PROD #1  │  │ PROD #4  │  │ PROD #5  │  │ PROD #3  │  │ PROD #2  │
   └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘
```

SSH-конфиг на dev-server (`~/.ssh/config`):
- Все хосты доступны по алиасам: `ssh project-1`, `ssh project-4`, `ssh project-5`, `ssh project-3`, `ssh project-2`
- Единый ключ `~/.ssh/id_ed25519` для всех продакшен-серверов
- Отдельный ключ `~/.ssh/github_key` для GitHub

---

## Деплой-пайплайн

### Общий flow

```
Код на dev-server → git push → GitHub → Actions runner (на dev-server)
                                              ↓
                                    SSH на целевой VPS
                                              ↓
                                    git pull → docker compose up -d --build
                                              ↓
                                    Health check → OK / Rollback
```

### deploy-all.sh (на dev-server)

Центральный скрипт деплоя: `~/deploy-all.sh`

```bash
# Деплой всех проектов
./deploy-all.sh

# Деплой одного проекта
./deploy-all.sh project-2

# Dry-run (без реальных действий)
./deploy-all.sh --dry-run

# Откат
./deploy-all.sh project-2 --rollback
```

**Маппинг проект → VPS → путь:**

| Проект | SSH-алиас | Путь на проде |
|--------|-----------|---------------|
| project-1 | project-1 | /home/deploy/project-1 |
| project-2 | project-2 | /home/claude/project-2 |
| project-5 | project-5 | /home/claude/project-5 |
| project-4 (project-4) | project-4 | /home/claude/project-4 |
| project-3 | project-3 | /home/claude/project-3 |

### Health checks

После деплоя автоматически проверяются:
- project-1: `http://localhost:8000/health`
- project-4 (project-4): `http://localhost:8080/health`
- project-3: `http://localhost:8000/health`

Если health check не проходит за 5 попыток (15 сек) → автоматический rollback.

---

## Бэкап секретов

`~/backup-secrets.sh` на dev-server:
1. Собирает `.env` файлы со всех VPS (dev + prod) по SSH
2. Шифрует GPG (AES256)
3. Пушит в приватный GitHub-репо
4. Хранит 10 последних бэкапов

---

## Синхронизация фреймворка

### Источник правды: `CheatB/vibe-framework`

Репозиторий `vibe-framework` содержит весь фреймворк: CLAUDE.md, rules/, commands/, skills/, hooks/.

### Синхронизация на dev-server

```bash
# Подтянуть обновления фреймворка
cd ~/vibe-framework && git pull origin master
# Скопировать в ~/.claude/
./sync.sh pull

# Запушить локальные изменения
./sync.sh push
```

sync.sh копирует файлы из репо в `~/.claude/` (CLAUDE.md, commands/, rules/, skills/, hooks/).

### Автоматическое обновление (рекомендация)

Добавить cron-задачу на dev-server:
```bash
# Каждые 30 минут проверять обновления фреймворка
*/30 * * * * cd ~/vibe-framework && git pull origin master && ./sync.sh pull >> /home/claude/logs/framework-sync.log 2>&1
```

---

## Правила для Claude

### При разработке
1. **Код пишем ТОЛЬКО через `mcp__vps-dev-server__exec`** — это единственный dev-сервер
2. Перед деплоем — `git push` через dev-server (там GitHub-токен с полным доступом)
3. Для проверки прода — читаем логи через MCP-тулы соответствующего VPS

### При деплое
1. Никогда не редактировать код напрямую на продакшен-VPS
2. Только `deploy-all.sh` или GitHub Actions runners
3. Всегда проверять health check после деплоя
4. При проблемах — `./deploy-all.sh <проект> --rollback`

### Лимиты MCP-тулов
- Команды через `mcp__vps-*__exec` ограничены **1000 символов**
- Для длинных команд: записать в файл → bash файл
- Для передачи файлов: git push/pull (не scp через MCP)

---

## Домены

На данный момент все VPS доступны только по IP. Домены не привязаны.

| VPS | IP |
|-----|------|
| dev-server | (определить через MCP) |
| project-1 | <YOUR_SERVER_IP> |
| project-4 | <YOUR_SERVER_IP> |
| project-5 | <YOUR_SERVER_IP> |
| vps-project-3 | <YOUR_SERVER_IP> |
| vps-project-2 | <YOUR_SERVER_IP> |

---

## Провайдер

Все VPS на **Beget** (beget.com). Управление через панель Beget.
