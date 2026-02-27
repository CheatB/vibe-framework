# Parallel Development Workflow

Guide for executing multiple independent tasks simultaneously.

## When to Use Parallel Mode

### ✅ Good for Parallel

**Multiple independent tasks:**
- Different bot commands (/start, /help, /settings)
- Different API endpoints
- Different UI components
- Different test suites
- Different models/schemas

**No file conflicts:**
- Tasks modify different files
- No shared dependencies

**No task dependencies:**
- Task B doesn't need Task A's output
- Can be developed in any order

### ❌ NOT Good for Parallel

**Sequential dependencies:**
- Setup → Core features
- Models → Migrations
- Auth → Protected endpoints

**Same file modifications:**
- Multiple tasks editing config
- Shared module changes

**Strict order required:**
- Database migrations
- Deployment steps
- Integration sequence

---

## How It Works

### Step 1: Trigger

```
User: Сделай Task 2.1, 2.3 и 3.1 параллельно
```

or

```
User: Делай Task 2.1, 2.2, 2.3
Claude: [Auto-analyzes] → runs parallel if safe
```

### Step 2: Dependency Analysis

Claude checks each task:

```
Task 2.1: /start command
├── Files: src/handlers/start.py, tests/test_start.py
├── Dependencies: None
└── Status: ✅ Safe for parallel

Task 2.3: /help command  
├── Files: src/handlers/help.py, tests/test_help.py
├── Dependencies: None
└── Status: ✅ Safe for parallel

Task 3.1: Unit tests base
├── Files: tests/conftest.py, tests/utils.py
├── Dependencies: None
└── Status: ✅ Safe for parallel
```

**Conflict Check:**
```
File overlaps: None
Dependencies: None
→ ✅ Can execute in parallel
```

### Step 3: Git Branching

Creates separate branch for each task:

```bash
git checkout main
git checkout -b task-2.1-start
git checkout main
git checkout -b task-2.3-help
git checkout main
git checkout -b task-3.1-unit-tests
```

### Step 4: Parallel Execution

Each task runs independently:

```
[Frontend-1 Subagent] Task 2.1
├── RED: Write tests for /start
├── GREEN: Implement /start handler
├── REFACTOR: Clean up code
├── DOC: Document task
├── TEST: Run task-level tests
└── COMMIT: "feat(bot): add /start command"

[Frontend-2 Subagent] Task 2.3
├── RED: Write tests for /help
├── GREEN: Implement /help handler
├── REFACTOR: Clean up code
├── DOC: Document task
├── TEST: Run task-level tests
└── COMMIT: "feat(bot): add /help command"

[Testing-1 Subagent] Task 3.1
├── Create conftest.py
├── Create test utilities
├── Write tests for utilities
├── DOC: Document test setup
├── TEST: Run tests
└── COMMIT: "test: add base test infrastructure"
```

**Timeline:**
```
Time    Frontend-1      Frontend-2      Testing-1
0:00    [Start 2.1]     [Start 2.3]     [Start 3.1]
0:05    [Testing]       [Coding]        [Setup]
0:08    [✓ Done]        [Testing]       [Testing]
0:12                    [✓ Done]        [✓ Done]

Total: 12 minutes (vs 28 minutes sequential)
```

### Step 5: Merge & Validation

```bash
# Switch to main
git checkout main

# Merge all branches
git merge task-2.1-start
git merge task-2.3-help
git merge task-3.1-unit-tests

# Check for conflicts
# (Auto-resolve if possible, or ask user)

# Run full test suite
pytest
# (Ensure everything works together)

# Push to remote
git push origin main
```

---

## Scenarios & Examples

### Scenario 1: Simple Parallel Tasks

```
User: Сделай Task 1.1, 1.2, 1.3

Claude:
🔀 Анализ зависимостей...

Task 1.1: Database models (User, Message)
Task 1.2: Database migrations
Task 1.3: Database seeder

⚠️ Зависимость обнаружена:
- Task 1.2 требует Task 1.1 (migrations need models)
- Task 1.3 требует Task 1.1 (seeder needs models)

Рекомендую последовательность:
1. Task 1.1 (models) → СНАЧАЛА
2. Task 1.2 (migrations) + Task 1.3 (seeder) → ПАРАЛЛЕЛЬНО

Применить? (да/нет)
```

### Scenario 2: File Conflict Detection

```
User: Сделай Task 2.1 и 2.2 параллельно

Claude:
🔀 Анализ файлов...

Task 2.1: Add logging to config.py
├── Files: config.py (lines 15-20)

Task 2.2: Add database URL to config.py
├── Files: config.py (lines 25-30)

⚠️ Конфликт файлов обнаружен:
Оба таска изменяют config.py

Хотя изменения в разных местах файла, рекомендую:
1. Task 2.1 → СНАЧАЛА
2. Task 2.2 → ПОСЛЕ

Или можно объединить в один Task 2.1-2: "Update config.py (logging + database)"

Как поступим?
```

### Scenario 3: Automatic Parallel Mode

```
User: Создай 5 API endpoints для CRUD операций User

Claude:
🔀 Декомпозиция на задачи...

Task 3.1: GET /users (list)
Task 3.2: GET /users/:id (get one)
Task 3.3: POST /users (create)
Task 3.4: PUT /users/:id (update)
Task 3.5: DELETE /users/:id (delete)

Анализ:
✅ Все задачи независимые
✅ Разные файлы (handlers/ + tests/)
✅ Нет зависимостей

Буду делать параллельно (3 задачи одновременно):

Волна 1: Task 3.1, 3.2, 3.3
Волна 2: Task 3.4, 3.5

Начинаю...
```

### Scenario 4: Resolving Merge Conflicts

```
Claude:
✅ Все задачи завершены, начинаю слияние...

git merge task-4.1-auth
git merge task-4.2-validation

⚠️ КОНФЛИКТ в src/middleware/index.js:

<<<<<<< task-4.1-auth
export { authMiddleware } from './auth';
=======
export { validationMiddleware } from './validation';
>>>>>>> task-4.2-validation

Решение: объединить экспорты
```js
export { authMiddleware } from './auth';
export { validationMiddleware } from './validation';
```

Применяю...
✓ Конфликт разрешён
✓ Запускаю тесты: PASS
✓ Коммичу: "merge: combine auth and validation tasks"
```

### Scenario 5: Force Parallel (Override)

```
User: Сделай Task 5.1 и 5.2 параллельно, я знаю что можно

Claude:
⚠️ Предупреждение:
Task 5.1 и Task 5.2 оба изменяют database/schema.py

Ты уверен? Это может привести к конфликтам.

User: Да, уверен

Claude:
Хорошо, запускаю принудительно параллельно.
Буду внимателен при слиянии.

[Выполняет задачи]

[При слиянии тщательно проверяет конфликты
 и обязательно показывает результат пользователю]
```

---

## Limits & Recommendations

### Max Parallel Tasks: 3-5

**Optimal: 2-3 tasks**
- Easy to track
- Low conflict risk
- Manageable context

**Acceptable: 4-5 tasks**
- For simple, similar tasks
- High developer confidence
- Clear separation

**NOT recommended: 6+ tasks**
- High cognitive load
- Conflict risk increases
- Context switching overhead

### Grouping Strategy

**Group by similarity:**
```
✅ Good:
- Group 1: All bot commands (/start, /help, /about)
- Group 2: All database models (User, Post, Comment)
- Group 3: All API endpoints for one resource

❌ Bad:
- Mixed: bot command + database + API + tests + docs
```

**Group by independence:**
```
✅ Good:
- Feature A components (all independent files)
- Feature B components (all independent files)

❌ Bad:
- Feature A + Feature B (if they share code)
```

---

## Best Practices

### 1. Clear Task Boundaries

```
✅ Good:
Task 3.1: Implement /start command
├── File: src/handlers/start.py
├── Tests: tests/test_start.py
└── Clear scope

❌ Bad:
Task 3.1: Add bot commands and fix config
├── Multiple unrelated changes
├── Unclear scope
```

### 2. Independent Test Suites

Each task has its own tests:
```
Task 3.1 tests: tests/handlers/test_start.py
Task 3.2 tests: tests/handlers/test_help.py
Task 3.3 tests: tests/handlers/test_about.py
```

No shared test setup (unless in conftest.py)

### 3. Atomic Commits

Each task = one commit:
```
git log --oneline
abc123 feat(bot): add /start command
def456 feat(bot): add /help command
ghi789 feat(bot): add /about command
```

NOT:
```
abc123 wip
def456 more work
ghi789 fix
```

### 4. Communication

Claude announces:
- When starting parallel mode
- Which tasks are running
- When each completes
- Any issues encountered
- Final merge result

### 5. Fallback to Sequential

If ANY doubt about safety:
```
Claude: 
⚠️ Не уверен что эти задачи независимые.
Рекомендую делать последовательно для безопасности.

Переключаюсь на последовательное выполнение...
```

---

## Troubleshooting

### Problem: Merge conflicts

**Prevention:**
- Better task decomposition
- Check file overlaps before starting

**Resolution:**
- Auto-resolve if simple (imports, exports)
- Ask user for complex conflicts
- Show diff clearly

### Problem: Test failures after merge

**Cause:**
- Tasks had hidden dependencies
- Integration issues

**Resolution:**
- Revert to pre-merge state
- Run tasks sequentially
- Debug integration issues

### Problem: Context switching overhead

**Symptom:**
- Claude seems confused
- Mixing up task details

**Resolution:**
- Reduce parallel task count
- Add clearer task documentation
- Use more descriptive branch names

---

## Commands Summary

```
# Auto-detect
"Сделай Task 2.1, 2.2, 2.3"
→ Claude analyzes and decides

# Force parallel
"Сделай Task 2.1 и 2.3 параллельно"
→ Parallel if safe, warns if not

# Force sequential
"Сделай Task 2.1, 2.2, 2.3 последовательно"
→ Always sequential, no parallel

# Check status
"Как идут параллельные задачи?"
→ Shows progress of each task
```
