#!/bin/bash
# auto-format.sh
# Auto-formats files after Claude edits them
# Add to .claude/settings.json under hooks.PostToolUse with matcher "Edit|Write"
# By Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer
#
# Detects the formatter from project config and runs it on the edited file

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Try project-level formatters first, then global

# JavaScript / TypeScript / CSS / HTML / JSON / Markdown
case "$EXT" in
    js|jsx|ts|tsx|css|scss|html|json|md|yaml|yml)
        if [ -f "node_modules/.bin/prettier" ]; then
            node_modules/.bin/prettier --write "$FILE_PATH" 2>/dev/null
        elif command -v prettier &>/dev/null; then
            prettier --write "$FILE_PATH" 2>/dev/null
        elif [ -f "node_modules/.bin/biome" ]; then
            node_modules/.bin/biome format --write "$FILE_PATH" 2>/dev/null
        fi
        ;;
    # Python
    py)
        if command -v ruff &>/dev/null; then
            ruff format "$FILE_PATH" 2>/dev/null
        elif command -v black &>/dev/null; then
            black --quiet "$FILE_PATH" 2>/dev/null
        fi
        ;;
    # Go
    go)
        if command -v gofmt &>/dev/null; then
            gofmt -w "$FILE_PATH" 2>/dev/null
        fi
        ;;
    # Rust
    rs)
        if command -v rustfmt &>/dev/null; then
            rustfmt "$FILE_PATH" 2>/dev/null
        fi
        ;;
esac

# Always exit 0 — formatting failure shouldn't block the edit
exit 0
