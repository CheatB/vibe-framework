# Frontend Design Skill

Этот скилл активируется автоматически при работе с фронтендом: HTML, CSS, React, Next.js, UI компоненты.

## Когда использовать
- Создание веб-интерфейсов
- Работа с CSS/Tailwind
- React/Next.js компоненты
- Landing pages
- Дашборды и админки

## Принципы дизайна

### Типографика
- Заголовки: контрастные, крупные (h1: 2.5rem, h2: 2rem, h3: 1.5rem)
- Тело: читаемый размер (1rem / 16px минимум), line-height: 1.6
- Не более 2-3 шрифтов на страницу
- Системные шрифты по умолчанию: `-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`

### Цвета
- Основная палитра: не более 5 цветов
- Контраст текста к фону: минимум 4.5:1 (WCAG AA)
- Используй CSS переменные для темизации:
```css
:root {
  --color-primary: #3B82F6;
  --color-secondary: #10B981;
  --color-danger: #EF4444;
  --color-bg: #FFFFFF;
  --color-text: #1F2937;
}
```

### Layout
- Mobile-first: начинай с мобильного, расширяй через media queries
- Flexbox для одномерных layouts
- CSS Grid для двумерных сеток
- Максимальная ширина контента: 1200px, с padding 1-2rem по бокам

### Компоненты
- Кнопки: минимум 44x44px touch target
- Формы: явные label, placeholder ≠ label, видимый focus state
- Карточки: мягкие тени (`box-shadow: 0 1px 3px rgba(0,0,0,0.1)`)
- Анимации: `transition: all 0.2s ease`, prefer-reduced-motion

### Tailwind CSS (если используется)
- Используй утилитарные классы
- Группируй: layout → spacing → typography → colors → effects
- Кастомизация через tailwind.config.js, не инлайн стили
- Responsive: sm: → md: → lg: → xl:

### Доступность (a11y)
- Семантические теги: nav, main, article, section, aside
- alt для всех изображений
- aria-label для интерактивных элементов без текста
- Keyboard navigation: tabindex, focus-visible

## Антипаттерны (НЕ ДЕЛАЙ)
- ❌ Не используй px для font-size (используй rem)
- ❌ Не делай text на фоне без достаточного контраста
- ❌ Не используй !important (почти никогда)
- ❌ Не делай горизонтальный скролл на мобильных
- ❌ Не используй абсолютные позиции для layout

## Agentation — UI-итерации через аннотации (React 18+)

Для React-проектов используй Agentation для UI-правок. Это React-компонент, который позволяет кликнуть на любой элемент UI, написать замечание, и передать агенту точный контекст (селектор, позиция, классы).

### Когда использовать:
- Визуальные правки UI (цвета, отступы, размеры, hover-эффекты)
- Отладка анимаций (заморозка CSS-анимаций для аннотирования)
- Batch-правки нескольких элементов за раз
- Проблемы с layout (можно аннотировать пустые области)

### Режимы детализации:
- **Compact** — селектор + заметка (для простых правок)
- **Standard** — + позиция, текст (90% задач)
- **Detailed** — + bounding box, соседние элементы
- **Forensic** — + computed styles, полный DOM-путь (для сложных CSS-проблем)

### Установка:

```bash
npm install agentation -D
```

В layout проекта (Next.js App Router — `app/layout.tsx`, Pages Router — `pages/_app.tsx`, или `src/App.tsx`):

```tsx
import { Agentation } from 'agentation';

// В конце JSX, перед закрывающим тегом:
{process.env.NODE_ENV === "development" && <Agentation />}
```

### Работа на VPS (код на VPS, браузер на маке):

1. VPS: `npm run dev` (порт 3000)
2. Мак: `ssh -L 3000:localhost:3000 claude@vps-ip`
3. Открыть `localhost:3000` в Chrome
4. Кликнуть иконку Agentation → режим аннотаций
5. Кликнуть на элемент, написать замечание, Copy
6. Вставить markdown в Claude Code на VPS
7. Агент находит элемент по селектору, правит, hot-reload

### MCP-версия (без copy-paste, опционально):

```bash
npm install agentation-mcp
npx agentation-mcp init
```

Добавить в `.claude/settings.json` проекта:
```json
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["agentation-mcp", "server"]
    }
  }
}
```

Прокинуть дополнительный порт WebSocket для MCP. Тогда агент видит аннотации в real-time без copy-paste.

### Важно:
- Agentation только формирует контекст, не генерирует код
- Добавлять только в dev-режиме (`process.env.NODE_ENV === "development"`)
- Только React 18+
- Для 90% задач хватает Standard режима, Forensic — для сложных CSS-проблем
