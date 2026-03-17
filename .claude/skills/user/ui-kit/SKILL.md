---
name: ui-kit
description: Фаза 2.5 Шаг C. Создаёт Component Map L1-L4 и план задач по реализации компонентов на основе docs/design-spec.md.
---

# UI Kit — Шаг C Фазы 2.5

## Когда активировать
После design-tokens (Шаг B). Нужен docs/design-spec.md.

## Workflow

### Шаг 1: Component Map по типу продукта

Базовый набор:
- L1 Atoms: Button, Input, Textarea, Select, Checkbox,
  Radio, Switch, Badge, Tag, Avatar, Icon, Spinner,
  Tooltip, Divider
- L2 Molecules: Card, FormField, SearchBar, Dropdown,
  Tabs, Modal, Drawer, Alert, Toast, Pagination
- L3 Organisms: Navbar, Sidebar, Header, Footer,
  DataTable, Form, AuthForm, UserMenu
- L4 Templates: DashboardLayout, AuthLayout, SettingsLayout

Адаптация под product_type из design-spec:
- SaaS dashboard → DataTable, Charts, FilterPanel обязательны
- Landing page → Hero, Features, Pricing, CTA, Footer
- E-commerce → ProductCard, Cart, Checkout, OrderHistory
- Bot webapp → TelegramCard, InlineKeyboard, FileUploader
- Auth → LoginForm, RegisterForm, ForgotPassword

### Шаг 2: Определить источник каждого компонента

Приоритет:
1. 21st.dev (если MCP /ui доступен)
2. shadcn/ui (если ui-lib=shadcn в design-spec)
3. UIverse.io (для декоративных/анимированных)
4. Radix UI Primitives (для accessible базовых)
5. С нуля (только если нет готового)

Для каждого компонента: источник + variant + size + theme

### Шаг 3: Создать docs/ui-kit.md

# UI Kit — [Название]

## L1 — Atoms
| Компонент | Источник    | Варианты                    |
|-----------|-------------|-----------------------------|
| Button    | shadcn/ui   | default/outline/ghost, sm/md/lg |
| Input     | shadcn/ui   | default, error, disabled    |
| Badge     | shadcn/ui   | default/success/warning/error |
| Avatar    | shadcn/ui   | sm/md/lg, fallback text     |
| Spinner   | shadcn/ui   | sm/md/lg                    |

## L2 — Molecules
| Компонент | Источник    | Варианты                    |
|-----------|-------------|-----------------------------|
| Card      | shadcn/ui   | default, hover, selected    |
| Modal     | shadcn/ui   | sm/md/lg, с footer          |
| Toast     | shadcn/ui   | success/error/warning/info  |
| Tabs      | shadcn/ui   | line/pill                   |

## L3 — Organisms
| Компонент  | Источник  | Примечание                |
|------------|-----------|---------------------------|
| Navbar     | с нуля    | logo + nav + UserMenu     |
| Sidebar    | shadcn/ui | коллапсируемый            |
| DataTable  | shadcn/ui | sort, filter, pagination  |
| AuthForm   | с нуля    | login/register            |

## L4 — Templates
| Шаблон          | Состав                          |
|-----------------|---------------------------------|
| DashboardLayout | Sidebar + Header + main         |
| AuthLayout      | centered card, no nav           |
| SettingsLayout  | Sidebar + sections              |
| LandingLayout   | Header + sections + Footer      |

### Шаг 4: Создать docs/design-tasks.md

Задачи для добавления в tasks.md проекта (Волна 1):

## UI компоненты
### L1: Atoms
- [ ] Button — shadcn/ui: default/outline/ghost, sm/md/lg
- [ ] Input — shadcn/ui: default + error + disabled states
- [ ] Badge — shadcn/ui: default/success/warning/error
### L2: Molecules
- [ ] Card — shadcn/ui: default + hover
- [ ] Modal — shadcn/ui: sm/md/lg + footer
- [ ] Toast — shadcn/ui: success/error/warning/info
### L3: Organisms
- [ ] Navbar — с нуля: logo + nav links + UserMenu
- [ ] DataTable — shadcn/ui: sort + filter + pagination
### L4: Templates
- [ ] DashboardLayout — Sidebar + Header + main content
- [ ] AuthLayout — centered card без nav

## Пример

Ввод: product_type="SaaS dashboard", ui-lib="shadcn/ui"

docs/ui-kit.md содержит:
  L1: Button, Input, Select, Badge, Avatar, Spinner, Tooltip
  L2: Card, FormField, Tabs, Modal, Toast, Pagination
  L3: Navbar, Sidebar, DataTable, UserMenu, FiltersPanel
  L4: DashboardLayout, SettingsLayout

docs/design-tasks.md содержит ~20 задач с источниками.

## Приоритет при конфликтах

1. ui-lib из design-spec → определяет базовый источник
2. Если 21st.dev MCP доступен → пробовать /ui сначала
3. shadcn/ui → если ui-lib=shadcn или Next.js стек
4. Кастомные компоненты → только если нет готового
5. Plain HTML проект → UIverse + CSS custom properties
6. Без design-spec.md → запросить product_type и ui-lib
