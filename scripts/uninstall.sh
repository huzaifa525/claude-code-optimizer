#!/bin/bash
# Claude Code Optimizer — Uninstaller
# By Huzefa Nalkheda Wala | github.com/huzaifa525
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/uninstall.sh | bash

set -e

CLAUDE_HOME="$HOME/.claude"

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo ""
echo -e "${BOLD}  Claude Code Optimizer — Uninstall${RESET}"
echo ""

REMOVED=0

remove_item() {
    local item="$1"
    local label="$2"
    if [ -e "$item" ]; then
        rm -rf "$item"
        echo -e "${GREEN}  - ${RESET}Removed: ${label}"
        REMOVED=$((REMOVED + 1))
    fi
}

# Skills
for skill in explore-area gen-context smart-edit token-check planning commit review create-pr fix-issue tdd debug-error refactor document security-scan perf-check dep-check changelog migrate onboard plan optimize-tokens; do
    remove_item "${CLAUDE_HOME}/skills/${skill}" "Skill: ${skill}"
done

# Rules
remove_item "${CLAUDE_HOME}/rules/frontend.md" "Rule: frontend.md"
remove_item "${CLAUDE_HOME}/rules/backend.md" "Rule: backend.md"
remove_item "${CLAUDE_HOME}/rules/database.md" "Rule: database.md"
remove_item "${CLAUDE_HOME}/rules/testing.md" "Rule: testing.md"

# Hooks
for hook in generate-context.sh protect-files.sh filter-test-output.sh block-dangerous.sh auto-format.sh commit-reminder.sh resume-plan.sh; do
    remove_item "${CLAUDE_HOME}/hooks/${hook}" "Hook: ${hook}"
done

# Templates
remove_item "${CLAUDE_HOME}/CLAUDE.md.template" "CLAUDE.md.template"
remove_item "${CLAUDE_HOME}/claudeignore.template" "claudeignore.template"

echo ""
if [ $REMOVED -eq 0 ]; then
    echo -e "${YELLOW}  Nothing to remove — not installed.${RESET}"
else
    echo -e "${GREEN}  Removed ${REMOVED} items. Clean uninstall complete.${RESET}"
fi
echo ""
