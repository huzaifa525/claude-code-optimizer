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

```
Token Usage Comparison:
┌─────────────────────────────────┬──────────────────┐
│ Without Optimizer               │ With Optimizer    │
├─────────────────────────────────┼──────────────────┤
│ ~20-40 tool calls per task      │ ~5-10 tool calls │
│ Full exploration every session  │ Targeted reads   │
│ No awareness of conventions     │ Follows patterns │
│ Re-discovers architecture       │ Knows the map    │
└─────────────────────────────────┴──────────────────┘
```

## What's Included

```
claude-code-optimizer/
├── templates/                    # Copy these into your project
│   ├── CLAUDE.md                 # Main project instructions template
│   ├── .claude/
│   │   ├── rules/                # Path-scoped rules (lazy-loaded)
│   │   │   ├── frontend.md
│   │   │   ├── backend.md
│   │   │   ├── database.md
│   │   │   └── testing.md
│   │   ├── skills/               # Custom skills
│   │   │   ├── explore-area/
│   │   │   │   └── SKILL.md
│   │   │   └── gen-context/
│   │   │       └── SKILL.md
│   │   └── hooks/                # Automation hooks
│   │       ├── generate-context.sh
│   │       └── protect-files.sh
│   └── .claudeignore             # Files Claude should skip
├── examples/                     # Real-world examples
│   ├── nextjs-app/
│   ├── express-api/
│   ├── python-fastapi/
│   └── monorepo/
├── scripts/
│   └── setup.sh                  # Auto-setup script
└── docs/
    ├── strategies.md             # All optimization strategies explained
    ├── token-guide.md            # Understanding token usage
    └── hooks-reference.md        # Hook recipes
```

## Installation

### npm (Windows, Mac, Linux)

```bash
# Install globally (recommended)
npm i -g claude-code-optimizer

# Then run
claude-code-optimizer
# or
cco
```

### npx (no install needed)

```bash
# Run directly
npx claude-code-optimizer

# Or use the short alias
npx cco
```

**Other commands:**

```bash
# Install to current project only
npx claude-code-optimizer --project

# Uninstall
npx claude-code-optimizer --uninstall

# Help
npx claude-code-optimizer --help
```

### curl (Mac, Linux, WSL)

```bash
# Install globally
curl -sL https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/install.sh | bash

# Uninstall
curl -sL https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/uninstall.sh | bash
```

### PowerShell (Windows — no Node.js needed)

```powershell
# Install globally
irm https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/install.ps1 | iex
```

### Manual Setup

```bash
git clone https://github.com/huzaifa525/claude-code-optimizer.git
cd your-project
bash /path/to/claude-code-optimizer/scripts/setup.sh
```

### What Gets Installed

All methods install to `~/.claude/` (global, applies to all projects):

```
~/.claude/
├── skills/                  # 4 custom skills
│   ├── explore-area/        #   Deep codebase exploration
│   ├── gen-context/         #   Generate project context
│   ├── smart-edit/          #   Pattern-aware editing
│   └── token-check/         #   Token usage analysis
├── rules/                   # 4 path-scoped rules
│   ├── frontend.md          #   Frontend conventions
│   ├── backend.md           #   Backend conventions
│   ├── database.md          #   Database rules
│   └── testing.md           #   Testing patterns
├── hooks/                   # 3 automation hooks
│   ├── generate-context.sh  #   Session start context
│   ├── protect-files.sh     #   Block sensitive file edits
│   └── filter-test-output.sh #  Filter verbose test output
├── CLAUDE.md.template       # Copy to project as CLAUDE.md
└── claudeignore.template    # Copy to project as .claudeignore
```

### Post-Install

```bash
# Copy templates to your project
cp ~/.claude/CLAUDE.md.template ./CLAUDE.md
cp ~/.claude/claudeignore.template ./.claudeignore

# Edit with your project details
# Then start Claude Code and try:
#   /explore-area src/
#   /gen-context
#   /token-check
```

## How It Works

### Layer 0 — Always Loaded (~50 lines)

`CLAUDE.md` in your project root. Contains:
- Build/test commands
- Entry point map (5-6 key files)
- Request/data flow diagram
- Key decisions and gotchas

**Token cost: ~200 tokens every turn**

### Layer 1 — Path-Scoped Rules (loaded when relevant)

`.claude/rules/*.md` files with `paths:` frontmatter. Only loaded when Claude reads files matching those paths.

**Token cost: ~500 tokens, only when working in that area**

### Layer 2 — On-Demand Skills

`.claude/skills/` for exploration and context generation. Run in forked subagents so tokens don't pollute your main context.

**Token cost: 0 in main context (runs in subagent)**

### Layer 3 — Hooks (automatic)

Session start hooks that inject fresh git state. Pre-tool hooks that protect sensitive files.

**Token cost: ~100 tokens (hook output only)**

## Optimization Strategies

| Strategy | Token Savings | Effort |
|----------|--------------|--------|
| Lean CLAUDE.md with entry points | ~30% | Low |
| Path-scoped rules | ~20% | Medium |
| `.claudeignore` | ~15% | Low |
| Exploration skill (forked) | ~25% | Low |
| Session start hooks | ~10% | Medium |
| Code annotations (@claude tags) | ~15% | Medium |
| Cap thinking tokens | ~40% | Low |

## Configuration Tips

Add to your Claude Code settings:

```json
{
  "env": {
    "MAX_THINKING_TOKENS": "10000"
  }
}
```

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
