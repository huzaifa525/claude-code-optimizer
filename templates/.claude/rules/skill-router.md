# Skill Router

When the user asks you to do something, check this list FIRST and invoke the matching skill. Always prefer using a skill over doing the work manually.

## Git & GitHub
- User wants to **commit** / "commit this" / "save changes" → use `/commit`
- User wants to **create a PR** / "make a PR" / "open pull request" → use `/create-pr`
- User wants to **fix an issue** / "fix issue #X" / "fix bug #X" → use `/fix-issue X`
- User wants a **changelog** / "what changed" / "generate changelog" → use `/changelog`

## Code Quality
- User wants a **code review** / "review this" / "check my code" → use `/review`
- User wants a **security check** / "security audit" / "check for vulnerabilities" → use `/security-scan`
- User wants a **performance check** / "check performance" / "find slow code" → use `/perf-check`
- User wants to **check dependencies** / "outdated packages" / "vulnerable deps" → use `/dep-check`

## Development
- User wants to **plan** a feature / "plan this" / "how should I implement" → use `/plan`
- User wants to **add a feature** / "add" / "create" / "implement" → use `/smart-edit`
- User wants to **write tests first** / "TDD" / "test driven" → use `/tdd`
- User wants to **refactor** / "clean up" / "restructure" → use `/refactor`
- User wants to **migrate** / "upgrade" / "move from X to Y" → use `/migrate`
- User wants to **debug** / "fix this error" / "why is this failing" → use `/debug-error`
- User wants **isolated development** / "work in a branch" / "safe workspace" → use `/worktree`
- User wants to **execute a plan with subagents** / "parallel execution" / "dispatch tasks" → use `/subagent-dev`

## Documentation & Context
- User wants **documentation** / "add docs" / "document this" → use `/document`
- User wants to **understand the codebase** / "explain this area" / "how does X work" → use `/explore-area`
- User wants an **onboarding guide** / "new developer guide" → use `/onboard`
- User wants to **set up the project** / "initialize" / "set up claude" → use `/setup`

## Optimization
- User wants to **check token usage** / "how many tokens" / "session health" → use `/token-check`
- User wants to **optimize tokens** / "reduce cost" / "save tokens" → use `/optimize-tokens`
- User wants to **change optimization mode** / "aggressive mode" / "thorough mode" → use `/mode`

## Rules
- If multiple skills match, pick the most specific one
- If no skill matches, work normally without a skill
- Skills with `context: fork` (review, security-scan, perf-check, explore-area, onboard, plan, gen-context) run in isolated subagents — prefer these for read-only analysis

<!-- Rule by Huzefa Nalkheda Wala | github.com/huzaifa525 | claude-code-optimizer -->
