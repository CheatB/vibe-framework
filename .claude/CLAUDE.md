# Claude Desktop — Vibe Framework v4.1

## Язык
- Весь код, комментарии, docstrings, переменные — на русском
- Общение с пользователем — на русском

## Безопасность (КРИТИЧНО)
- НИКОГДА не хардкодить секреты, токены, пароли
- НИКОГДА не коммитить .env файлы
- ВСЕГДА валидировать пользовательский ввод
- ВСЕГДА использовать prepared statements для SQL
- Подробнее → rules/security.md

## Структура

```
~/.claude/
├── CLAUDE.md                 # ← Ты здесь (точка входа, минимум)
├── rules/                    # Постоянные правила (загружаются всегда)
│   ├── quality-gates.md     # Gate 1 (план) → Gate 2 (код) → Gate 3 (деплой)
│   ├── anti-mirage.md       # Проверка на несуществующие файлы/функции/API
│   ├── coding-standards.md  # DRY, KISS, YAGNI, TDD, размеры файлов
│   ├── automation.md        # Auto-fix pipeline (4 уровня), pre/post hooks
│   ├── security.md          # Секреты, валидация, CORS, rate limiting
│   ├── workflow-markers.md  # Визуальные маркеры этапов
│   └── skill-quality-gate.md # Проверка качества скиллов
├── commands/                 # Slash-команды
│   ├── new-project.md       # /new-project — полный pipeline создания проекта
│   ├── end.md               # /end — завершение рабочей сессии
│   ├── done.md              # /done — завершение фичи (+ обновление Project Knowledge)
│   ├── business-analysis.md # /business-analysis — standalone бизнес-анализ
│   ├── code-review.md       # /code-review
│   ├── tdd.md               # /tdd
│   └── ...
└── skills/user/              # Кастомные скиллы
    ├── aiogram-bot/          # Telegram боты на Aiogram v3
    ├── telegram-post-style/  # Посты для канала "Не просто Чел"
    ├── legal-compliance/     # Юридическая проверка (ПД, оферта, 152-ФЗ)
    ├── monetization/         # Модель монетизации
    ├── gtm/                  # Go-to-Market стратегия
    ├── analytics-setup/      # Метрики и аналитика (AARRR)
    └── accessibility/        # Доступность веб-интерфейсов (a11y)
```

## Ключевые правила (подробности в rules/)

1. **Quality Gates** — автоматическая проверка на 3 этапах. Ревью МОЛЧА, показываем пользователю финал. → rules/quality-gates.md
2. **Anti-Mirage** — проверка что все импорты, функции, env vars, зависимости реально существуют. → rules/anti-mirage.md
3. **TDD** — сначала тест, потом код. Минимум 80% покрытия. → rules/coding-standards.md
4. **Auto-Fix** — 4 уровня автоисправления (commit → push → CI → deploy). Макс 3 попытки. → rules/automation.md
5. **Workflow маркеры** — визуальные маркеры этапов (РЕЖИМ → ФАЗА → ЧЕКПОИНТ → ГОТОВО). → rules/workflow-markers.md
6. **Бизнес-анализ** — 5 блоков в Фазе 1.8: Legal, Monetization, GTM, Analytics, Accessibility. → commands/business-analysis.md

## Ключевые команды

- **/new-project** — от идеи до рабочего продукта. Определение размера S/M/L → brainstorming → бизнес-анализ (Фаза 1.8) → user-spec → tech-spec → tasks → код → деплой.
- **/business-analysis** — standalone бизнес-анализ (5 блоков: Legal, Monetization, GTM, Analytics, Accessibility).
- **/end** — конец рабочей сессии. AI_NOTES + session log + tasks.md + git commit/push.
- **/done** — фича завершена. Всё из /end + обновление Project Knowledge + архивация артефактов.

## Размеры задач

**S (Quick Fix):** 1-3 файла, <30 мин. Без brainstorming/specs. Anti-mirage only.
**M (Feature):** несколько компонентов, 1-4 часа. Полный pipeline с адаптивной валидацией.
**L (Epic):** новая архитектура, дни. Полный pipeline + consistency check + security review.

## Документация проекта (создаётся через /new-project)

```
docs/
├── project-knowledge/        # "Живые" документы (обновляются через /done)
│   ├── project.md            # Что за проект, аудитория, scope
│   ├── architecture.md       # Актуальный стек, структура, модель данных
│   ├── patterns.md           # Конвенции кода, git workflow
│   └── deployment.md         # Как деплоить, env vars, мониторинг
├── context.md                # Исходный контекст (замораживается)
├── brainstorm.md             # Результат мозгового штурма (замораживается)
├── user-spec.md              # Понятийное ТЗ (замораживается)
├── tech-spec.md              # Техническое ТЗ (замораживается)
├── tasks.md                  # Задачи с волнами и зависимостями
├── DECISIONS.md              # ADR — стратегические решения
├── ai-notes/                 # Тактические заметки по блокам
└── sessions/                 # Логи рабочих сессий
```

## Git workflow

Формат коммитов: `<тип>: <описание>`
Типы: feat, fix, refactor, docs, test, chore, session
Коммиты на русском.

## Приоритеты

1. Безопасность
2. Корректность (тесты)
3. Читаемость
4. Производительность
