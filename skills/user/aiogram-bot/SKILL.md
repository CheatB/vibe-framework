---
name: aiogram-bot
description: "Создание Telegram ботов на Aiogram v3 с использованием профессионального starter kit. Использовать когда нужно: (1) Создать нового Telegram бота с нуля, (2) Настроить проект бота с Docker/PostgreSQL/Redis, (3) Добавить админскую панель и рассылки, (4) Работать с миграциями БД, (5) Настроить Local Bot API для больших файлов (до 2GB)"
---

# Aiogram Bot Skill

Профессиональное создание Telegram ботов на Aiogram v3.20.0 с полной инфраструктурой.

## Быстрый старт

Для создания нового бота используй starter kit:

```bash
# Клонирование и настройка
git clone git@github.com:aislam23/aiogram_starter_kit.git <название_бота>
cd <название_бота>
make init-project  # Интерактивная настройка
make dev-d         # Запуск бота
```

## Архитектура проекта

### Структура каталогов
```
app/
├── handlers/          # Обработчики команд
│   ├── admin/        # Админские хендлеры (/admin, рассылки)
│   ├── start.py      # Команда /start
│   └── help.py       # Команды /help, /status
├── middlewares/      # Промежуточное ПО
│   ├── logging.py    # Логирование запросов
│   └── user.py       # Автосохранение пользователей
├── database/         # Работа с БД
│   ├── models.py     # SQLAlchemy модели
│   ├── database.py   # Класс для работы с БД
│   └── migrations/   # Система миграций
├── keyboards/        # Клавиатуры (admin.py)
├── services/         # Сервисы (broadcast.py)
├── states/           # FSM состояния (admin.py)
├── main.py          # Точка входа бота
└── config.py        # Конфигурация (Pydantic Settings)
```

Для подробного изучения структуры и примеров кода смотри [references/starter_kit_guide.md](references/starter_kit_guide.md)

## Создание хендлеров (Aiogram v3)

### Базовый паттерн
```python
from aiogram import Router
from aiogram.filters import CommandStart
from aiogram.types import Message

router = Router()

@router.message(CommandStart())
async def start_command(message: Message):
    await message.answer("Привет!")
```

### Регистрация роутера
Добавь в `app/handlers/__init__.py`:
```python
from .new_handler import router as new_router

def setup_routers(dp: Dispatcher):
    dp.include_router(start_router)
    dp.include_router(new_router)
```

### Inline-кнопки
```python
from aiogram import Router
from aiogram.types import Message, CallbackQuery, InlineKeyboardMarkup, InlineKeyboardButton

router = Router()

def получить_меню() -> InlineKeyboardMarkup:
    """Главное меню с inline-кнопками."""
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="📊 Профиль", callback_data="profile"),
         InlineKeyboardButton(text="⚙️ Настройки", callback_data="settings")],
        [InlineKeyboardButton(text="❓ Помощь", callback_data="help")]
    ])

@router.message(CommandStart())
async def cmd_start(message: Message):
    await message.answer("Выбери действие:", reply_markup=получить_меню())

@router.callback_query(lambda c: c.data == "profile")
async def показать_профиль(callback: CallbackQuery):
    await callback.message.edit_text(
        f"👤 Твой ID: {callback.from_user.id}",
        reply_markup=InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="◀️ Назад", callback_data="back_to_menu")]
        ])
    )
    await callback.answer()  # Убираем "часики"

@router.callback_query(lambda c: c.data == "back_to_menu")
async def назад_в_меню(callback: CallbackQuery):
    await callback.message.edit_text("Выбери действие:", reply_markup=получить_меню())
    await callback.answer()
```

### FSM (Finite State Machine)
```python
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup

class ОпросФорма(StatesGroup):
    имя = State()
    возраст = State()

@router.message(Command("опрос"))
async def начать_опрос(message: Message, state: FSMContext):
    await state.set_state(ОпросФорма.имя)
    await message.answer("Как тебя зовут?")

@router.message(ОпросФорма.имя)
async def получить_имя(message: Message, state: FSMContext):
    await state.update_data(имя=message.text)
    await state.set_state(ОпросФорма.возраст)
    await message.answer("Сколько тебе лет?")

@router.message(ОпросФорма.возраст)
async def получить_возраст(message: Message, state: FSMContext):
    данные = await state.get_data()
    await message.answer(f"Привет, {данные['имя']}! Тебе {message.text} лет.")
    await state.clear()
```

## Работа с базой данных

### Создание миграции
```bash
make create-migration NAME=add_user_phone DESC="Добавить телефон пользователя"
```

Подробнее о миграциях: [references/migrations_guide.md](references/migrations_guide.md)

## Админская панель

### Проверка прав админа
```python
from app.config import settings

if settings.is_admin(user_id):
    # Админский функционал
```

### Настройка админов
В `.env`:
```bash
ADMIN_USER_IDS=[123456789, 987654321]
```

## Полезные команды

### Разработка
```bash
make dev           # Запуск с логами
make dev-d         # Запуск в фоне
make restart-bot   # Перезапуск бота
make logs-bot      # Просмотр логов
```

### База данных
```bash
make db-shell      # PostgreSQL консоль
make db-migrate    # Применить миграции
```

## Язык кодовой базы

**Весь код пишется на русском языке:**
- Комментарии
- Docstrings
- Сообщения пользователю
- Названия переменных (где уместно)

Английский используется только для технических терминов.

## Версии зависимостей (ВАЖНО)

```
aiogram==3.20.0
pydantic-settings>=2.0
sqlalchemy>=2.0
alembic>=1.12
aiohttp>=3.9
redis>=5.0
```

При создании `requirements.txt` или `pyproject.toml` — **всегда указывай aiogram==3.20.0** явно. Starter kit уже содержит правильные версии в `docker-compose.yml`.

## Приоритет при конфликтах

Если пользователь просит что-то, что противоречит этому скиллу:

- **Другой фреймворк (python-telegram-bot, Telethon)** → объясни, что скилл заточен под Aiogram v3, но помоги если настаивает
- **Без Docker** → покажи вариант запуска через `python app/main.py`, но рекомендуй Docker
- **Без PostgreSQL (SQLite)** → допустимо для MVP, покажи как изменить DATABASE_URL
- **Старая версия Aiogram (v2)** → мягко объясни различия, пиши на v3

**Главное правило:** всегда выдавай рабочий код. Лучше код с комментариями "TODO" чем абстрактное объяснение без кода.
