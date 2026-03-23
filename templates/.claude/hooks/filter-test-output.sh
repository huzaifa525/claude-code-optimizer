#!/bin/bash
# filter-test-output.sh
# Filters verbose test output to show only failures
# Add to .claude/settings.json under hooks.PostToolUse with matcher "Bash"
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer
#
# Reduces token usage by stripping passing test details from context

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
OUTPUT=$(echo "$INPUT" | jq -r '.stdout // empty' 2>/dev/null)

# Only filter test, build, and lint commands
case "$COMMAND" in
    *"npm test"*|*"jest"*|*"vitest"*|*"pytest"*|*"cargo test"*|*"go test"*)
        ;;
    *"npm run build"*|*"npm run lint"*|*"eslint"*|*"tsc"*|*"ruff check"*)
        ;;
    *)
        exit 0
        ;;
esac

# Count lines — only filter if output is large
LINE_COUNT=$(echo "$OUTPUT" | wc -l)
if [ "$LINE_COUNT" -lt 50 ]; then
    exit 0
fi

# Output a summary instead of full output
echo "Test output was $LINE_COUNT lines. Showing summary only:"
echo ""
echo "$OUTPUT" | grep -E "(FAIL|PASS|ERROR|✓|✗|Tests:|Suites:|failed|passed|error)" | head -30
echo ""
echo "(Full output truncated to save tokens. Run the test command again to see full output.)"
