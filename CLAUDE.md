# Глобальные правила Claude Code

## Кто я
<AUTHOR> (@CheatB), вайбкодер, GMT+7, macOS.
Создаю приложения с помощью нейросетей. Python, Node.js, TypeScript.

## Язык и стиль
- Код, комментарии, документация, переменные — **русский**
- Простым языком, технический жаргон допустим
- Живо, с иронией, без канцелярита

## Безопасность
- НИКОГДА не коммитить .env, токены, пароли
- SQL запросы только через параметризацию
- Все user inputs — враждебные по умолчанию
- Rate limiting на публичных endpoints

## Качество кода
- DRY, KISS, YAGNI
- Файл > 300 строк → разбить
- Функция > 50 строк → разбить
- Перед изменением: `grep` usages по кодовой базе
- Тесты на критический функционал

## Git
- Коммит-сообщения: conventional commits (feat/fix/refactor/docs)
- Коммитить только по моей команде
- Protected branches: через PR

## Инфраструктура (февраль 2026)

Централизованная модель: **Vibe Dev Factory**.
dev-server = dev-hub (все репо, Claude CLI, CI/CD), остальные VPS = только прод.
Клиент: VSCode + Remote-SSH, workspace: ~/all-projects.code-workspace

### Серверы (Beget VPS)
| Хост | IP | Роль | Путь |
|------|-----|------|------|
| dev-server | <SERVER_IP> | DEV: все проекты, runners | ~/ |
| project-1 | <SERVER_IP> | PROD: Project1 | /home/deploy/project-1 |
| project-2 | <SERVER_IP> | PROD: Project2ibe | /home/claude/project-2 |
| project-3 | <SERVER_IP> | PROD: Vibe Factory | /home/claude/project-3 |
| project-4 | <SERVER_IP> | PROD: ProjectApp | /home/claude/project-app |
| project-5 | <SERVER_IP> | PROD: Project5 | /home/claude/project-5 |

### Claude CLI на dev-server
Каждый проект в отдельной tmux-сессии.
- Запуск: `dev` (алиас ~/start-all.sh)
- Флаги: `--max --continue --dangerously-skip-permissions`
- Алиасы: z sv db oc gr vf

### CI/CD
- 7 GitHub self-hosted runners на dev-server
- Push в main -> runner -> SSH-деплой на прод
- Ручной: `~/deploy-all.sh [сервер] [--dry-run] [--rollback]`

### Бэкап секретов
- Cron 3:00: .env с dev+prod, AES256, -> CheatB/secrets-backup (private)
- Скрипты: ~/backup-secrets.sh, ~/restore-secrets.sh

### SSH-ключи
- Мак -> VPS: ~/.ssh/vps_master (ed25519)
- dev-server -> прод: ~/.ssh/id_ed25519


## Инструменты

### Slash-команды
/new-project /code-review /tdd /test /deploy /status /cleanup

### Hooks
- PreToolUse Bash: tmux напоминание для долгих команд
- PreToolUse Write/Edit: security scan + backup
- PostToolUse Edit/Write: автоформатирование (prettier/black)
- Stop: проверка staged на console.log/debugger

### SSH-алиасы (из ~/.ssh/config)
project-1, project-2, project-3, project-5, project-4

## Agent Teams
Каталог ролей в AGENTS.md.
Тиммейты на claude-sonnet-4-5 (5x дешевле Opus).
Простые баги — одна сессия без teams.
