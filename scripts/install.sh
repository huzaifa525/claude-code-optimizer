#!/bin/bash
# Claude Code Optimizer — Global Installer
# By Huzefa Nalkheda Wala | github.com/huzaifa525
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/install.sh | bash
#
# Installs skills, rules, and hooks globally to ~/.claude/

set -e

VERSION="1.0.0"
REPO="huzaifa525/claude-code-optimizer"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
CLAUDE_HOME="$HOME/.claude"

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
DIM="\033[2m"
RESET="\033[0m"

echo ""
echo -e "${BOLD}  Claude Code Optimizer v${VERSION}${RESET}"
echo -e "${DIM}  by Huzefa Nalkheda Wala${RESET}"
echo ""
echo -e "  Installing globally to ${CYAN}~/.claude/${RESET}"
echo ""

# Detect download tool
if command -v curl &>/dev/null; then
    DL="curl -sfL"
elif command -v wget &>/dev/null; then
    DL="wget -qO-"
else
    echo "Error: curl or wget required"
    exit 1
fi

download() {
    local url="$1"
    local dest="$2"
    local dir=$(dirname "$dest")

    mkdir -p "$dir"

    if [ -f "$dest" ]; then
        echo -e "${YELLOW}  ~ ${RESET}$(basename "$dest") (already exists, skipping)"
        return 0
    fi

    if $DL "$url" > "$dest" 2>/dev/null; then
        echo -e "${GREEN}  + ${RESET}$(basename "$dest")"
        return 0
    else
        echo -e "${YELLOW}  ! ${RESET}Failed to download $(basename "$dest")"
        rm -f "$dest"
        return 1
    fi
}

# ── Skills ──
echo "  Skills:"
SKILLS="explore-area gen-context smart-edit token-check planning commit review create-pr fix-issue tdd debug-error refactor document security-scan perf-check dep-check changelog migrate onboard plan optimize-tokens"
for skill in $SKILLS; do
    download \
        "${BASE_URL}/templates/.claude/skills/${skill}/SKILL.md" \
        "${CLAUDE_HOME}/skills/${skill}/SKILL.md"
done

echo ""

# ── Rules ──
echo "  Rules:"
RULES="frontend.md backend.md database.md testing.md token-optimization.md"
for rule in $RULES; do
    download \
        "${BASE_URL}/templates/.claude/rules/${rule}" \
        "${CLAUDE_HOME}/rules/${rule}"
done

echo ""

# ── Hooks ──
echo "  Hooks:"
HOOKS="generate-context.sh protect-files.sh filter-test-output.sh block-dangerous.sh auto-format.sh commit-reminder.sh resume-plan.sh"
for hook in $HOOKS; do
    download \
        "${BASE_URL}/templates/.claude/hooks/${hook}" \
        "${CLAUDE_HOME}/hooks/${hook}"
    chmod +x "${CLAUDE_HOME}/hooks/${hook}" 2>/dev/null || true
done

echo ""

# ── Templates ──
echo "  Templates:"
download \
    "${BASE_URL}/templates/CLAUDE.md" \
    "${CLAUDE_HOME}/CLAUDE.md.template"
download \
    "${BASE_URL}/templates/.claudeignore" \
    "${CLAUDE_HOME}/claudeignore.template"

echo ""
echo -e "${BOLD}${GREEN}  Installation complete!${RESET}"
echo ""
echo "  Installed to ~/.claude/:"
echo -e "    ${CYAN}skills/${RESET}   21 skills (explore-area, commit, review, create-pr, fix-issue, etc.)"
echo -e "    ${CYAN}rules/${RESET}    frontend, backend, database, testing"
echo -e "    ${CYAN}hooks/${RESET}    generate-context, protect-files, filter-test-output"
echo ""
echo "  Next steps:"
echo "    1. Copy template to your project:"
echo -e "       ${DIM}cp ~/.claude/CLAUDE.md.template ./CLAUDE.md${RESET}"
echo -e "       ${DIM}cp ~/.claude/claudeignore.template ./.claudeignore${RESET}"
echo "    2. Edit CLAUDE.md with your project details"
echo "    3. Edit rules in ~/.claude/rules/ for your stack"
echo -e "    4. Start Claude Code and try: ${CYAN}/explore-area src/${RESET}"
echo ""
