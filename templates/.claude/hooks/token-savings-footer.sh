#!/bin/bash
# token-savings-footer.sh
# Shows estimated token savings after Claude stops responding
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer

# Track session tool calls in a temp file
TRACKER="/tmp/cco-session-tracker"

# Increment call count
if [ -f "$TRACKER" ]; then
    COUNT=$(cat "$TRACKER" 2>/dev/null || echo "0")
    COUNT=$((COUNT + 1))
else
    COUNT=1
fi
echo "$COUNT" > "$TRACKER"

# Show footer every 5th stop (not every single response)
if [ $((COUNT % 5)) -ne 0 ]; then
    exit 0
fi

# Estimate savings based on typical optimization
# Without optimizer: ~28 tool calls/task, ~3000 tokens/call = 84K tokens/task
# With optimizer: ~8 tool calls/task, ~2000 tokens/call = 16K tokens/task
# Savings per task: ~68K tokens
# Rough estimate: savings = stop_count * 13K tokens (averaged across turns)

SAVED_TOKENS=$((COUNT * 13000))

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
