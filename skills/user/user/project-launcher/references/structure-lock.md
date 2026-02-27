# Structure Lock

Mechanism for enforcing strict project structure and preventing code rot.

## Purpose

**Structure Lock prevents:**
- Creating backup folders (`old/`, `backup/`, `temp/`)
- Renaming files to `*_old`, `*_backup`
- Accumulating unused code
- Structural chaos

**Structure Lock ensures:**
- Clean, intentional directory structure
- Deliberate changes only
- Easy navigation
- No code rot

---

## File Location

`.project-meta/structure.lock`

---

## Format (YAML)

```yaml
# Structure Lock Configuration
# Updated: 2026-02-02

allowed_directories:
  - src/
  - tests/
  - docs/
  - scripts/
  - config/
  - .project-meta/
  - backups/          # Only for automated backups

allowed_src_structure:
  - src/bot/          # Bot-related code
  - src/handlers/     # Command handlers
  - src/database/     # Database models & queries
  - src/middlewares/  # Middleware functions
  - src/utils/        # Utility functions
  - src/config/       # Configuration

forbidden_patterns:
  - "*/old/*"         # No 'old' directories anywhere
  - "*/backup/*"      # No 'backup' directories
  - "*_old*"          # No '_old' in names
  - "*_backup*"       # No '_backup' in names
  - "*_temp*"         # No '_temp' in names
  - "*/tmp/*"         # No 'tmp' directories
  - "*.bak"           # No .bak files
  - "*~"              # No editor backup files

rules:
  - "Create directories only from allowed lists"
  - "Delete obsolete code immediately, don't rename"
  - "Update structure.lock before adding new directories"
  - "Run cleanup command if structure gets messy"
```

---

## How It Works

### When Creating Directory

```
User: Создай папку src/helpers

Claude checks structure.lock:
1. Is 'src/helpers/' in allowed_src_structure? → NO
2. Matches forbidden_patterns? → NO

Claude:
⚠️ 'src/helpers/' not in allowed structure.

Options:
A. Add to allowed_src_structure (if intended)
B. Use existing 'src/utils/' instead
C. Explain why new directory is needed

What should I do?
```

### User Chooses Option A

```
User: А, добавь в allowed

Claude:
✓ Updating .project-meta/structure.lock...
✓ Added 'src/helpers/' to allowed_src_structure
✓ Creating src/helpers/

Directory created. You can now add files there.
```

### When Pattern is Forbidden

```
User: Переименуй старый файл в src/bot_old.py

Claude:
❌ BLOCKED by structure.lock

'*_old*' matches forbidden pattern.

Proper approach:
1. Delete src/bot.py (if obsolete)
2. Commit: "refactor: remove obsolete bot.py"

OR

1. Keep src/bot.py (if still needed)
2. Refactor and improve it

Never rename to *_old. Delete or keep.

What would you like to do?
```

---

## Enforcement Rules

### Rule 1: Allowed Directories Only

**Valid:**
```
src/handlers/start.py          ✅ (allowed)
tests/test_handlers.py         ✅ (allowed)
docs/architecture.md           ✅ (allowed)
```

**Invalid:**
```
source/handlers/start.py       ❌ (not allowed)
test/test_handlers.py          ❌ (not allowed, should be 'tests/')
documentation/arch.md          ❌ (not allowed, should be 'docs/')
```

### Rule 2: No Forbidden Patterns

**Valid:**
```
src/bot.py                     ✅
src/bot_v2.py                  ✅ (version suffix OK if needed)
```

**Invalid:**
```
src/bot_old.py                 ❌ (*_old* forbidden)
src/old/bot.py                 ❌ (*/old/* forbidden)
src/backup/bot.py              ❌ (*/backup/* forbidden)
src/bot_backup.py              ❌ (*_backup* forbidden)
src/bot~                       ❌ (*~ forbidden)
src/bot.bak                    ❌ (*.bak forbidden)
```

### Rule 3: Update Lock Before Creating

**Process:**
```
1. Check if directory allowed
2. If not:
   a. Ask user if should add
   b. Update structure.lock
   c. Then create directory
3. If yes:
   a. Create directory immediately
```

### Rule 4: Delete, Don't Rename

**Wrong:**
```
git mv src/bot.py src/bot_old.py     ❌
```

**Right:**
```
git rm src/bot.py                    ✅
git commit -m "refactor: remove obsolete bot.py"
```

---

## Updating Structure Lock

### Adding New Directory

**Manual:**
```yaml
allowed_src_structure:
  - src/bot/
  - src/handlers/
  - src/api/          # ← Add new
```

**Via Claude:**
```
User: Add src/api/ to structure

Claude:
✓ Added src/api/ to structure.lock
```

### Adding Forbidden Pattern

```yaml
forbidden_patterns:
  - "*/old/*"
  - "*_deprecated*"   # ← Add new
```

---

## Example Projects

### Telegram Bot

```yaml
allowed_directories:
  - src/
  - tests/
  - docs/
  - .project-meta/
  - backups/

allowed_src_structure:
  - src/bot/          # Main bot logic
  - src/handlers/     # Command handlers
  - src/database/     # Models & migrations
  - src/middlewares/  # Middlewares
  - src/keyboards/    # Keyboard layouts
  - src/utils/        # Utilities

forbidden_patterns:
  - "*/old/*"
  - "*_old*"
  - "*_backup*"
```

### Next.js Web App

```yaml
allowed_directories:
  - src/
  - public/
  - tests/
  - docs/
  - .project-meta/
  - backups/

allowed_src_structure:
  - src/app/          # Next.js app directory
  - src/components/   # React components
  - src/lib/          # Libraries & utilities
  - src/hooks/        # Custom hooks
  - src/styles/       # Global styles
  - src/types/        # TypeScript types

forbidden_patterns:
  - "*/old/*"
  - "*_old*"
  - "*_backup*"
  - "*/tmp/*"
```

### FastAPI Backend

```yaml
allowed_directories:
  - src/
  - tests/
  - docs/
  - migrations/
  - .project-meta/
  - backups/

allowed_src_structure:
  - src/api/          # API routes
  - src/models/       # Database models
  - src/schemas/      # Pydantic schemas
  - src/services/     # Business logic
  - src/core/         # Core configs
  - src/utils/        # Utilities

forbidden_patterns:
  - "*/old/*"
  - "*_old*"
  - "*_backup*"
```

---

## Benefits

### 1. Clean Codebase

No accumulation of:
- `old/` folders
- `*_backup` files
- Temporary directories
- Dead code

### 2. Clear Intent

Every directory has a purpose:
- Defined in structure.lock
- Documented
- Intentional

### 3. Easy Navigation

Developers know where to find:
- Handlers → `src/handlers/`
- Tests → `tests/`
- Docs → `docs/`

No confusion about:
- Is it in `old/` or `backup/`?
- Which version is current?

### 4. Git History Clarity

```
git log --oneline
abc123 feat: add new handler
def456 refactor: remove obsolete code  ← Clear action
ghi789 fix: bug in middleware
```

NOT:
```
abc123 rename old code to backup
def456 create old folder
ghi789 move to old_old folder
```

---

## Best Practices

### 1. Define Structure Early

Create structure.lock in Step 0 of project launch:
```
User: /new-project

Claude:
[... prompts ...]
✓ Creating structure.lock with project type defaults
```

### 2. Keep It Simple

Don't over-specify:
```
❌ Too specific:
allowed_src_structure:
  - src/handlers/start/
  - src/handlers/help/
  - src/handlers/about/
  [... 50 more entries ...]

✅ Better:
allowed_src_structure:
  - src/handlers/      # All handlers go here
```

### 3. Document Decisions

Add comments in structure.lock:
```yaml
allowed_src_structure:
  - src/api/          # REST API endpoints
  - src/legacy/       # Legacy code, will be removed Q2
```

### 4. Review Periodically

Every phase completion:
```
Claude: 
Phase 2 complete.

Structure check:
✓ All files in allowed directories
✓ No forbidden patterns
✓ Structure.lock up to date

Ready to continue.
```

---

## Troubleshooting

### Problem: Too Restrictive

**Symptom:**
Claude blocks every new directory

**Solution:**
```
User: Structure.lock слишком строгий, ослабь

Claude:
Понял. Какие директории добавить?

User: Разреши все в src/

Claude:
✓ Updated forbidden_patterns to only block:
  - */old/*
  - *_backup*
  - *_old*

Now allowing any structure in src/ as long as
it doesn't match forbidden patterns.
```

### Problem: Unclear Structure

**Symptom:**
Not sure where to put new code

**Solution:**
```
User: Где должен быть код для email отправки?

Claude:
Looking at structure.lock...

Best location: src/services/email.py

Reasoning:
- Business logic → services/
- Not a handler (no user command)
- Not utilities (specific domain logic)

Creating src/services/email.py...
```

---

## Summary

**Structure Lock = Project Discipline**

- ✅ Clean structure
- ✅ No code rot
- ✅ Easy navigation
- ✅ Clear git history
- ✅ Intentional changes only

**Update it when needed, enforce it always.**
