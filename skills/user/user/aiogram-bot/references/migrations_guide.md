# Руководство по миграциям БД

## Создание миграции

```bash
make create-migration NAME=add_user_phone DESC="Добавить телефон пользователя"
```

Создаст файл в `app/database/migrations/versions/YYYYMMDD_HHMMSS_add_user_phone.py`:

```python
from app.database.migrations import Migration
from sqlalchemy import text

class AddUserPhoneMigration(Migration):
    def get_version(self) -> str:
        return "20260131_120000"
    
    def check_can_apply(self, session) -> bool:
        # Проверка: столбец не существует
        result = session.execute(text(
            "SELECT column_name FROM information_schema.columns "
            "WHERE table_name='users' AND column_name='phone'"
        ))
        return result.fetchone() is None
    
    def upgrade(self, session):
        session.execute(text(
            "ALTER TABLE users ADD COLUMN phone VARCHAR(20)"
        ))
    
    def downgrade(self, session):
        session.execute(text(
            "ALTER TABLE users DROP COLUMN phone"
        ))
```

## Автоматические миграции

Миграции применяются автоматически при запуске бота через `db.create_tables()`.

Для ручного запуска:
```bash
make db-migrate
make db-migration-status  # Проверить статус
```

## Структура миграций

```
app/database/migrations/
├── __init__.py              # Экспорт основных классов
├── base.py                  # Базовый класс Migration
├── manager.py               # MigrationManager
└── versions/                # Файлы миграций
    ├── __init__.py
    ├── 20241201_000001_initial_tables.py
    └── 20241201_000002_add_user_columns_example.py
```

## Методы класса Migration

### get_version()
Возвращает уникальную версию миграции в формате `YYYYMMDD_HHMMSS`.

### check_can_apply(session)
Проверяет, нужно ли применять миграцию. Возвращает `True`, если миграция должна быть применена.

Типичные проверки:
- Существование столбца
- Существование таблицы
- Наличие индекса

### upgrade(session)
Применяет миграцию. Здесь выполняются SQL команды для изменения схемы БД.

### downgrade(session)
Откатывает миграцию (опционально). Выполняет обратные изменения.

## Примеры миграций

### Добавление столбца
```python
def upgrade(self, session):
    session.execute(text(
        "ALTER TABLE users ADD COLUMN last_seen TIMESTAMP"
    ))
```

### Создание индекса
```python
def upgrade(self, session):
    session.execute(text(
        "CREATE INDEX idx_users_username ON users(username)"
    ))
```

### Создание новой таблицы
```python
def upgrade(self, session):
    session.execute(text("""
        CREATE TABLE messages (
            id SERIAL PRIMARY KEY,
            user_id BIGINT NOT NULL,
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(user_id)
        )
    """))
```

## Автоматические таблицы

При запуске бота автоматически создаются таблицы:
* **users** - пользователи бота
* **bot_stats** - статистика бота
* **migration_history** - история примененных миграций
