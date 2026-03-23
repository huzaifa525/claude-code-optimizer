# Claude Code Optimizer

[![npm version](https://img.shields.io/npm/v/claude-code-optimizer.svg)](https://www.npmjs.com/package/claude-code-optimizer)
[![npm downloads](https://img.shields.io/npm/dm/claude-code-optimizer.svg)](https://www.npmjs.com/package/claude-code-optimizer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Created by [Huzefa Nalkheda Wala](https://huzefanalkhedawala.in/)** — AI Product Engineer | IIT Ropar | [GitHub](https://github.com/huzaifa525) | [LinkedIn](https://linkedin.com/in/huzefanalkheda) | [HuggingFace](https://huggingface.co/huzaifa525)

A complete toolkit to make Claude Code faster, cheaper, and smarter when working with your codebase.

**npm:** [npmjs.com/package/claude-code-optimizer](https://www.npmjs.com/package/claude-code-optimizer)

## The Problem

Claude Code explores your codebase on every session — running Glob, Grep, and Read calls that burn tokens. Without guidance, it:

- Wastes 5-15 tool calls just to orient itself
- Re-reads the same files across sessions
- Misses project conventions and makes wrong assumptions
- Burns tokens on exploration instead of actual work

## The Solution

A layered context system that gives Claude a **compass instead of a GPS** — just enough structure to navigate efficiently, loaded only when relevant.

Token Usage Comparison:
┌─────────────────────────────────┬──────────────────┐
│ Without Optimizer               │ With Optimizer   │
├─────────────────────────────────┼──────────────────┤
│ ~20-40 tool calls per task      │ ~5-10 tool calls │
│ Full exploration every session  │ Targeted reads   │
│ No awareness of conventions     │ Follows patterns │
│ Re-discovers architecture       │ Knows the map    │
└─────────────────────────────────┴──────────────────┘

## Installation

Install it — everything sets up automatically. No extra commands needed.

### npm (Windows, Mac, Linux)

```bash
npm i -g claude-code-optimizer
```

That's it. Skills, rules, hooks, and templates are installed to `~/.claude/` automatically.

### curl (Mac, Linux, WSL)

```bash
curl -sL https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/install.sh | bash
```

### PowerShell (Windows — no Node.js needed)

```powershell
irm https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/install.ps1 | iex
```

### Uninstall

```bash
# npm
npx claude-code-optimizer --uninstall

# curl
curl -sL https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/uninstall.sh | bash
```

### Post-Install

Copy the templates to your project and fill in your details:

```bash
cp ~/.claude/CLAUDE.md.template ./CLAUDE.md
cp ~/.claude/claudeignore.template ./.claudeignore
```

---

## What Gets Installed

### Skills (Custom Slash Commands)

Skills are commands you can invoke inside Claude Code with `/skill-name`. They run as specialized prompts that guide Claude to work smarter.

#### `/explore-area [directory]`

**What it does:** Deep exploration of a codebase area before making changes. Reads entry points, maps imports/exports, identifies patterns, checks tests, and returns a structured summary.

**When to use:** Before touching unfamiliar code. Instead of manually reading 10 files, this skill does it in a forked subagent — so the exploration tokens don't pollute your main context.

**How to invoke:**
```
/explore-area src/api/
/explore-area src/components/
/explore-area auth
```

**Example output:**
```
## Area: src/api/

### Key Files
- routes/index.ts → all routes registered here
- middleware/auth.ts → JWT validation

### Patterns
- One file per resource in routes/
- Zod validation at route level

### Gotchas
- auth middleware is duplicated intentionally (different token validation)
```

---

#### `/gen-context`

**What it does:** Generates a fresh project context summary by analyzing package.json, project structure, entry points, framework, git history, and existing CLAUDE.md.

**When to use:** At the start of a new session, or when the project has changed significantly. Gives Claude a full picture of the project without you explaining it.

**How to invoke:**
```
/gen-context
```

**Example output:**
```
## Project: my-app
## Stack: Next.js 14, TypeScript, Prisma, PostgreSQL

### Commands
- Dev: npm run dev
- Test: npm test

### Entry Points
- app/layout.tsx → root layout
- lib/db.ts → database connection

### Suggested CLAUDE.md Updates
- Missing: test command documentation
- Missing: deployment flow
```

---

#### `/smart-edit [what to change]`

**What it does:** Before making any change, it first finds similar existing code in your codebase, reads at least 2 examples of the same pattern, checks conventions, then implements matching the exact style.

**When to use:** When adding new features or modifying code. Ensures Claude follows YOUR patterns instead of generic ones.

**How to invoke:**
```
/smart-edit Add a delete endpoint for users
/smart-edit Add dark mode toggle to settings page
/smart-edit Create a new database migration for adding email field
```

---

#### `/token-check`

**What it does:** Analyzes your current Claude Code session for token efficiency — what's loaded in context, how many MCP servers, conversation length, and whether you should compact or clear.

**When to use:** When a session feels slow or expensive. Gives you a health report with specific optimization tips.

**How to invoke:**
```
/token-check
```

**Example output:**
```
Session Health Report
─────────────────────
Context usage: ~120K / 200K
Conversation turns: 23
Suggested action: /compact
Optimization tips:
- 3 files read multiple times (users.ts, auth.ts, db.ts)
- 2 MCP servers unused this session
- CLAUDE.md is 340 lines (recommend < 200)
```

---

### Rules (Path-Scoped Guidelines)

Rules are markdown files in `~/.claude/rules/` that give Claude persistent context about your coding conventions. They use **path-scoping** — each rule only loads when Claude reads files matching specific patterns, so you don't waste tokens on irrelevant context.

#### `frontend.md`

**Activates when Claude reads:** `src/components/**`, `src/pages/**`, `**/*.tsx`, `**/*.jsx`

**What it tells Claude:** Component structure, styling approach, key components, patterns to follow, and what NOT to do (e.g., no class components).

**How it works:** You edit this file with your actual frontend conventions. When Claude opens a `.tsx` file, these rules automatically load. When Claude is working on backend code, these rules stay hidden — zero token cost.

#### `backend.md`

**Activates when Claude reads:** `src/api/**`, `src/routes/**`, `src/controllers/**`, `src/services/**`

**What it tells Claude:** API structure (routes → controllers → services), how to add new endpoints step-by-step, error handling patterns, and things to never do (e.g., never put business logic in route handlers).

#### `database.md`

**Activates when Claude reads:** `src/database/**`, `src/models/**`, `prisma/**`, `**/*.sql`

**What it tells Claude:** Which ORM you use, migration rules (never edit existing ones), model inventory, query patterns, and safety rules (never store passwords in plain text).

#### `testing.md`

**Activates when Claude reads:** `**/*.test.*`, `**/*.spec.*`, `tests/**`

**What it tells Claude:** Test runner, file conventions, patterns (describe/it, AAA), what to test, what NOT to test, and test database setup.

#### How to customize rules

```bash
# Edit any rule
code ~/.claude/rules/frontend.md

# Add a new rule
code ~/.claude/rules/security.md
```

Add `paths:` frontmatter to scope when it loads:

```yaml
---
paths:
  - "src/api/**"
  - "**/*.ts"
---

Your rules here...
```

---

### Hooks (Automation Scripts)

Hooks are shell scripts that run automatically at specific moments in Claude Code's lifecycle. They don't need to be invoked — they trigger on their own.

#### `generate-context.sh`

**Triggers:** Every time you start a new Claude Code session.

**What it does:** Automatically injects your recent git commits, uncommitted changes, staged files, and current branch into Claude's context. Claude instantly knows what you've been working on without asking.

**How it helps:** Eliminates the "what's the current state?" back-and-forth at the start of every session.

#### `protect-files.sh`

**Triggers:** Every time Claude tries to edit or write a file.

**What it does:** Blocks Claude from modifying sensitive files — `.env`, credentials, lock files, `.git/`, private keys. If Claude tries, it gets a "BLOCKED" message explaining why.

**How it helps:** Prevents accidental edits to files that should never be touched by AI. Peace of mind.

**Protected by default:**
- `.env`, `.env.local`, `.env.production`
- `credentials.json`, `*.pem`, `*.key`
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `.git/` directory

#### `filter-test-output.sh`

**Triggers:** After Claude runs a test command (`npm test`, `jest`, `pytest`, etc.).

**What it does:** If test output exceeds 50 lines, it filters to show only pass/fail summary instead of the full verbose output. Full output stays in the terminal — Claude just gets the summary.

**How it helps:** Test output can be thousands of lines. This saves massive token waste by only feeding Claude the information it actually needs (what passed, what failed).

#### How to activate hooks

Add to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/generate-context.sh" }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/protect-files.sh" }
        ]
      }
    ]
  }
}
```

Or copy the included settings template:

```bash
cp ~/.claude/hooks/../templates/.claude/settings.json ./.claude/settings.json
```

---

### Templates

#### `CLAUDE.md.template`

A ready-to-fill template for your project's `CLAUDE.md` — the main file Claude reads at every session start. Includes sections for:

- Build/test/lint commands
- Entry points map
- Request and data flow diagrams
- Key decisions and gotchas
- Code annotation tags

Copy to your project and fill in:

```bash
cp ~/.claude/CLAUDE.md.template ./CLAUDE.md
```

#### `claudeignore.template`

Pre-configured `.claudeignore` to prevent Claude from reading files that waste tokens — node_modules, build output, lock files, binary assets, IDE files, logs, and secrets.

```bash
cp ~/.claude/claudeignore.template ./.claudeignore
```

---

## How It All Works Together

```
Session Start
    │
    ├── Hook: generate-context.sh runs automatically
    │   └── Claude sees: recent commits, uncommitted changes, current branch
    │
    ├── CLAUDE.md loaded (~200 tokens)
    │   └── Claude sees: commands, entry points, flow diagrams, decisions
    │
    ├── .claudeignore active
    │   └── Claude CANNOT see: node_modules, dist, lock files, .env
    │
    │
You ask Claude to work on something
    │
    ├── Rules load based on what files Claude reads
    │   ├── Touching frontend? → frontend.md loads
    │   ├── Touching API? → backend.md loads
    │   ├── Touching DB? → database.md loads
    │   └── Touching tests? → testing.md loads
    │
    ├── You invoke a skill if needed
    │   ├── /explore-area src/auth/ → deep dive in subagent
    │   ├── /smart-edit Add feature → pattern-aware implementation
    │   └── /token-check → session health report
    │
    └── Hook: protect-files.sh guards every edit
        └── .env, credentials, lock files → BLOCKED
```

**Total overhead: ~200 tokens always loaded.** Everything else loads on-demand.

---

## Optimization Strategies

| Strategy | Token Savings | Effort |
|----------|--------------|--------|
| Lean CLAUDE.md with entry points | ~30% | Low |
| Path-scoped rules | ~20% | Medium |
| `.claudeignore` | ~15% | Low |
| Exploration skill (forked) | ~25% | Low |
| Session start hooks | ~10% | Medium |
| Code annotations (@claude tags) | ~15% | Medium |

---

## Examples

The `examples/` directory includes ready-to-use CLAUDE.md templates for:

- **Next.js App** — App Router, Server Actions, Prisma, Tailwind
- **Express API** — REST, Controllers, Services, JWT Auth
- **Python FastAPI** — SQLAlchemy, Alembic, Pydantic v2
- **Monorepo** — Turborepo, pnpm workspaces, shared packages

Browse them on [GitHub](https://github.com/huzaifa525/claude-code-optimizer/tree/main/examples).

---

## Contributing

1. Fork the repo
2. Add your stack-specific example in `examples/`
3. Submit a PR

## Author

**Huzefa Nalkheda Wala** — AI Product Engineer & Medical AI Researcher

- Website: [huzefanalkhedawala.in](https://huzefanalkhedawala.in/)
- GitHub: [@huzaifa525](https://github.com/huzaifa525)
- LinkedIn: [huzefanalkheda](https://linkedin.com/in/huzefanalkheda)
- HuggingFace: [huzaifa525](https://huggingface.co/huzaifa525)
- Medium: [huzefanalkheda](https://huzefanalkheda.medium.com/)

Currently building enterprise AI systems at CleverFlow (Dubai/India). IIT Ropar AI Program. 45+ production features shipped with 99.5% uptime.

## License

MIT — Huzefa Nalkheda Wala
