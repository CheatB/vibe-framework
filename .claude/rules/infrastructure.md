# Инфраструктура — карта VPS и правила работы

## Философия

**Один VPS для разработки, остальные — только продакшен.**

Весь код пишется и тестируется на **secondbrain**. На продакшен-серверы код попадает ТОЛЬКО через git (push → GitHub Actions runner → SSH → docker compose up). Никакого ручного редактирования кода на проде.

**Зачем:**
- Единая точка правды — все исходники, конфиги, секреты в одном месте
- Безопасность — SSH-ключи для деплоя только на secondbrain
- Контроль — любое изменение в проде проходит через git history
- Откат — всегда можно вернуться к предыдущему коммиту

---

## Карта серверов

### secondbrain (DEV) — центральный узел

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-secondbrain__exec` |
| Hostname | cmiioiydtb |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Разработка, CI/CD runners, инфра-сервисы |

**Что живёт:**
- GitHub Actions self-hosted runners (6 шт.): grambotica-bot-main, grambotica-bot-server, openclaw, stackovervibe, vibefactory, zachot
- Obsidian CouchDB (синхронизация заметок)
- SearXNG (поисковый движок)
- Uptime Kuma (мониторинг доступности)
- StackOverVibe dev-инстанс (для тестирования)
- Grambotica исходники (Gradle-проект)
- Claude Framework (`~/.claude/` + `~/claude-config/`)

**SSH-ключи к остальным VPS:** `~/.ssh/id_ed25519` + конфиг в `~/.ssh/config`

---

### vps-main — Zachot

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-main__exec` |
| Hostname | hoycyrlmat |
| IP | 31.128.42.135 |
| ОС | Ubuntu 22.04 |
| Пользователи | claude, deploy |
| Роль | Продакшен Zachot |

**Что живёт:** Zachot (API + Worker на systemd, без Docker)
**Путь проекта:** `/home/deploy/zachot` (деплой) + `/home/claude/zachot` (копия)
**Деплой:** `git pull` → `deploy_backend.sh` → `deploy_frontend.sh` → systemd restart

**Особенность:** Docker установлен, но у пользователя `claude` нет прав на docker socket. Zachot работает через systemd, не через Docker.

---

### whynotmonth — Grambotica

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-whynotmonth__exec` |
| Hostname | jodfxbzqic |
| IP | 31.129.98.220 |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Продакшен Grambotica |

**Что живёт (Docker):**
- grambotica-bot-main (Telegram-бот)
- grambotica-bot-server (сервер)
- tbank-proxy (прокси платежей)
- grambotica-postgres
- grambotica-redis
- Watchdog-скрипты (event, payment, proxy)

**Особенность:** Docker установлен, но у пользователя `claude` нет прав. Деплой через runner на secondbrain.

---

### openclaw — OpenClaw

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-openclaw__exec` |
| Hostname | pyodmbnajm |
| IP | 2.58.98.230 |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Продакшен OpenClaw |

**Что живёт (Docker):** SearXNG (часть функционала OpenClaw)

---

### aware-anton — VibeFactory

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-aware-anton__exec` |
| Hostname | content-factory-vps |
| IP | 155.212.144.166 |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Продакшен VibeFactory |

**Что живёт (Docker):**
- vibe-factory-nginx (reverse proxy)
- vibe-factory-web (Django)
- vibe-factory-celery-worker
- vibe-factory-celery-beat
- vibe-factory-flower (мониторинг Celery)
- vibe-factory-postgres
- vibe-factory-redis

---

### wholehearted-igor — StackOverVibe

| Параметр | Значение |
|----------|----------|
| MCP-тул | `mcp__vps-wholehearted-igor__exec` |
| Hostname | web-page-cheatb-vibe |
| IP | 109.172.36.108 |
| ОС | Ubuntu 24.04 |
| Пользователь | claude |
| Роль | Продакшен StackOverVibe |

**Что живёт (Docker):**
- stackovervibe-app
- stackovervibe-postgres

---

## SSH-топология

```
              ┌──────────────┐
              │  secondbrain │  ← DEV (код пишется тут)
              │  (центр)     │
              └──────┬───────┘
                     │ SSH (~/.ssh/id_ed25519)
        ┌────────────┼────────────────┬──────────────┐
        │            │                │              │
   ┌────▼────┐  ┌────▼─────┐  ┌──────▼─────┐  ┌────▼────┐  ┌────────────┐
   │ zachot  │  │whynotmon │  │  openclaw   │  │ aware-  │  │wholeheart- │
   │ :42.135 │  │ :98.220  │  │  :98.230   │  │ anton   │  │  ed-igor   │
   │ Zachot  │  │Grambotica│  │  OpenClaw   │  │VibeFact.│  │StackOverV. │
   └─────────┘  └──────────┘  └────────────┘  └─────────┘  └────────────┘
```

SSH-конфиг на secondbrain (`~/.ssh/config`):
- Все хосты доступны по алиасам: `ssh zachot`, `ssh whynotmonth`, `ssh openclaw`, `ssh vibe-factory`, `ssh stackovervibe`
- Единый ключ `~/.ssh/id_ed25519` для всех продакшен-серверов
- Отдельный ключ `~/.ssh/github_secondbrain` для GitHub

---

## Деплой-пайплайн

### Общий flow

```
Код на secondbrain → git push → GitHub → Actions runner (на secondbrain)
                                              ↓
                                    SSH на целевой VPS
                                              ↓
                                    git pull → docker compose up -d --build
                                              ↓
                                    Health check → OK / Rollback
```

### deploy-all.sh (на secondbrain)

Центральный скрипт деплоя: `~/deploy-all.sh`

```bash
# Деплой всех проектов
./deploy-all.sh

# Деплой одного проекта
./deploy-all.sh stackovervibe

# Dry-run (без реальных действий)
./deploy-all.sh --dry-run

# Откат
./deploy-all.sh stackovervibe --rollback
```

**Маппинг проект → VPS → путь:**

| Проект | SSH-алиас | Путь на проде |
|--------|-----------|---------------|
| zachot | zachot | /home/deploy/zachot |
| stackovervibe | stackovervibe | /home/claude/stackovervibe |
| openclaw | openclaw | /home/claude/openclaw |
| grambotica (whynotmonth) | whynotmonth | /home/claude/grambotica |
| vibe-factory | vibe-factory | /home/claude/vibefactory |

### Health checks

После деплоя автоматически проверяются:
- zachot: `http://localhost:8000/health`
- whynotmonth (grambotica): `http://localhost:8080/health`
- vibe-factory: `http://localhost:8000/health`

Если health check не проходит за 5 попыток (15 сек) → автоматический rollback.

---

## Бэкап секретов

`~/backup-secrets.sh` на secondbrain:
1. Собирает `.env` файлы со всех VPS (dev + prod) по SSH
2. Шифрует GPG (AES256)
3. Пушит в приватный GitHub-репо
4. Хранит 10 последних бэкапов

---

## Синхронизация фреймворка

### Источник правды: `CheatB/vibe-framework`

Репозиторий `vibe-framework` содержит весь фреймворк: CLAUDE.md, rules/, commands/, skills/, hooks/.

### Синхронизация на secondbrain

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

Добавить cron-задачу на secondbrain:
```bash
# Каждые 30 минут проверять обновления фреймворка
*/30 * * * * cd ~/vibe-framework && git pull origin master && ./sync.sh pull >> /home/claude/logs/framework-sync.log 2>&1
```

---

## Правила для Claude

### При разработке
1. **Код пишем ТОЛЬКО через `mcp__vps-secondbrain__exec`** — это единственный dev-сервер
2. Перед деплоем — `git push` через secondbrain (там GitHub-токен с полным доступом)
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
| secondbrain | (определить через MCP) |
| zachot | 31.128.42.135 |
| whynotmonth | 31.129.98.220 |
| openclaw | 2.58.98.230 |
| aware-anton | 155.212.144.166 |
| wholehearted-igor | 109.172.36.108 |

---

## Провайдер

Все VPS на **Beget** (beget.com). Управление через панель Beget.
