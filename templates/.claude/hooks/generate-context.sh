#!/bin/bash
# generate-context.sh
# Runs on SessionStart to give Claude fresh project context
# Add to .claude/settings.json under hooks.SessionStart
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer

echo "## Session Context (auto-generated)"
echo ""

# Recent changes
echo "### Recent Commits"
git log --oneline -5 2>/dev/null || echo "Not a git repo"
echo ""

# Uncommitted work
CHANGES=$(git diff --name-only 2>/dev/null)
STAGED=$(git diff --cached --name-only 2>/dev/null)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | head -10)

if [ -n "$CHANGES" ] || [ -n "$STAGED" ] || [ -n "$UNTRACKED" ]; then
    echo "### Uncommitted Work"
    if [ -n "$STAGED" ]; then
        echo "**Staged:**"
        echo "$STAGED" | sed 's/^/- /'
    fi
    if [ -n "$CHANGES" ]; then
        echo "**Modified:**"
        echo "$CHANGES" | sed 's/^/- /'
    fi
    if [ -n "$UNTRACKED" ]; then
        echo "**New files:**"
        echo "$UNTRACKED" | sed 's/^/- /'
    fi
    echo ""
fi

# Current branch
BRANCH=$(git branch --show-current 2>/dev/null)
if [ -n "$BRANCH" ]; then
    echo "### Current Branch: $BRANCH"
    echo ""
fi

# Active plan detection
if [ -f "task_plan.md" ]; then
    echo "### Active Plan: task_plan.md exists — read it to continue previous work"
    echo ""
fi
