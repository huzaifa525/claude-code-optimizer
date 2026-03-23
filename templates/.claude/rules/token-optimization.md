# Token Optimization Rules

These rules apply at all times to minimize token waste.

## Thinking Tokens
- Extended thinking is the #1 token cost — capped at 10000 via settings
- For simple edits, formatting, renaming — thinking should be minimal
- Only complex architecture, debugging, or multi-file changes need deep thinking

## Model Selection
- Use **Sonnet** for: file edits, formatting, simple bug fixes, test writing, documentation, git operations
- Use **Opus** for: complex debugging, architecture decisions, multi-file refactoring, security analysis
- Use **Haiku** for: subagents doing simple tasks (grep, read, summarize)
- When in doubt, start with Sonnet — switch to Opus only if Sonnet struggles

## Smart Compaction
- After reading 10+ files → `/compact` to free context
- After exploration phase (before starting edits) → `/compact`
- After running tests with verbose output → `/compact`
- After debugging session → `/compact` before implementing fix
- Add focus hint: `/compact Focus on auth module changes only`
- NEVER let context grow past ~150K tokens without compacting

## Subagent Strategy
- Use `context: fork` for ANY exploration or research task
- Use `context: fork` for code review, security scan, performance check
- NEVER explore a large directory in main context — always fork
- Subagent results return as a summary, raw file contents stay isolated
- When delegating to subagents, prefer Explore agent for read-only, Plan agent for architecture

## Duplicate Read Prevention
- Before reading a file, check if you already read it in this session
- If you need to re-check a file after editing, read ONLY the changed section using offset/limit
- After editing a file, do NOT re-read the whole file to verify — trust the Edit tool's output
- If you need content from a file you already read, use your memory of it instead of re-reading

## Web Search & Fetching
- Use WebSearch tool for finding information online
- Use WebFetch tool for reading web page content
- If WebFetch gets blocked (403/Cloudflare), fall back to curl with browser headers
- NEVER dump entire web pages into context — extract only relevant sections
- Limit web search results to top 3-5, don't fetch all
- For large pages, fetch and read only the sections you need

## File Reading
- ALWAYS use `offset` and `limit` when you know which part of a file you need
- DON'T read entire large files — read just the relevant section
- DON'T re-read files you already read in this session
- Use Grep to find the right lines first, then Read with offset

## Tool Calls
- Use Glob/Grep BEFORE Read — narrow down targets first
- Combine independent searches into parallel tool calls
- Prefer specific file paths over broad glob patterns
- Use `head_limit` on Grep to cap results

## Context Management
- After heavy exploration, use `/compact` to free context
- One task per session — `/clear` between unrelated tasks
- Forked subagents (`context: fork`) for exploration — keeps main context clean

## Command Output
- Pipe verbose commands through `head` or `tail` to limit output
- Use `--quiet` or `--silent` flags when available
- Avoid `git log` without `-n` limit
- Avoid `npm ls` or `pip list` without filtering

<!-- Rule by Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer -->
