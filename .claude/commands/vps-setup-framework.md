# /vps-setup-framework — Установка Vibe Framework на VPS

**Цель:** После базовой настройки VPS (SSH, Docker, Nginx) раскатить весь Vibe Framework для полноценной работы через Claude Code.

**Триггер:** Пользователь говорит "установи фреймворк на VPS", "раскатай Claude Code на сервере", "/vps-setup-framework"

**Предусловия:**
- VPS уже настроен (SSH, Docker, Nginx) — через `/setup-vps` или вручную
- SSH-доступ работает (проверить через vps-MCP или `ssh claude@<host>`)

---

## Процесс

### Шаг 1: Проверка связи

```
Подключиться к VPS через MCP или SSH.
Проверить:
- [ ] SSH работает
- [ ] Node.js установлен (>= 18)
- [ ] npm доступен
- [ ] Python3 установлен
- [ ] Git установлен
```

Если чего-то нет — установить:
```bash
# Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

# Python и pip
sudo apt install -y python3 python3-pip python3-venv

# Git
sudo apt install -y git
```

### Шаг 2: Установка Claude Code CLI

```bash
sudo npm install -g @anthropic-ai/claude-code
```

Проверить: `claude --version`

### Шаг 3: Клонирование claude-config и синхронизация

```bash
# Клонируем репо фреймворка
git clone https://github.com/CheatB/claude-config.git ~/claude-config

# Синхронизируем в ~/.claude/
bash ~/claude-config/scripts/sync.sh pull
```

Это создаст всю структуру `~/.claude/` автоматически:
- `rules/` — правила (quality-gates, anti-mirage, security, и т.д.)
- `commands/` — slash-команды
- `skills/user/` — пользовательские скиллы
- `templates/hooks/` — шаблоны проектных хуков
- `scripts/` — утилиты (sync.sh, install-hooks.sh)
- `TEMPLATE.md` — шаблон проектного CLAUDE.md с секцией ПРОГРЕСС

### Шаг 4: Установка плагинов

```bash
claude plugin install code-simplifier
claude plugin install hookify
claude plugin install typescript-lsp
claude plugin install pyright-lsp
claude plugin install mgrep
claude plugin install context7
claude plugin install frontend-design
claude plugin install security-guidance
claude plugin install pr-review-toolkit
claude plugin install commit-commands
claude plugin install superpowers
claude plugin install nemp
```

### Шаг 5: Настройка MCP-серверов

```bash
claude mcp add --transport http sentry-mcp https://mcp.sentry.dev/mcp
claude mcp add database-mcp -- npx -y @bytebase/dbhub
claude mcp add docker-mcp -- npx -y @quantgeekdev/docker-mcp
claude mcp add telegram-mcp -- npx -y @s1lverain/claude-telegram-mcp
```

### Шаг 6: Установка инструментов для хуков

```bash
# Python линтер
pip3 install ruff black isort --break-system-packages

# Node.js инструменты
sudo npm install -g prettier typescript
```

### Шаг 7: Настройка permissions (settings.json)

Создать `~/.claude/settings.json` с разрешениями (скопировать с локальной машины или создать минимальный):

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "enabledPlugins": {
    "hookify@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true,
    "commit-commands@claude-plugins-official": true,
    "mgrep@Mixedbread-Grep": true,
    "superpowers@superpowers-marketplace": true,
    "frontend-design@claude-plugins-official": true,
    "security-guidance@claude-plugins-official": true,
    "pr-review-toolkit@claude-plugins-official": true,
    "context7@claude-plugins-official": true,
    "nemp@nemp-memory": true,
    "code-simplifier@claude-plugins-official": true
  }
}
```

### Шаг 8: Верификация

```bash
# Проверить CLI
claude --version

# Проверить плагины
claude plugin list

# Проверить MCP
claude mcp list

# Проверить структуру
ls ~/.claude/rules/ ~/.claude/commands/ ~/.claude/skills/user/ ~/.claude/templates/hooks/ ~/.claude/scripts/

# Тестовый запуск
claude "скажи привет и покажи список доступных правил из rules/"
```

---

## Установка хуков в проект

После создания проекта — установить проектные хуки:

```bash
bash ~/.claude/scripts/install-hooks.sh /путь/к/проекту
```

Это скопирует 5 хуков в `$PROJECT/.claude/hooks/` и обновит проектный `settings.json`:
- `session-start-progress.sh` — читает ПРОГРЕСС при старте/compaction
- `stop-check-progress.sh` — блокирует если >3 файла без обновления ПРОГРЕСС
- `stop-check-debug.sh` — блокирует если console.log/debugger/print()
- `post-edit-format.sh` — автоформат prettier/black/isort
- `track-changes.sh` — логирует изменённые файлы

---

## Обновление фреймворка

Для обновления на уже настроенном VPS:

```bash
cd ~/claude-config && git pull && bash scripts/sync.sh pull
```

---

## Чеклист завершения

```
[ ] Claude Code CLI установлен
[ ] claude-config клонирован в ~/claude-config
[ ] sync.sh pull выполнен — ~/.claude/ на месте
[ ] 12 плагинов установлены
[ ] 4 MCP-сервера подключены
[ ] Инструменты для хуков (ruff, prettier, tsc) установлены
[ ] settings.json с permissions и plugins
[ ] Agent Teams включены (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)
[ ] Тестовый запуск Claude Code успешен
```
