---
name: project-launcher
description: Create projects with 10-step workflow from idea to deployment. Handles specs (SMART user spec, tech spec), TDD execution, testing cycles (task/feature/phase/project), git automation, VPS deployment, monitoring. Supports parallel development (2-5 tasks). Integrates with Second Brain for context storage. Uses subagents (planner, architect, tdd-guide, code-reviewer, security-reviewer) and Superpowers skills.
---

# Project Launcher

Universal framework for systematic project creation from idea to production.

## Triggers

- `/new-project`
- "создай новый проект"
- "начать проект"

## Core Workflow

**10-step process:**

**Step 0: Init** → Interactive prompts (name, type, location, deploy target) → creates structure + Git + Second Brain entry

**Step 1: Context** → Gather requirements → save to `.project-meta/00-context.md` + Second Brain

**Step 2-3: Brainstorming** → [Superpowers brainstorming] → clarifying questions → suggestions from problems-log/similar projects

**Step 4: User Spec** → [planner subagent] → SMART specification → save to `01-user-spec.md` + Second Brain

**Step 5: Tech Spec** → [architect subagent] + [security-reviewer] → detailed technical spec → save to `02-tech-spec.md` + Second Brain

**Step 6: Tasks** → [Superpowers writing-plans] → decompose into atomic tasks → save to `03-tasks.md` + Second Brain (NOT Todoist)

**Step 7: Execution** → TDD step-by-step (RED→GREEN→REFACTOR) → documentation → testing cycles → Git commit+push after EACH task

**Step 8: Deployment** → Auto-deploy to VPS via MCP → systemd service → healthcheck

**Step 9: Monitoring** → Auto-setup systemd restart + healthcheck cron + Telegram alerts + journald logs

**Step 10: Docs & Summary** → README, CONTRIBUTING, CHANGELOG → test plans → Second Brain lessons → final stats

## Key Features

**TDD-First:**
- Tests before code (always)
- RED → GREEN → REFACTOR cycle
- [tdd-guide] assists throughout

**Multi-Level Testing:**
- After task: Unit + Integration + Security
- After feature: + Feature tests + Regression + Performance + manual test plan
- After phase: + E2E + Load testing + manual test plan
- After project: Full suite + Smoke + Audit + final acceptance test plan

**Git Automation:**
- Commit + push after EVERY completed task
- Conventional commit format
- No batching

**Structure Lock:**
- `.project-meta/structure.lock` enforces allowed directories
- Blocks forbidden patterns (`*/old/*`, `*_backup*`, etc.)
- Must update lock before creating new directories

**Problems Log:**
- Second Brain: `development/problems-log.md` (global across all projects)
- Claude reads before each new project
- Prevents repeating mistakes

**Auto-Backups:**
- Weekly cron backups
- Stored in `project/backups/`
- Monthly cleanup suggestions

**Parallel Development:**
- 2-5 tasks simultaneously
- Auto-checks dependencies and file conflicts
- Git branches per task → merge when complete

## Integrations

**Superpowers:** brainstorming, writing-plans  
**Subagents:** planner, architect, tdd-guide, code-reviewer, security-reviewer, build-error-resolver, e2e-runner  
**MCP:** GitHub (commits), VPS (deploy), Memory, Sequential-thinking  
**Second Brain:** All specs, context, problems-log

## Second Brain Structure

```
projects/{name}/
├── 00-context.md
├── 01-user-spec.md
├── 02-tech-spec.md
├── 03-tasks.md
├── 04-implementation-log.md
└── 05-lessons-learned.md

development/
└── problems-log.md (global)
```

## Detailed References

For complete workflows, examples, and troubleshooting:

- **references/step-by-step.md** — Detailed explanation of each step with example dialogs
- **references/testing-cycles.md** — Complete testing strategy for all levels
- **references/parallel-dev.md** — Parallel development workflow + scenarios
- **references/structure-lock.md** — Structure lock format and enforcement rules
- **references/problems-log.md** — Problems log format and usage examples

## Principles

**Goal:** Systematic approach, minimal tokens, maximum quality  
**Process:** Planning → TDD → Documentation → Learn from mistakes  
**Storage:** Second Brain (not Claude memory) for token efficiency  
**Testing:** Always tests first  
**Structure:** Strict enforcement via structure.lock
