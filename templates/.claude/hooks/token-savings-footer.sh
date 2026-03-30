#!/bin/bash
# token-savings-footer.sh
# Shows estimated token savings after Claude stops responding
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer

# Windows UTF-8 safety
[ -n "$WINDIR" ] || [ -n "$MSYSTEM" ] && { export LANG=C.UTF-8; export LC_ALL=C.UTF-8; } 2>/dev/null

ACTIVITY_LOG="${TMPDIR:-/tmp}/cco-session-activity.log"
TRACKER="${TMPDIR:-/tmp}/cco-session-tracker"

# Count tool calls from the activity log (more accurate than counting stops)
if [ -f "$ACTIVITY_LOG" ]; then
    TOOL_CALLS=$(wc -l < "$ACTIVITY_LOG" 2>/dev/null || echo "0")
else
    TOOL_CALLS=0
fi

# Track stop count separately for display frequency
if [ -f "$TRACKER" ]; then
    STOP_COUNT=$(cat "$TRACKER" 2>/dev/null || echo "0")
    STOP_COUNT=$((STOP_COUNT + 1))
else
    STOP_COUNT=1
fi
echo "$STOP_COUNT" > "$TRACKER"

# Show footer every 5th stop (not every single response)
if [ $((STOP_COUNT % 5)) -ne 0 ]; then
    exit 0
fi

# Estimate savings based on tool call reduction
# Without optimizer: ~3000 tokens/call average
# With optimizer: ~2000 tokens/call average (targeted reads, less exploration)
# Savings per tool call: ~1000 tokens
# Plus: ~5000 tokens saved per session from thinking cap + compaction
SAVED_TOKENS=$(( (TOOL_CALLS * 1000) + 5000 ))

if [ "$SAVED_TOKENS" -gt 1000000 ]; then
    DISPLAY="$(echo "scale=1; $SAVED_TOKENS / 1000000" | bc 2>/dev/null || echo "$((SAVED_TOKENS / 1000000))")M"
elif [ "$SAVED_TOKENS" -gt 1000 ]; then
    DISPLAY="$(echo "scale=1; $SAVED_TOKENS / 1000" | bc 2>/dev/null || echo "$((SAVED_TOKENS / 1000))")K"
else
    DISPLAY="$SAVED_TOKENS"
fi

echo ""
echo "---"
echo "Optimized by **Claude Code Optimizer** | ~${DISPLAY} tokens saved this session | [github.com/huzaifa525/claude-code-optimizer](https://github.com/huzaifa525/claude-code-optimizer)"

exit 0
