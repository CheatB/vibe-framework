# Docker & Deploy Skill

Этот скилл активируется автоматически когда Claude работает с Docker, деплоем, инфраструктурой.

## Когда использовать
- Работа с docker-compose.yml / Dockerfile
- Деплой на VPS
- Настройка CI/CD
- Работа с nginx, traefik, caddy

## Правила Docker

### docker-compose.yml
- ВСЕГДА указывай `restart: unless-stopped` для продакшн-сервисов
- ВСЕГДА указывай `healthcheck` для каждого сервиса
- Используй `.env` для переменных, НИКОГДА не хардкодь секреты
- Указывай конкретные версии образов (не `latest`)
- Используй `depends_on` с `condition: service_healthy`

### Dockerfile
- Используй multi-stage builds для уменьшения размера
- Запускай от непривилегированного пользователя (`USER app`)
- Кэшируй зависимости (COPY requirements.txt перед COPY .)
- Указывай `.dockerignore`

### Деплой
- Перед деплоем ВСЕГДА проверь `git status` — нет ли незакоммиченных изменений
- После `docker compose up -d` — подожди 10 сек и проверь логи
- Если контейнер рестартует — проверь `docker compose logs <service> --tail 50`
- Health-check: `curl -sf http://localhost:<port>/health`

### Откат
При неудачном деплое:
```bash
# Откат к предыдущей версии
git log --oneline -5  # найди хороший коммит
git revert HEAD
git push
docker compose up -d
```

### Мониторинг
- `docker stats` — ресурсы контейнеров
- `docker compose logs -f` — логи в реальном времени
- `docker system df` — использование диска Docker

## Шаблон docker-compose.yml для Python бота
```yaml
version: '3.8'
services:
  bot:
    build: .
    restart: unless-stopped
    env_file: .env
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "python", "-c", "import requests; requests.get('http://localhost:8080/health')"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```
