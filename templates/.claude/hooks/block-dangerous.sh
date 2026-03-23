#!/bin/bash
# block-dangerous.sh
# Blocks dangerous bash commands that could cause irreversible damage
# Add to .claude/settings.json under hooks.PreToolUse with matcher "Bash"
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer
#
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$CMD" ]; then
    exit 0
fi

# Dangerous patterns to block
BLOCKED_PATTERNS=(
    "rm -rf /"
    "rm -rf ~"
    "rm -rf \*"
    "rm -rf ."
    "git push --force origin main"
    "git push --force origin master"
    "git push -f origin main"
    "git push -f origin master"
    "git reset --hard"
    "git clean -fd"
    "git checkout -- ."
    "DROP TABLE"
    "DROP DATABASE"
    "TRUNCATE TABLE"
    "DELETE FROM .* WHERE 1"
    "> /dev/sda"
    "mkfs"
    "dd if="
    ":(){:|:&};:"
    "chmod -R 777 /"
    "curl.*|.*bash"
    "wget.*|.*bash"
    "npm publish"
    "pip upload"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$CMD" | grep -qiE "$pattern"; then
        echo "BLOCKED: Command matches dangerous pattern '$pattern'. If you really need to run this, ask the user to run it manually." >&2
        exit 2
    fi
done

exit 0
