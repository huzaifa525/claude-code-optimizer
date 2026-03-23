# Claude Code Optimizer

[![npm version](https://img.shields.io/npm/v/claude-code-optimizer.svg)](https://www.npmjs.com/package/claude-code-optimizer)
[![npm downloads](https://img.shields.io/npm/dm/claude-code-optimizer.svg)](https://www.npmjs.com/package/claude-code-optimizer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Created by [Huzefa Nalkheda Wala](https://huzefanalkhedawala.in/)** — AI Product Engineer \| IIT Ropar \| [GitHub](https://github.com/huzaifa525) \| [LinkedIn](https://linkedin.com/in/huzefanalkheda) \| [HuggingFace](https://huggingface.co/huzaifa525)

A complete toolkit to make Claude Code faster, cheaper, and smarter when working with your codebase.

**npm:** [npmjs.com/package/claude-code-optimizer](https://www.npmjs.com/package/claude-code-optimizer)

---

## The Problem

Claude Code explores your codebase on every session — running Glob, Grep, and Read calls that burn tokens. Without guidance, it:

- Wastes 5-15 tool calls just to orient itself
- Re-reads the same files across sessions
- Misses project conventions and makes wrong assumptions
- Burns tokens on exploration instead of actual work

## The Solution

A layered context system that gives Claude a **compass instead of a GPS** — just enough structure to navigate efficiently, loaded only when relevant.

| Metric | Without Optimizer | With Optimizer |
| :--- | :---: | :---: |
| Tool calls per task | ~20-40 | ~5-10 |
| Session start | Full exploration | Targeted reads |
| Conventions | No awareness | Follows patterns |
| Architecture | Re-discovers every time | Knows the map |

---

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

| Type | Count | Installed To |
| :--- | :---: | :--- |
| Skills | 21 | `~/.claude/skills/` |
| Rules | 5 | `~/.claude/rules/` |
| Hooks | 8 | `~/.claude/hooks/` |
| Templates | 2 | `~/.claude/` |

---

## Skills (Custom Slash Commands)

Skills are commands you can invoke inside Claude Code with `/skill-name`. They run as specialized prompts that guide Claude to work smarter.

#### Exploration & Context

| Skill | Purpose | How to Invoke |
| :--- | :--- | :--- |
| `/explore-area` | Deep codebase exploration before changes | `/explore-area src/api/` |
| `/gen-context` | Generate fresh project context summary | `/gen-context` |
| `/onboard` | Full onboarding guide for new developers | `/onboard` |
| `/token-check` | Session token usage analysis | `/token-check` |
| `/optimize-tokens` | Web search for latest optimization tips + project analysis | `/optimize-tokens` |

#### Development Workflow

| Skill | Purpose | How to Invoke |
| :--- | :--- | :--- |
| `/planning` | Persistent markdown planning for complex tasks | Auto-activates on complex tasks |
| `/plan` | Create implementation plan with task breakdown | `/plan Add user notifications` |
| `/smart-edit` | Pattern-aware code changes | `/smart-edit Add delete endpoint` |
| `/tdd` | Test-Driven Development cycle | `/tdd user login validation` |
| `/fix-issue` | Fetch GitHub issue, implement fix, test, commit | `/fix-issue 42` |
| `/debug-error` | Analyze error, find root cause, fix | `/debug-error Cannot read property of undefined` |
| `/refactor` | Refactor code while preserving behavior | `/refactor auth middleware` |
| `/migrate` | Migrate between frameworks/versions | `/migrate React-Router-v5 React-Router-v6` |

#### Git & GitHub

| Skill | Purpose | How to Invoke |
| :--- | :--- | :--- |
| `/commit` | Generate conventional commit message and commit | `/commit` |
| `/create-pr` | Create PR with auto-generated description | `/create-pr` |
| `/changelog` | Generate changelog from git history | `/changelog` |

#### Code Quality & Security

| Skill | Purpose | How to Invoke |
| :--- | :--- | :--- |
| `/review` | Review changes for quality, security, performance | `/review` |
| `/security-scan` | OWASP top 10, secrets, injection scan | `/security-scan` |
| `/perf-check` | N+1 queries, memory leaks, bundle size analysis | `/perf-check src/api/` |
| `/dep-check` | Outdated/vulnerable dependency check | `/dep-check` |
| `/document` | Generate docs/JSDoc/docstrings | `/document src/utils/` |

### `/explore-area [directory]`

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

### `/gen-context`

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

### `/smart-edit [what to change]`

**What it does:** Before making any change, it first finds similar existing code in your codebase, reads at least 2 examples of the same pattern, checks conventions, then implements matching the exact style.

**When to use:** When adding new features or modifying code. Ensures Claude follows YOUR patterns instead of generic ones.

**How to invoke:**

```
/smart-edit Add a delete endpoint for users
/smart-edit Add dark mode toggle to settings page
/smart-edit Create a new database migration for adding email field
```

---

### `/token-check`

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

### `/planning`

**What it does:** Automatically creates a `task_plan.md` file for complex tasks. Breaks work into steps, tracks progress with checkboxes, and survives across sessions. When you resume a session, Claude reads the plan and continues where it left off.

**Auto-activates** when a task requires 5+ steps. No need to invoke manually.

---

### `/commit`

**What it does:** Analyzes your staged changes (`git diff --cached`), checks your recent commit style, and generates a conventional commit message (feat:, fix:, refactor:, etc.). Then commits.

**How to invoke:** Stage your changes with `git add`, then type `/commit`.

---

### `/review`

**What it does:** Runs `git diff`, reads every changed file, and checks for code quality, security vulnerabilities, performance issues, and convention violations. Returns a structured report with severity levels.

**Runs in a forked subagent** — review tokens don't pollute your main context.

---

### `/create-pr`

**What it does:** Analyzes ALL commits on your branch (not just the latest), generates a PR title, summary bullets, change list, and test plan checklist. Pushes and creates the PR via `gh`.

---

### `/fix-issue [number]`

**What it does:** Fetches a GitHub issue, creates a branch, finds relevant code, implements the fix, writes tests, runs them, and commits with the issue number.

**How to invoke:** `/fix-issue 42`

---

### `/tdd [feature]`

**What it does:** Strict Test-Driven Development — writes a failing test first, implements the minimum code to pass, verifies, then refactors. Repeats until the feature is complete.

---

### `/debug-error [error]`

**What it does:** Parses an error message or stack trace, traces the root cause through the codebase, checks recent git changes, implements a fix, and verifies.

---

### `/refactor [target]`

**What it does:** Runs tests first to establish a baseline, then refactors incrementally. After each change, runs tests again. If anything breaks, reverts immediately.

---

### `/security-scan`

**What it does:** Scans for OWASP top 10 vulnerabilities — hardcoded secrets, SQL injection, XSS, missing auth, insecure configs, dependency vulnerabilities. Returns a severity-ranked report.

**Runs in a forked subagent** — scan tokens stay isolated.

---

### `/perf-check [target]`

**What it does:** Analyzes for N+1 queries, memory leaks, unnecessary re-renders, large bundle imports, missing caching, O(n²) algorithms, and more.

**Runs in a forked subagent.**

---

### `/dep-check`

**What it does:** Runs `npm audit` / `pip audit`, checks for outdated packages, flags deprecated dependencies, and suggests upgrades with breaking change warnings.

---

### `/changelog`

**What it does:** Generates a changelog from git history since the last tag. Groups commits by type (features, fixes, breaking changes). Outputs or updates CHANGELOG.md.

---

### `/migrate [from] [to]`

**What it does:** Greps for all usages of the old API/library, creates a migration plan, applies changes file by file, runs tests after each file, and reports what couldn't be auto-migrated.

**How to invoke:** `/migrate Express-v4 Express-v5` or `/migrate React-Router-v5 React-Router-v6`

---

### `/onboard`

**What it does:** Generates a complete onboarding guide — project structure, tech stack, dev workflow, code conventions, common tasks, environment variables, and useful commands.

**Runs in a forked subagent.**

---

### `/plan [feature]`

**What it does:** Creates a phased implementation plan with task breakdown, file mapping, reference code pointers, dependencies, and risk assessment.

**Runs in a forked subagent** using the Plan agent.

---

### `/optimize-tokens`

**What it does:** Searches the web for the latest Claude Code token optimization tips, then analyzes your current project setup (CLAUDE.md size, .claudeignore, rules, skills, MCP servers, settings). Returns a scored report with quick wins.

---

## Rules (Path-Scoped Guidelines)

Rules are markdown files in `~/.claude/rules/` that give Claude persistent context about your coding conventions. They use **path-scoping** — each rule only loads when Claude reads files matching specific patterns, so you don't waste tokens on irrelevant context.

| Rule | Activates When Claude Reads | What It Tells Claude |
| :--- | :--- | :--- |
| `frontend.md` | `src/components/**`, `src/pages/**`, `**/*.tsx`, `**/*.jsx` | Component structure, styling approach, patterns to follow, what NOT to do |
| `backend.md` | `src/api/**`, `src/routes/**`, `src/controllers/**`, `src/services/**` | API structure (routes → controllers → services), endpoint patterns, error handling |
| `database.md` | `src/database/**`, `src/models/**`, `prisma/**`, `**/*.sql` | ORM usage, migration rules, query patterns, safety rules |
| `testing.md` | `**/*.test.*`, `**/*.spec.*`, `tests/**` | Test runner, file conventions, what to test, what NOT to test |

**How it works:** You edit these files with your actual conventions. When Claude opens a `.tsx` file, `frontend.md` loads automatically. When Claude is working on backend code, frontend rules stay hidden — zero token cost.

### How to customize rules

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

## Hooks (Automation Scripts)

Hooks are shell scripts that run automatically at specific moments in Claude Code's lifecycle. They don't need to be invoked — they trigger on their own.

| Hook | Triggers On | What It Does |
| :--- | :--- | :--- |
| `generate-context.sh` | Every session start | Injects recent commits, uncommitted changes, branch, active plan into context |
| `resume-plan.sh` | Every session start | Detects task_plan.md and injects it so `/planning` continues across sessions |
| `protect-files.sh` | Every file edit/write | Blocks edits to `.env`, credentials, lock files, `.git/`, private keys |
| `block-dangerous.sh` | Every bash command | Blocks `rm -rf /`, `git push --force main`, `DROP TABLE`, etc. |
| `auto-format.sh` | After every file edit | Auto-runs prettier/black/gofmt/rustfmt on edited files |
| `filter-test-output.sh` | After test/build/lint commands | Filters verbose output (50+ lines) to summary only |
| `commit-reminder.sh` | When Claude stops responding | Reminds about uncommitted changes, suggests `/commit` |
| `auto-setup.sh` | Every session start | Auto-generates `CLAUDE.md` and `.claudeignore` if missing — detects stack, framework, entry points, commands |

### `generate-context.sh`

**How it helps:** Eliminates the "what's the current state?" back-and-forth at the start of every session. Claude instantly knows what you've been working on.

### `protect-files.sh`

**How it helps:** Prevents accidental edits to files that should never be touched by AI.

**Protected by default:**

| Category | Files |
| :--- | :--- |
| Environment | `.env`, `.env.local`, `.env.production` |
| Credentials | `credentials.json`, `*.pem`, `*.key` |
| Lock files | `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` |
| Git | `.git/` directory |

### `filter-test-output.sh`

**How it helps:** Test output can be thousands of lines. This saves massive token waste by only feeding Claude the information it actually needs (what passed, what failed). Full output stays in your terminal.

### How to activate hooks

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

---

## Templates

| Template | Copy To | Purpose |
| :--- | :--- | :--- |
| `CLAUDE.md.template` | `./CLAUDE.md` (project root) | Main project instructions — commands, entry points, flow diagrams, decisions |
| `claudeignore.template` | `./.claudeignore` (project root) | Blocks Claude from reading node_modules, build output, lock files, secrets |

```bash
cp ~/.claude/CLAUDE.md.template ./CLAUDE.md
cp ~/.claude/claudeignore.template ./.claudeignore
```

---

## How It All Works Together

| Stage | What Happens | Token Cost |
| :--- | :--- | :---: |
| **Session Start** | `generate-context.sh` hook runs automatically — Claude sees recent commits, changes, branch | ~100 |
| **Always Loaded** | `CLAUDE.md` loads — Claude sees commands, entry points, flow diagrams, decisions | ~200 |
| **Always Active** | `.claudeignore` blocks node_modules, dist, lock files, .env from being read | 0 |
| **On-Demand** | Rules load based on what files Claude reads (frontend.md, backend.md, etc.) | ~500 when active |
| **Auto Planning** | `planning` skill activates on complex tasks — creates task_plan.md | ~200 |
| **User Invoked** | 21 skills for commits, reviews, PRs, debugging, security, etc. | 0 in main context (forked) |
| **Every Edit** | `protect-files.sh` guards .env, credentials, lock files | ~10 |

**Total always-on overhead: ~300 tokens.** Everything else loads only when needed.

---

## Optimization Strategies

| Strategy | Token Savings | Effort |
| :--- | :---: | :---: |
| Lean CLAUDE.md with entry points | ~30% | Low |
| Path-scoped rules | ~20% | Medium |
| `.claudeignore` | ~15% | Low |
| Exploration skill (forked) | ~25% | Low |
| Session start hooks | ~10% | Medium |
| Code annotations (`@claude` tags) | ~15% | Medium |

---

## Examples

The `examples/` directory includes ready-to-use CLAUDE.md templates for:

| Stack | Framework | Key Features |
| :--- | :--- | :--- |
| **Next.js App** | Next.js 14, App Router | Server Actions, Prisma, Tailwind |
| **Express API** | Express.js | REST, Controllers, Services, JWT Auth |
| **Python FastAPI** | FastAPI | SQLAlchemy, Alembic, Pydantic v2 |
| **Monorepo** | Turborepo | pnpm workspaces, shared packages |

Browse them on [GitHub](https://github.com/huzaifa525/claude-code-optimizer/tree/main/examples).

---

## Contributing

1. Fork the repo
2. Add your stack-specific example in `examples/`
3. Submit a PR

---

## Author

**Huzefa Nalkheda Wala** — AI Product Engineer & Medical AI Researcher

| Platform | Link |
| :--- | :--- |
| Website | [huzefanalkhedawala.in](https://huzefanalkhedawala.in/) |
| GitHub | [@huzaifa525](https://github.com/huzaifa525) |
| LinkedIn | [huzefanalkheda](https://linkedin.com/in/huzefanalkheda) |
| HuggingFace | [huzaifa525](https://huggingface.co/huzaifa525) |
| Medium | [huzefanalkheda](https://huzefanalkheda.medium.com/) |

Currently building enterprise AI systems at CleverFlow (Dubai/India). IIT Ropar AI Program. 45+ production features shipped with 99.5% uptime.

## License

MIT — Huzefa Nalkheda Wala
