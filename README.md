# Vibe Framework v4.1

AI-assisted development framework для Claude Code. Правила, команды, скиллы — всё для того, чтобы AI-агент работал как полноценный партнёр в разработке.

## Что внутри

- **`vibe-framework-v4.md`** — полное описание методологии (Phases 0→6, Quality Gates, Auto-Fix Pipeline, Anti-Mirage)
- **`.claude/`** — рабочая конфигурация фреймворка:
  - `CLAUDE.md` — точка входа для AI-агента
  - `rules/` — 10 правил (качество, безопасность, тестирование, БД, документация)
  - `commands/` — 18 slash-команд (/new-project, /end, /done, /deploy, /tdd и др.)
  - `skills/user/` — 7 кастомных скиллов (aiogram-bot, telegram-post-style, legal-compliance, monetization, gtm, analytics-setup, accessibility)

## Как использовать

1. Скопировать `.claude/` в `~/.claude/` (глобальная конфигурация) или в корень проекта
2. Документ `vibe-framework-v4.md` — справочник по методологии

## Автор

<AUTHOR> (@CheatB) — [Не просто Чел](https://t.me/cheatb_channel)
