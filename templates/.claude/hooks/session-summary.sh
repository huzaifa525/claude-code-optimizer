#!/bin/bash
# session-summary.sh
# Runs on Stop to capture what was accomplished in this session
# Writes a summary to ~/.claude/sessions/ for cross-session memory
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer

# Only run in git repos
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    exit 0
fi

SESSIONS_DIR="$HOME/.claude/sessions"
mkdir -p "$SESSIONS_DIR"

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || basename "$PWD")
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
SESSION_FILE="$SESSIONS_DIR/${PROJECT_NAME}_${TIMESTAMP}.md"
ACTIVITY_LOG="${TMPDIR:-/tmp}/cco-session-activity.log"

# Collect session data
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
RECENT_COMMITS=$(git log --oneline -3 --since="1 hour ago" 2>/dev/null)
MODIFIED=$(git diff --name-only 2>/dev/null)
STAGED=$(git diff --cached --name-only 2>/dev/null)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | head -10)

# Count activity from tracker
TOOL_COUNT=0
if [ -f "$ACTIVITY_LOG" ]; then
    TOOL_COUNT=$(wc -l < "$ACTIVITY_LOG" 2>/dev/null || echo "0")
fi

# Only write summary if there was meaningful activity
if [ -z "$RECENT_COMMITS" ] && [ -z "$MODIFIED" ] && [ -z "$STAGED" ] && [ "$TOOL_COUNT" -lt 3 ]; then
    exit 0
fi

# Write session summary
cat > "$SESSION_FILE" << SUMMARY
# Session: $PROJECT_NAME
**Date:** $(date +%Y-%m-%d\ %H:%M)
**Branch:** $BRANCH
**Tool calls:** ~$TOOL_COUNT

## Changes Made
SUMMARY

if [ -n "$RECENT_COMMITS" ]; then
    echo "### Commits This Session" >> "$SESSION_FILE"
    echo "$RECENT_COMMITS" | sed 's/^/- /' >> "$SESSION_FILE"
    echo "" >> "$SESSION_FILE"
fi

if [ -n "$STAGED" ]; then
    echo "### Staged Files" >> "$SESSION_FILE"
    echo "$STAGED" | sed 's/^/- /' >> "$SESSION_FILE"
    echo "" >> "$SESSION_FILE"
fi

if [ -n "$MODIFIED" ]; then
    echo "### Modified Files" >> "$SESSION_FILE"
    echo "$MODIFIED" | sed 's/^/- /' >> "$SESSION_FILE"
    echo "" >> "$SESSION_FILE"
fi

if [ -n "$UNTRACKED" ]; then
    echo "### New Files" >> "$SESSION_FILE"
    echo "$UNTRACKED" | sed 's/^/- /' >> "$SESSION_FILE"
    echo "" >> "$SESSION_FILE"
fi

# Clean up activity log for next session
rm -f "$ACTIVITY_LOG" 2>/dev/null

# Keep only last 20 session files per project to prevent unbounded growth
ls -t "$SESSIONS_DIR/${PROJECT_NAME}_"*.md 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

exit 0
