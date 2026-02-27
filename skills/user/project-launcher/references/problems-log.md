# Problems Log

Global log of issues encountered across all projects, their solutions, and lessons learned.

## Location

**Second Brain:** `development/problems-log.md`

**Scope:** ALL projects share this log

---

## Purpose

**Problems Log serves to:**
- Document issues and their solutions
- Learn from mistakes
- Prevent repeating the same errors
- Build institutional knowledge
- Share solutions across projects

**Claude reads this log:**
- Before starting any new project
- When encountering similar issues
- When making architectural decisions

---

## Format

Each entry follows this structure:

```markdown
## YYYY-MM-DD | ProjectName | TaskID | Problem Title

**Проблема:** 
[Detailed description of what went wrong]

**Контекст:**
- Environment: [dev/staging/prod]
- Tech stack: [relevant technologies]
- Timeline: [when discovered]

**Решение:**
[How it was fixed, step by step]

**Код:** (if applicable)
```python
# Solution code here
```

**Урок:**
[Key takeaway for future projects]

**Теги:** #category #technology #type

---
```

---

## Real Examples

### Example 1: Database Connection

```markdown
## 2026-01-15 | zachot | Task-2.3 | PostgreSQL Connection Pooling

**Проблема:**
После деплоя на VPS бот начал падать с ошибкой:
"too many connections" при 50+ одновременных пользователях.

**Контекст:**
- Environment: Production (vps-main)
- Tech stack: Python 3.11, asyncpg, PostgreSQL 14
- Timeline: Обнаружено через 2 часа после запуска

**Решение:**
1. Добавил connection pooling в database.py:
   ```python
   pool = await asyncpg.create_pool(
       dsn=DATABASE_URL,
       min_size=5,
       max_size=20,  # Было: создавалось новое соединение каждый раз
       command_timeout=60
   )
   ```
2. Переиспользовал соединения из пула
3. Настроил max_connections в PostgreSQL до 100

**Код:**
```python
# database.py
import asyncpg

class Database:
    def __init__(self):
        self.pool = None
    
    async def connect(self):
        self.pool = await asyncpg.create_pool(
            dsn=settings.DATABASE_URL,
            min_size=5,
            max_size=20,
            command_timeout=60
        )
    
    async def fetch(self, query, *args):
        async with self.pool.acquire() as conn:
            return await conn.fetch(query, *args)
```

**Урок:**
ВСЕГДА использовать connection pooling в production.
В dev можно без него, но в prod обязательно.

**Теги:** #database #postgresql #production #performance #connection-pooling

---
```

### Example 2: Telegram Rate Limits

```markdown
## 2026-01-20 | emoji_bot | Task-3.5 | Telegram Flood Control

**Проблема:**
Бот забанен на 2 часа за превышение rate limits при массовой рассылке.

**Контекст:**
- Environment: Production
- Tech stack: Aiogram 3.x, Python 3.11
- Timeline: Во время первой массовой рассылки (500 пользователей)

**Решение:**
1. Добавил rate limiting с использованием aiogram_broadcaster:
   ```python
   from aiogram_broadcaster import MessageBroadcaster
   
   broadcaster = MessageBroadcaster(
       bot=bot,
       chats=user_ids,
       interval=0.05  # 20 сообщений/сек (безопасно)
   )
   ```
2. Разбил рассылку на батчи по 100 пользователей
3. Добавил задержку 3 секунды между батчами

**Код:**
```python
async def send_broadcast(bot: Bot, user_ids: list, message: str):
    from aiogram_broadcaster import MessageBroadcaster
    
    # Батчи по 100
    batch_size = 100
    for i in range(0, len(user_ids), batch_size):
        batch = user_ids[i:i + batch_size]
        
        broadcaster = MessageBroadcaster(
            bot=bot,
            chats=batch,
            interval=0.05  # 20 msg/sec
        )
        
        await broadcaster.run(message)
        
        # Пауза между батчами
        if i + batch_size < len(user_ids):
            await asyncio.sleep(3)
```

**Урок:**
Для рассылок использовать aiogram_broadcaster с rate limiting.
Telegram limits: 30 msg/sec to different users, но безопаснее 20 msg/sec.

**Теги:** #telegram #ratelimit #broadcast #aiogram #production

---
```

### Example 3: Git Secrets Leak

```markdown
## 2026-01-25 | landing-project | Task-1.2 | .env in Git History

**Проблема:**
Случайно закоммитил .env с API ключами в публичный репозиторий.

**Контекст:**
- Environment: Development
- Tech stack: Next.js, GitHub
- Timeline: Обнаружено через 10 минут после push

**Решение:**
1. Сразу инвалидировал все ключи
2. Удалил .env из истории Git:
   ```bash
   git filter-repo --invert-paths --path .env
   git push origin --force --all
   ```
3. Добавил .env в .gitignore (БЫЛО УЖЕ, но забыл проверить)
4. Создал .env.example с заглушками
5. Настроил pre-commit hook для проверки секретов

**Код:**
```bash
# .git/hooks/pre-commit
#!/bin/bash
# Проверка на случайный коммит .env

if git diff --cached --name-only | grep -q "\.env$"; then
    echo "❌ ОШИБКА: Попытка закоммитить .env файл!"
    echo "Используй .env.example для шаблонов"
    exit 1
fi

# Проверка на секреты в коде
if git diff --cached | grep -iE "(api[_-]?key|secret|password|token).*=.*['\"].*['\"]"; then
    echo "⚠️  ВНИМАНИЕ: Возможно секреты в коде!"
    echo "Проверь файлы перед коммитом"
    read -p "Продолжить? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
```

**Урок:**
1. ВСЕГДА проверяй .gitignore перед первым коммитом
2. Используй pre-commit hooks для автопроверки
3. Инвалидируй ключи сразу, не жди
4. git filter-repo для очистки истории

**Теги:** #security #git #secrets #prevention

---
```

---

## Entry Categories

### By Type

**#bug** — Runtime bugs  
**#security** — Security issues  
**#performance** — Performance problems  
**#deployment** — Deployment issues  
**#configuration** — Config errors  
**#integration** — Third-party integration issues  
**#database** — Database problems  
**#testing** — Testing challenges  
**#architecture** — Architectural decisions

### By Technology

**#python** **#nodejs** **#postgresql** **#redis** **#docker** **#nginx** **#telegram** **#nextjs** **#fastapi** **#aiogram**

### By Environment

**#development** **#staging** **#production**

---

## How Claude Uses It

### Before New Project

```
Claude: 
Starting new project: telegram-bot

📖 Reading problems-log.md...

Found relevant entries:
- PostgreSQL connection pooling (#database #postgresql)
- Telegram rate limits (#telegram #ratelimit)
- Environment variables handling (#security #configuration)

Will apply these lessons during development.
```

### During Development

```
User: Добавь массовую рассылку

Claude:
Проверяю problems-log...

⚠️ Важный урок из emoji_bot (2026-01-20):
Telegram имеет rate limits для рассылок.

Рекомендую:
- Использовать aiogram_broadcaster
- Rate: 20 msg/sec (безопасно)
- Батчи по 100 пользователей
- Пауза 3 сек между батчами

Применить этот подход? (да/нет)
```

### When Problem Occurs

```
Claude:
Ошибка: too many connections

Проверяю problems-log...

✓ Найдено решение из zachot (2026-01-15)

Проблема: PostgreSQL connection pooling
Решение: Добавить asyncpg pool с min_size=5, max_size=20

Применяю проверенное решение...
```

---

## Best Practices

### 1. Document Immediately

```
❌ Плохо:
"Исправлю сейчас, задокументирую потом"
→ Забывается

✅ Хорошо:
1. Решаем проблему
2. Сразу документируем
3. Коммитим в Second Brain
```

### 2. Be Specific

```
❌ Плохо:
## 2026-01-15 | zachot | Database Error

Была ошибка с базой. Починил.

✅ Хорошо:
## 2026-01-15 | zachot | Task-2.3 | PostgreSQL Connection Pooling

**Проблема:**
[Detailed description with error message]

**Решение:**
[Step by step what was done]

**Код:**
[Actual code that fixed it]
```

### 3. Include Code

```
❌ Плохо:
Добавил connection pooling

✅ Хорошо:
```python
pool = await asyncpg.create_pool(
    dsn=DATABASE_URL,
    min_size=5,
    max_size=20
)
```
```

### 4. Tag Properly

```
❌ Плохо:
**Теги:** #проблема

✅ Хорошо:
**Теги:** #database #postgresql #production #performance #connection-pooling
```

Multiple specific tags help finding entries later

### 5. Extract Lessons

```
❌ Плохо:
**Урок:**
Надо было сделать по-другому

✅ Хорошо:
**Урок:**
ВСЕГДА использовать connection pooling в production.
В development можно без него для простоты, но в production обязательно.
Рекомендуемые настройки: min_size=5, max_size=20.
```

---

## Searching Problems Log

### By Tag

```
User: Что у нас было с PostgreSQL?

Claude:
Ищу в problems-log по тегу #postgresql...

Найдено 3 записи:
1. Connection pooling (2026-01-15)
2. Migration conflicts (2026-01-18)
3. Index optimization (2026-01-22)

Какую хочешь посмотреть?
```

### By Project

```
User: Какие проблемы были в проекте zachot?

Claude:
Фильтрую по ProjectName = zachot...

5 записей:
1. PostgreSQL connection pooling
2. Telegram webhook setup
3. Redis session storage
4. Docker networking
5. Systemd service config
```

### By Date

```
User: Что случилось на прошлой неделе?

Claude:
Проблемы 2026-01-20 to 2026-01-27:

1. emoji_bot: Telegram rate limits
2. landing-project: Git secrets leak
3. zachot: Redis connection timeout
```

---

## Maintenance

### Monthly Review

```
Claude: 
Месячный обзор problems-log.md

Статистика:
- Всего записей: 47
- Новых за месяц: 12
- Категории:
  - #database: 8
  - #security: 3
  - #deployment: 5
  - #performance: 4

Частые проблемы:
1. Database connection issues (4 раза)
2. Rate limiting (3 раза)

Рекомендация: Создать best practices документ для:
- Database connection pooling
- Rate limiting стратегии
```

### Archiving Old Entries

```
# После 1 года переносить в архив
problems-log-archive-2025.md
```

Keep problems-log.md < 500 entries for fast reading

---

## Summary

**Problems Log = Institutional Memory**

- ✅ Learn from mistakes
- ✅ Don't repeat errors
- ✅ Share knowledge across projects
- ✅ Faster problem resolution
- ✅ Better architectural decisions

**Document everything, reference often.**
