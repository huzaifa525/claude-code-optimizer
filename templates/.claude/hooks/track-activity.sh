#!/bin/bash
# track-activity.sh
# Lightweight PostToolUse hook that logs tool usage for session awareness
# Fires on every tool call — must be FAST (no heavy parsing)
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer

ACTIVITY_LOG="${TMPDIR:-/tmp}/cco-session-activity.log"

# Append timestamp — the matcher already tells us the tool type
# We just need to count activity and track timing
echo "$(date +%H:%M:%S)" >> "$ACTIVITY_LOG"

exit 0
