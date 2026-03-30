#!/bin/bash
# memory-inject.sh
# Runs on SessionStart to inject last session's summary for cross-session memory
# Lightweight file-based persistent memory — no database needed
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer

# Windows UTF-8 safety
[ -n "$WINDIR" ] || [ -n "$MSYSTEM" ] && { export LANG=C.UTF-8; export LC_ALL=C.UTF-8; } 2>/dev/null

SESSIONS_DIR="$HOME/.claude/sessions"

# Get project name
if git rev-parse --is-inside-work-tree &>/dev/null; then
    PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || basename "$PWD")
else
    PROJECT_NAME=$(basename "$PWD")
fi

# Find the most recent session file for this project
LAST_SESSION=$(ls -t "$SESSIONS_DIR/${PROJECT_NAME}_"*.md 2>/dev/null | head -1)

if [ -z "$LAST_SESSION" ]; then
    exit 0
fi

# Check if the session file is from a different session (older than 2 minutes)
FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$LAST_SESSION" 2>/dev/null || stat -f %m "$LAST_SESSION" 2>/dev/null || echo "0") ))

# If file is less than 30 seconds old, it's from the current session — skip
if [ "$FILE_AGE" -lt 30 ]; then
    exit 0
fi

echo ""
echo "## Last Session Memory"
echo ""

# Show condensed summary (first 25 lines max to save tokens)
head -25 "$LAST_SESSION"

TOTAL=$(wc -l < "$LAST_SESSION" 2>/dev/null || echo "0")
if [ "$TOTAL" -gt 25 ]; then
    echo ""
    echo "... ($TOTAL total lines — this is a summary of your last session)"
fi

echo ""

exit 0
