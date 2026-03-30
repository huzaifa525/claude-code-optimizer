#!/bin/bash
# commit-reminder.sh
# Reminds about uncommitted changes when Claude stops responding
# Add to .claude/settings.json under hooks.Stop
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer

# Windows UTF-8 safety
[ -n "$WINDIR" ] || [ -n "$MSYSTEM" ] && { export LANG=C.UTF-8; export LC_ALL=C.UTF-8; } 2>/dev/null

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    exit 0
fi

STAGED=$(git diff --cached --name-only 2>/dev/null)
MODIFIED=$(git diff --name-only 2>/dev/null)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | head -5)

# Count total uncommitted files
COUNT=0
[ -n "$STAGED" ] && COUNT=$((COUNT + $(echo "$STAGED" | wc -l)))
[ -n "$MODIFIED" ] && COUNT=$((COUNT + $(echo "$MODIFIED" | wc -l)))
[ -n "$UNTRACKED" ] && COUNT=$((COUNT + $(echo "$UNTRACKED" | wc -l)))

if [ "$COUNT" -gt 0 ]; then
    echo ""
    echo "Reminder: $COUNT uncommitted file(s). Use /commit to commit your changes."
fi

exit 0
