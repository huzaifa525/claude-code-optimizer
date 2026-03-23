# Project: [YOUR PROJECT NAME]
<!-- Template by Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer -->

## Commands
- Build: `[your build command]`
- Test: `[your test command]`
- Lint: `[your lint command]`
- Dev: `[your dev server command]`

## Entry Points
- [src/app.ts]              → App setup, middleware registration
- [src/routes/index.ts]     → All routes mounted here
- [src/models/index.ts]     → All database models exported
- [src/config/index.ts]     → Environment config, secrets

## Request Flow
Client → [Framework] → Middleware → Route Handler → Controller → Service → Database

## Data Flow
Database → ORM → Service Layer → Controller → Response → Client Cache → UI

## Key Decisions
- [Why X not Y] → [reason]
- [Why this pattern] → [reason]

## Things That Look Wrong But Aren't
- [file/pattern] → [why it's intentional]

## Conventions
- [Your naming convention]
- [Your file organization rule]
- [Your testing approach]

## Code Annotations
- Search `@claude-entry` for system entry points
- Search `@claude-pattern` for examples to follow
- Search `@claude-warning` for files not to modify

## Workflow
- New feature → `/plan` first, then `/smart-edit` to implement
- Bug fix → `/debug-error` or `/fix-issue [number]`
- Before editing unfamiliar code → `/explore-area [dir]`
- After all changes → `/review` then `/commit`
- Ready to merge → `/create-pr`
- New developer → `/onboard`
