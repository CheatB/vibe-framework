# Команда: Тесты

## Что делает
Запускает тесты с правильными параметрами

## Как использовать
- `/test` — запустить все тесты
- `/test <путь>` — запустить конкретные тесты
- `/test-watch` — watch mode
- `/test-coverage` — с покрытием

## Действия

### Определить тестовый фреймворк
1. Проверь `package.json` на наличие:
   - Jest
   - Vitest
   - Pytest
   - Cargo test

### Запустить тесты
- JavaScript/TypeScript: `npm test` или `pnpm test`
- Python: `pytest`
- Rust: `cargo test`

### Показать результаты
```
Пользователь: /test

Ты:
🧪 Запускаю тесты...

✅ 45 passed
❌ 2 failed
⏭️  5 skipped

Failed tests:
1. src/utils/api.test.ts - should handle errors
2. src/components/Form.test.tsx - should validate input

Хочешь посмотреть детали ошибок?
```

### Coverage
Если `/test-coverage`:
- Запусти с флагом coverage
- Покажи процент покрытия
- Покажи некрытые файлы
