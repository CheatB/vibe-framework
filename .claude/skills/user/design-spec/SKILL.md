---
name: design-spec
description: Фаза 2.5 Шаг A. Запускает ui-ux-pro-max для DB-рекомендаций, задаёт 4-5 уточняющих вопросов, создаёт docs/design-spec.md.
---

# Design Spec — Шаг A Фазы 2.5

## Когда активировать

Автоматически в Фазе 2.5, если tech_stack содержит:
react, vue, next, nuxt, svelte, html, frontend, web, landing, dashboard, webapp, mini-app.

## Workflow

### Шаг 1: Извлечь контекст из Tech Spec

Из docs/tech-spec.md определить:
- product_type — тип (SaaS, e-commerce, dashboard, landing, bot-webapp)
- stack — технологический стек (nextjs, react, shadcn, html-tailwind...)
- audience — целевая аудитория
- style_hints — стилевые предпочтения если упомянуты

### Шаг 2: Запустить ui-ux-pro-max
Путь: ~/.claude/skills/user/ui-ux-pro-max/scripts/
5 поисков (PROD=product_type из шага 1):
  search.py "$PROD" --domain product
  search.py "$PROD" --domain style
  search.py "$PROD" --domain color
  search.py "$PROD" --domain typography
  design_system.py "$PROD $STACK" --design-system -f markdown
Топ-3 из каждого домена.
Если скилл не установлен — пропустить, перейти к шагу 3.

### Шаг 3: Задать 4-5 уточняющих вопросов
На основе результатов:
1. Стиль: "[вариант A] или [вариант B]?" — из --domain style
2. Цвета: "[палитра 1] или [палитра 2]?" — из --domain color
3. Типографика: "[пара шрифтов] — ок?" — из --domain typography
4. UI-kit: shadcn/ui / Radix / свои компоненты?
5. Анимации: нет / subtle / expressive?
Пропустить вопрос если ответ очевиден из tech-spec.

### Шаг 4: Создать docs/design-spec.md
Заполнить ответами пользователя + рекомендациями ui-ux-pro-max.

## Шаблон docs/design-spec.md

# Design Spec — [Название]

## Идентичность
- Продукт: [тип из ui-ux-pro-max]
- Аудитория: [из tech-spec]
- Tone: professional / friendly / bold / calm
- Ценности: [3-5 слов]

## Стиль
- Направление: [из --domain style]
- Референсы: [ссылки или описание]
- Избегать: [антипримеры]

## Цвета
- Primary: #XXXXXX
- Secondary: #XXXXXX
- Accent: #XXXXXX
- Background: #FFFFFF / #0A0A0A
- Surface: #F8F8F8 / #1A1A1A
- Error: #EF4444 | Success: #22C55E | Warning: #F59E0B
- Text: #111111 / #888888 (muted)

## Типографика
- Heading: [шрифт, вес]
- Body: [шрифт, вес]
- Mono: [шрифт] (для кода)
- Scale (px): 12/14/16/18/20/24/30/36/48

## Spacing & Layout
- Единица: 4px
- Breakpoints: 640/768/1024/1280/1536
- Container max-w: [N]px / full

## Компоненты
- UI-lib: [shadcn/ui / Radix / custom]
- Иконки: [Lucide / Heroicons / Phosphor]
- Анимации: [framer-motion / tailwind / нет]
- Border-radius: none / sm(4px) / md(8px) / lg / full

## Пример

Ввод (из tech-spec): product_type="SaaS dashboard", stack="nextjs shadcn"

Команды:
  search.py "SaaS dashboard" --domain style
  → "Clean Minimalist" / "Data-Forward" / "Enterprise Modern"
  search.py "SaaS dashboard" --domain color
  → "Neutral Pro" / "Blue Enterprise" / "Dark Mode First"

Вопрос пользователю:
"ui-ux-pro-max предлагает 3 стиля для SaaS dashboard:
1. Clean Minimalist — светлый, строгая типографика
2. Data-Forward — акцент на графиках, плотная вёрстка
3. Enterprise Modern — корпоративный, нейтральные цвета
Что ближе?"

Вывод: docs/design-spec.md с заполненными секциями.

## Приоритет при конфликтах

1. Пользователь указал стиль в tech-spec → приоритет над ui-ux-pro-max
2. ui-ux-pro-max рекомендует → предлагать как вариант, не навязывать
3. Ничего не указано → взять топ-1 и уточнить у пользователя
4. ui-ux-pro-max не установлен → задать те же вопросы вручную
5. Конфликт цветов/типографики → приоритет у явного выбора пользователя
