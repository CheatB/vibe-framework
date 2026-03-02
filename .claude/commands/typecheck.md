# Команда: Проверка типов TypeScript

## Что делает
Проверяет типы TypeScript без компиляции

## Как использовать
Пользователь пишет: `/typecheck`

## Действия
1. Проверь наличие `tsconfig.json`
2. Запусти `tsc --noEmit`
3. Покажи ошибки типов, если есть
4. Предложи исправить автоматически простые ошибки

## Пример
```
Пользователь: /typecheck

Ты:
🔍 Проверяю типы TypeScript...

❌ Найдены 2 ошибки:
1. src/utils/api.ts:15 - Argument of type 'string' is not assignable to parameter of type 'number'
2. src/components/Form.tsx:42 - Property 'name' does not exist on type 'Props'

Хочешь посмотреть подробнее?
```
