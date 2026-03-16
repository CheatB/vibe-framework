# Vibe Framework v5.1

> Мозг + Руки + Совесть — полная методология вайбкодинга с AI-агентом

Фреймворк для тех, кто создаёт приложения с помощью AI (Claude Code, Cursor, Windsurf и др.), не будучи профессиональным программистом. От хаотичного промптинга — к системной разработке с enforcement.

[Читать на Project2ibe](https://project-2.ru/framework/vibe-framework)

## Философия

| | Мозг (Фреймворк) | Руки (Инструменты) | Совесть (Enforcement) |
|---|---|---|---|
| **Где живёт** | `CLAUDE.md`, `rules/`, маркеры | hooks, agents, plugins, skills | Vibe Runner, quality gates, pre-commit |
| **Что делает** | Описывает ЧТО и КОГДА | Выполняют работу | Следит, что правила РЕАЛЬНО выполняются |

## Что внутри

```
vibe-framework/
├── vibe-framework-v5.1.md  # Полное руководство (2400+ строк)
├── CLAUDE.md               # Точка входа для AI-агента
├── rules/                  # 11 правил (+ rules/design.md)
├── commands/               # 18 slash-команд
├── hooks/                  # 14 Git-хуков (+ check-design-tokens.sh)
├── skills/user/            # 19 скиллов (+ design-spec, design-tokens, ui-kit)
└── sync.sh                 # Синхронизация
```

## Что нового в v5.1

- **Phase 2.5 — Design System** — новая фаза между Tech Spec и декомпозицией
- **design-spec** — AI задаёт 12 вопросов и создаёт `docs/design-spec.md` автоматически
- **design-tokens** — генерирует `tokens.css`, `tokens.json` (W3C), `global.css` из spec
- **ui-kit** — Component Map: 21st.dev → shadcn/ui → UIverse → с нуля
- **check-design-tokens.sh** — хук блокирует хардкодные цвета/пиксели при записи файлов
- **rules/design.md** — правило: никаких `#hex` и `rgb()` вне `var(--token)`

## Что нового в v5.0

- **Vibe Shift** — эволюция от промпт-инжиниринга к enforcement
- **Vibe Runner** — плагин-надзиратель, блокирует коммиты при нарушении правил
- **Совесть** — третий столп: не только «что» и «как», но и «кто проверит»
- **Детерминистические guardrails** — линтеры, тесты, pre-commit как минимум

## Быстрый старт

```bash
# Клонируй
git clone https://github.com/CheatB/vibe-framework.git

# Скопируй конфиг глобально или используй sync.sh
cd vibe-framework && ./sync.sh
```

## 7 фаз проекта

| Фаза | Что происходит |
|---|---|
| **0. Инфраструктура** | Сервер, Git, SSH, CI/CD, шаблоны |
| **1. User Spec** | Глубинное интервью → спецификация |
| **1.8 Бизнес-анализ** | Legal, монетизация, GTM, аналитика |
| **2. Tech Spec** | Архитектура и стек |
| **2.5 Design System** | Дизайн-спек → токены → компонентная карта |
| **3. Декомпозиция** | Эпики → фичи → задачи |
| **4. Реализация** | Последовательный или командный режим |
| **5. Тестирование** | 12 типов тестов |
| **6. Финализация** | Чеклист, деплой, документация |

## 4 уровня работы

- **Проект** — от нуля до продакшена (фазы 0-6)
- **Эпик** — крупная функциональность (wave-параллелизм)
- **Фича** — одна возможность (brainstorm → build → test → commit)
- **Фикс** — быстрое исправление (определи → исправь → проверь → коммит)

## Совместимость

Заточен под **Claude Code**, но принципы применимы к любому AI-ассистенту. Файлы rules/, commands/, skills/ легко адаптировать под Cursor, Windsurf, Copilot.

## Автор

@CheatB — вайбкодер, менеджер в IT

- Telegram: [Не просто Чел](https://t.me/cheatb_channel)
- Project2ibe: [project-2.ru](https://project-2.ru)

## Лицензия

MIT
