#!/bin/bash
# Claude Code Optimizer — Global Installer
# By Huzefa Nalkheda Wala | github.com/huzaifa525
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/install.sh | bash
#
# Installs skills, rules, and hooks globally to ~/.claude/
# Resilient: tries raw.githubusercontent.com → GitHub API → cdn.jsdelivr.net

set -e

VERSION="4.0.2"
REPO="huzaifa525/claude-code-optimizer"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
FALLBACK_URL="https://cdn.jsdelivr.net/gh/${REPO}@${BRANCH}"
CLAUDE_HOME="$HOME/.claude"
VERSION_FILE="$CLAUDE_HOME/.cco-version"

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
MAGENTA="\033[35m"
DIM="\033[2m"
RESET="\033[0m"

# Windows UTF-8 safety
if [ -n "$WINDIR" ] || [ -n "$MSYSTEM" ]; then
    export LANG=C.UTF-8 2>/dev/null || true
    export LC_ALL=C.UTF-8 2>/dev/null || true
fi

echo ""
echo -e "${BOLD}  Claude Code Optimizer v${VERSION}${RESET}"
echo -e "${DIM}  by Huzefa Nalkheda Wala${RESET}"
echo ""

# Detect upgrade
if [ -f "$VERSION_FILE" ]; then
    INSTALLED=$(cat "$VERSION_FILE" 2>/dev/null)
    if [ "$INSTALLED" = "$VERSION" ]; then
        echo -e "  v${VERSION} already installed — checking for missing files"
    else
        echo -e "  ${MAGENTA}Upgrading${RESET} v${INSTALLED} → v${VERSION}"
    fi
    FORCE=true
elif [ -d "$CLAUDE_HOME/skills" ]; then
    echo -e "  ${MAGENTA}Upgrading${RESET} (pre-v4) → v${VERSION}"
    FORCE=true
else
    echo -e "  Installing globally to ${CYAN}~/.claude/${RESET}"
    FORCE=false
fi
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

# Resilient download with fallback chain
download() {
    local path="$1"
    local dest="$2"
    local dir=$(dirname "$dest")
    local filename=$(basename "$dest")

    mkdir -p "$dir"

    # Skip existing files unless upgrading
    if [ -f "$dest" ] && [ "$FORCE" = "false" ]; then
        echo -e "${YELLOW}  ~ ${RESET}${filename}"
        return 0
    fi

    # Try primary URL
    if $DL "${BASE_URL}/${path}" > "$dest" 2>/dev/null && [ -s "$dest" ]; then
        if [ "$FORCE" = "true" ] && [ -f "$dest" ]; then
            echo -e "${MAGENTA}  ↑ ${RESET}${filename}"
        else
            echo -e "${GREEN}  + ${RESET}${filename}"
        fi
        return 0
    fi

    # Fallback: jsdelivr CDN
    if $DL "${FALLBACK_URL}/${path}" > "$dest" 2>/dev/null && [ -s "$dest" ]; then
        if [ "$FORCE" = "true" ]; then
            echo -e "${MAGENTA}  ↑ ${RESET}${filename} (via CDN)"
        else
            echo -e "${GREEN}  + ${RESET}${filename} (via CDN)"
        fi
        return 0
    fi

    echo -e "${YELLOW}  ! ${RESET}Failed: ${filename}"
    rm -f "$dest"
    return 1
}

# ── Skills (25) ──
echo "  Skills:"
SKILLS="explore-area gen-context smart-edit token-check planning commit review create-pr fix-issue tdd debug-error refactor document security-scan perf-check dep-check changelog migrate onboard plan optimize-tokens setup worktree subagent-dev mode"
for skill in $SKILLS; do
    download \
        "templates/.claude/skills/${skill}/SKILL.md" \
        "${CLAUDE_HOME}/skills/${skill}/SKILL.md"
done

echo ""

# ── Rules (6) ──
echo "  Rules:"
RULES="frontend.md backend.md database.md testing.md token-optimization.md skill-router.md"
for rule in $RULES; do
    download \
        "templates/.claude/rules/${rule}" \
        "${CLAUDE_HOME}/rules/${rule}"
done

echo ""

# ── Hooks (13) ──
echo "  Hooks:"
HOOKS="generate-context.sh protect-files.sh filter-test-output.sh block-dangerous.sh auto-format.sh commit-reminder.sh resume-plan.sh auto-setup.sh auto-update-check.sh token-savings-footer.sh session-summary.sh track-activity.sh memory-inject.sh"
for hook in $HOOKS; do
    download \
        "templates/.claude/hooks/${hook}" \
        "${CLAUDE_HOME}/hooks/${hook}"
    chmod +x "${CLAUDE_HOME}/hooks/${hook}" 2>/dev/null || true
done

echo ""

# ── Settings ──
echo "  Config:"
if [ ! -f "${CLAUDE_HOME}/settings.json" ] || [ "$FORCE" = "true" ]; then
    download \
        "templates/.claude/settings.json" \
        "${CLAUDE_HOME}/settings.json"
else
    echo -e "${YELLOW}  ~ ${RESET}settings.json (up to date)"
fi

echo ""

# ── Templates ──
echo "  Templates:"
download "templates/CLAUDE.md" "${CLAUDE_HOME}/CLAUDE.md.template"
download "templates/.claudeignore" "${CLAUDE_HOME}/claudeignore.template"

# ── Sessions directory ──
mkdir -p "${CLAUDE_HOME}/sessions"

# ── Save version ──
echo "$VERSION" > "$VERSION_FILE"

echo ""
echo -e "${BOLD}${GREEN}  Installation complete!${RESET}"
echo ""
echo "  Installed to ~/.claude/:"
echo -e "    ${CYAN}skills/${RESET}     25 skills"
echo -e "    ${CYAN}rules/${RESET}      6 rules"
echo -e "    ${CYAN}hooks/${RESET}      13 hooks"
echo -e "    ${CYAN}sessions/${RESET}   persistent memory"
echo ""
echo "  Next steps:"
echo "    1. Open Claude Code in any repo"
echo -e "    2. Type ${CYAN}/setup${RESET} to auto-generate CLAUDE.md"
echo "    3. Everything else works automatically"
echo ""
