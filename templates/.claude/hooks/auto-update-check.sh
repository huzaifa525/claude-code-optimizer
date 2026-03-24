#!/bin/bash
# auto-update-check.sh
# Checks for new version on session start, notifies if outdated
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer

# Only check once per day (cache in /tmp)
CACHE_FILE="/tmp/cco-update-check"
NOW=$(date +%s)

if [ -f "$CACHE_FILE" ]; then
    LAST_CHECK=$(cat "$CACHE_FILE" 2>/dev/null || echo "0")
    DIFF=$((NOW - LAST_CHECK))
    # Skip if checked within last 24 hours
    if [ "$DIFF" -lt 86400 ]; then
        exit 0
    fi
fi

# Save current check time
echo "$NOW" > "$CACHE_FILE"

# Get installed version
if command -v node &>/dev/null; then
    INSTALLED=$(node -e "try{console.log(require('claude-code-optimizer/package.json').version)}catch(e){console.log('')}" 2>/dev/null)
fi

if [ -z "$INSTALLED" ]; then
    # Try npm list
    INSTALLED=$(npm list -g claude-code-optimizer --depth=0 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
fi

if [ -z "$INSTALLED" ]; then
    exit 0
fi

# Get latest version from npm (timeout 3 seconds, don't block session)
LATEST=$(timeout 3 npm view claude-code-optimizer version 2>/dev/null)

if [ -z "$LATEST" ]; then
    exit 0
fi

# Compare
if [ "$INSTALLED" != "$LATEST" ]; then
    echo ""
    echo "## Claude Code Optimizer Update Available"
    echo ""
    echo "Installed: v${INSTALLED} → Latest: v${LATEST}"
    echo "Run: \`npm i -g claude-code-optimizer@latest\`"
    echo ""
fi

exit 0
