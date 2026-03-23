---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "tests/**"
  - "__tests__/**"
---

# Testing Rules

## Framework
- Test runner: [Jest / Vitest / Pytest / etc.]
- Run all: [npm test]
- Run single: [npm test -- path/to/file.test.ts]
- Coverage: [npm run test:coverage]

## File Conventions
- Tests colocated: [src/foo.ts → src/foo.test.ts]
- OR tests mirrored: [src/foo.ts → tests/foo.test.ts]
- Naming: [*.test.ts | *.spec.ts]

## Patterns
- [Use describe/it blocks, not test()]
- [One describe per function/component]
- [Arrange-Act-Assert pattern]
- [Use factories/fixtures, not inline test data]

## What to Test
- API routes: [HTTP status, response shape, error cases]
- Services: [Business logic, edge cases]
- Components: [Rendering, user interactions, a11y]

## What NOT to Test
- [Don't test framework internals]
- [Don't mock the database — use test database]
- [Don't test private methods directly]

## Test Database
- [How to set up test DB]
- [How to seed test data]
- [How to clean up after tests]

## Skills to Use
- For new features → use `/tdd` for strict test-driven development
- Before editing tests → use `/explore-area tests/` to understand test patterns
- For debugging test failures → use `/debug-error` with the error message
- After refactoring → use `/refactor` which auto-runs tests before and after

<!-- Rule template by Huzefa Nalkheda Wala | claude-code-optimizer -->
