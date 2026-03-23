#!/bin/bash
# resume-plan.sh
# Detects task_plan.md on session start and injects it into context
# Add to .claude/settings.json under hooks.SessionStart
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer
#
# Works with the /planning skill to persist progress across sessions

PLAN_FILE="task_plan.md"

if [ -f "$PLAN_FILE" ]; then
    echo ""
    echo "## Active Plan Detected"
    echo ""
    echo "Found \`task_plan.md\` — you have an in-progress plan from a previous session."
    echo "Read it and continue from the CURRENT step."
    echo ""
    cat "$PLAN_FILE"
    echo ""
fi

exit 0
