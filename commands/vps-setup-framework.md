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

### Шаг 3: Создание структуры .claude/

```bash
mkdir -p ~/.claude/{rules,commands,hooks/scripts,skills/user,agents}
```

### Шаг 4: Копирование фреймворка

Скопировать с локальной машины на VPS всю структуру `.claude/`:

**Вариант A: Через Git (рекомендуемый)**
Если `.claude/` в Git-репозитории:
```bash
cd ~ && git clone <repo-url> .claude-repo
cp -r .claude-repo/.claude/* ~/.claude/
```

**Вариант B: Через SCP**
С локальной машины:
```bash
scp -r ~/.claude/* claude@<host>:~/.claude/
```

**Вариант C: Через MCP (из Claude Desktop)**
Если есть SSH-MCP к серверу — создать файлы прямо через MCP-команды.

### Шаг 5: Установка плагинов

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

### Шаг 6: Настройка MCP-серверов

```bash
claude mcp add --transport http sentry-mcp https://mcp.sentry.dev/mcp
claude mcp add database-mcp -- npx -y @bytebase/dbhub
claude mcp add docker-mcp -- npx -y @quantgeekdev/docker-mcp
claude mcp add telegram-mcp -- npx -y @s1lverain/claude-telegram-mcp
```

### Шаг 7: Установка инструментов для хуков

```bash
# Python линтер
pip3 install ruff black isort --break-system-packages

# Node.js инструменты
sudo npm install -g prettier typescript
```

### Шаг 8: Настройка permissions (settings.json)

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

### Шаг 9: Сделать хуки исполняемыми

```bash
chmod +x ~/.claude/hooks/scripts/*.sh
```

### Шаг 10: Верификация

```bash
# Проверить CLI
claude --version

# Проверить плагины
claude plugin list

# Проверить MCP
claude mcp list

# Проверить структуру
ls -la ~/.claude/rules/ ~/.claude/commands/ ~/.claude/agents/ ~/.claude/skills/user/

# Тестовый запуск
claude "скажи привет и покажи список доступных правил из rules/"
```

---

## Чеклист завершения

```
[ ] Claude Code CLI установлен
[ ] .claude/ структура на месте (rules, commands, hooks, skills, agents)
[ ] 12 плагинов установлены
[ ] 4 MCP-сервера подключены
[ ] Хуки исполняемые (chmod +x)
[ ] Инструменты для хуков (ruff, prettier, tsc) установлены
[ ] settings.json с permissions и plugins
[ ] Agent Teams включены (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)
[ ] Тестовый запуск Claude Code успешен
```

---

## Быстрый скрипт (всё в одном)

При необходимости, пользователь может попросить сгенерировать один bash-скрипт `install-vibe-framework.sh`, который выполнит все шаги автоматически. Скрипт должен:
1. Проверить зависимости (node, npm, python3, git)
2. Установить Claude Code CLI
3. Создать структуру директорий
4. Скопировать файлы фреймворка
5. Установить плагины
6. Настроить MCP-серверы
7. Установить инструменты (ruff, prettier)
8. Настроить permissions
9. Сделать хуки исполняемыми
10. Запустить верификацию
