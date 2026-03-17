---
name: design-tokens
description: Фаза 2.5 Шаг B. Берёт docs/design-spec.md и генерирует tokens.css (CSS Custom Properties), tokens.json (W3C Design Tokens), global.css (reset + шрифты).
---

# Design Tokens — Шаг B Фазы 2.5

## Когда активировать
После design-spec (Шаг A). Нужен файл docs/design-spec.md.
Если его нет — запустить design-spec или запросить данные вручную.

## Workflow

### Шаг 1: Читать docs/design-spec.md
Извлечь:
- colors: primary, secondary, accent, bg, surface, text, error/success/warning
- typography: heading/body/mono font, scale px
- spacing: base=4px, breakpoints
- border-radius, animation preference
- ui-lib (shadcn/ui требует HSL, остальные — hex)

### Шаг 2: Создать src/styles/tokens.css

Три слоя в одном файле:

:root {
  /* === PRIMITIVE (сырые значения) === */
  --color-blue-50: #EFF6FF;
  --color-blue-500: #3B82F6;
  --color-blue-900: #1E3A8A;
  /* ...scales 50-900 для каждого цвета... */
  --space-1: 4px; --space-2: 8px; --space-4: 16px;
  --space-6: 24px; --space-8: 32px; --space-16: 64px;
  --radius-sm: 4px; --radius-md: 8px; --radius-lg: 12px;
  --duration-fast: 150ms; --duration-normal: 300ms;

  /* === SEMANTIC (смысловые алиасы) === */
  --color-primary: var(--color-blue-500);
  --color-background: #FFFFFF;
  --color-surface: #F8F8F8;
  --color-text: #111111;
  --color-text-muted: #888888;
  --color-error: #EF4444;
  --color-success: #22C55E;
  --color-warning: #F59E0B;
}

  /* === TYPOGRAPHY === */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --text-xs: 12px; --text-sm: 14px; --text-base: 16px;
  --text-lg: 18px; --text-xl: 20px; --text-2xl: 24px;
  --text-3xl: 30px; --text-4xl: 36px; --text-5xl: 48px;

/* === DARK MODE === */
[data-theme="dark"] {
  --color-background: #0A0A0A;
  --color-surface: #1A1A1A;
  --color-text: #F0F0F0;
  --color-text-muted: #888888;
  --color-primary: var(--color-blue-400);
}

/* === MOTION === */
@media (prefers-reduced-motion: reduce) {
  --duration-fast: 0ms;
  --duration-normal: 0ms;
}

/* Если shadcn/ui — использовать HSL вместо hex: */
/* --primary: 217 91% 60%; */
/* --background: 0 0% 100%; */

### Шаг 3: Создать src/styles/tokens.json (W3C Design Tokens)

Формат для Figma Tokens Studio и Style Dictionary:
{
  "color": {
    "primary":    { "$value": "#3B82F6", "$type": "color" },
    "background": { "$value": "#FFFFFF", "$type": "color" },
    "text":       { "$value": "#111111", "$type": "color" }
  },
  "typography": {
    "heading": { "$value": { "fontFamily": "Inter", "fontWeight": 700 }, "$type": "typography" },
    "body":    { "$value": { "fontFamily": "Inter", "fontWeight": 400 }, "$type": "typography" }
  },
  "spacing": {
    "4": { "$value": "16px", "$type": "dimension" }
  }
}

### Шаг 4: Создать src/styles/global.css

/* Импорт шрифтов */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

/* Минимальный reset */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

/* Базовые стили */
body {
  font-family: var(--font-sans);
  background-color: var(--color-background);
  color: var(--color-text);
  font-size: var(--text-base);
  line-height: 1.6;
}

/* Скролл */
html { scroll-behavior: smooth; }
@media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } }

## Пример

Из docs/design-spec.md:
  Primary: #3B82F6 | Background: #FFFFFF | Text: #111111
  Heading: Inter 700 | Body: Inter 400 | Mono: JetBrains Mono
  Border-radius: md (8px) | Анимации: subtle

Генерирует 3 файла:
- src/styles/tokens.css  — ~250 строк CSS Custom Properties
- src/styles/tokens.json — ~50 строк W3C формат для Figma
- src/styles/global.css  — ~40 строк reset + базовые стили

## Приоритет при конфликтах

1. docs/design-spec.md → источник правды для всех значений
2. Если ui-lib = shadcn/ui → все цвета в HSL, совместимо с globals.css shadcn
3. Если Tailwind → дополнительно сгенерировать секцию extend в tailwind.config.js
4. Если design-spec.md нет → сначала запустить design-spec (Шаг A)
5. Тёмная тема — всегда генерировать, даже если не просили
