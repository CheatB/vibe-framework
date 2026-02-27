# Aiogram Starter Kit - Подробное руководство

## Точка входа (app/main.py)

```python
# Создание Bot + Dispatcher
bot = Bot(token=settings.bot_token)
dp = Dispatcher(storage=FSMContext(RedisStorage(...)))

# Регистрация middlewares
setup_middlewares(dp)

# Регистрация роутеров
setup_routers(dp)

# При старте: миграции БД
await db.create_tables()  # Автоматически применяет миграции

# Запуск polling
await dp.start_polling(bot)
```

## FSM состояния

### Определение состояний
```python
# app/states/admin.py
from aiogram.fsm.state import State, StatesGroup

class BroadcastState(StatesGroup):
    waiting_content = State()
    waiting_button = State()
    waiting_confirm = State()
```

### Использование
```python
from app.states.admin import BroadcastState

@router.message(F.text == "📤 Рассылка")
async def start_broadcast(message: Message, state: FSMContext):
    await state.set_state(BroadcastState.waiting_content)
    await message.answer("Отправьте контент для рассылки")

@router.message(BroadcastState.waiting_content)
async def receive_content(message: Message, state: FSMContext):
    await state.update_data(content=message)
    await state.set_state(BroadcastState.waiting_button)
```

## Middlewares

### Регистрация
В `app/middlewares/__init__.py`:
```python
def setup_middlewares(dp: Dispatcher):
    # По типу события
    dp.message.middleware(LoggingMiddleware())
    dp.callback_query.middleware(LoggingMiddleware())
    dp.message.middleware(UserMiddleware())
```

### Создание middleware
```python
from aiogram import BaseMiddleware

class MyMiddleware(BaseMiddleware):
    async def __call__(self, handler, event, data):
        # До хендлера
        result = await handler(event, data)
        # После хендлера
        return result
```

## Система рассылок

Готовый функционал в `app/services/broadcast.py`:
- Поддержка всех типов сообщений
- Inline кнопки с ссылками
- Прогресс-бар рассылки
- Статистика доставки

## Local Bot API (файлы до 2GB)

### Настройка
1. Получи credentials на https://my.telegram.org
2. Добавь в `.env`:
```bash
USE_LOCAL_API=true
TELEGRAM_API_ID=12345678
TELEGRAM_API_HASH=abcdef1234567890
```

3. Запусти:
```bash
make dev-local      # Запуск с Local API
make api-status     # Проверка статуса
```

### Конфигурация в коде
```python
# app/config.py
use_local_api: bool = False
local_api_url: str = "http://telegram-bot-api:8081"
file_upload_limit_mb: int = 2000 if use_local_api else 50
```

## Конфигурация (.env)

### Обязательные параметры
```bash
BOT_TOKEN=your_bot_token_here
BOT_USERNAME=your_bot_username
ADMIN_USER_IDS=[123456789]
```

### База данных
```bash
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=botdb
POSTGRES_USER=botuser
POSTGRES_PASSWORD=securepassword
```

### Redis
```bash
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0
```
