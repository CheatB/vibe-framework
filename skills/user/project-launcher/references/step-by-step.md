# Step-by-Step Workflow

Detailed explanation of each step in the project launcher workflow with example dialogs.

## Step 0: Initialization

### User Interaction

```
User: /new-project

Claude:
🚀 Project Launcher активирован!

1️⃣ Название проекта? (латиницей, без пробелов)
2️⃣ Тип проекта? (telegram-bot / nextjs-landing / web-system / другое)
3️⃣ Где разрабатывать? (локально / vps-main / vps-second / решим потом)
4️⃣ Деплой на продакшн? (да, укажи VPS / нет / решим потом)
```

### What Happens

- Creates project structure (local or VPS based on choice)
- Initializes Git repository
- Loads project template if available
- Creates `.project-meta/structure.lock`
- Creates Second Brain entry in `projects/{name}/`

---

## Step 1: Context Gathering

### Process

Collect information about the project through conversation:
- What should the project do?
- Who are the users?
- What are the constraints?
- What defines success?

### Output

Saves to:
- `.project-meta/00-context.md` (local)
- Second Brain: `projects/{name}/00-context.md`

---

## Steps 2-3: Brainstorming

### Tool Used

[Superpowers brainstorming]

### Process

Ask clarifying questions about:
- Functional requirements
- User workflows
- Technical constraints
- Business requirements

### If User Unsure

Suggest options from:
- `development/problems-log.md` (similar past projects)
- Best practices for the project type
- Common patterns

---

## Step 4: User Spec (SMART)

### Tool Used

[planner subagent]

### SMART Format

Creates specification with:
- **Specific:** What exactly will be built
- **Measurable:** Success criteria
- **Achievable:** Feasibility check
- **Relevant:** Why this matters
- **Time-bound:** Timeline

### Output

Saves to:
- `.project-meta/01-user-spec.md`
- Second Brain: `projects/{name}/01-user-spec.md`

---

## Step 5: Tech Spec

### Tool Used

[architect subagent] + [security-reviewer]

### Contents

Technical specification includes:
- Architecture overview
- Technology stack
- Database schema
- API/Bot commands design
- Project structure
- Components breakdown
- Security measures
- Deployment strategy
- Testing strategy
- Monitoring approach
- Scaling considerations

### Output

Saves to:
- `.project-meta/02-tech-spec.md`
- Second Brain: `projects/{name}/02-tech-spec.md`

---

## Step 6: Task Decomposition

### Tool Used

[Superpowers writing-plans]

### Process

Break down into:
- Atomic tasks (small, testable)
- Organized into Phases
- Time estimates per task
- Dependencies marked

### Output

Saves to:
- `.project-meta/03-tasks.md`
- Second Brain: `projects/{name}/03-tasks.md`
- **NOT** Todoist (we use Second Brain for better token efficiency)

---

## Step 7: Execution (TDD Step-by-Step)

### For Each Task (5 sub-steps)

**1. Write Tests FIRST (RED)**
- [tdd-guide subagent] assists
- Write failing tests that define behavior

**2. Write Code (GREEN)**
- Implement minimal code to pass tests
- [code-reviewer] checks quality

**3. Refactor (REFACTOR)**
- Improve code quality
- Keep tests passing

**4. Documentation**
- Create `docs/tasks/task-{id}.md`
- Document implementation decisions

**5. Testing Cycle + Git**
- Run testing cycle for this level
- Git commit + push immediately
- Conventional commit format

### Testing Cycles

See `testing-cycles.md` for complete details.

### Problems Encountered

Document in:
- Second Brain: `development/problems-log.md`
- Format: Date | Project | Task | Problem | Solution | Lesson | Tags
- Reused in future projects

---

## Step 8: Deployment

### Auto-Deploy Process

1. Connect to VPS via MCP
2. Clone from GitHub
3. Install dependencies
4. Run migrations (if applicable)
5. Create systemd service
6. Start service
7. Run healthcheck validation

---

## Step 9: Monitoring Setup

### Auto-Configuration

Sets up:
- Systemd service with auto-restart
- Healthcheck cron (5-minute intervals)
- Telegram alerts on failure
- Journald logging (JSON format, 7-day retention)

---

## Step 10: Final Documentation

### Creates/Updates

- README.md
- CONTRIBUTING.md
- CHANGELOG.md
- .env.example
- All task documentation
- Test plans

### Second Brain

Saves:
- `04-implementation-log.md` (what was built)
- `05-lessons-learned.md` (insights for future)
- Project summary with statistics

---

## Example Full Workflow

```
User: /new-project

Claude: [Prompts for name, type, location, deploy]

User: 
Name: zachot
Type: telegram-bot
Location: vps-main
Deploy: vps-main

Claude:
✓ Created structure on vps-main
✓ Git initialized
✓ Second Brain entry created

Let's gather context...
[Continues through all 10 steps]

[After completion]
✅ Project zachot ready!
📊 Stats:
   - 15 tasks completed
   - 47 tests passing
   - Deployed to vps-main
   - Monitoring active
```
