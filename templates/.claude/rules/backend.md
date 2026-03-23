---
paths:
  - "src/api/**"
  - "src/routes/**"
  - "src/controllers/**"
  - "src/services/**"
  - "src/middleware/**"
---

# Backend Rules

## API Structure
- Routes: [src/routes/] → Define endpoints, call controllers
- Controllers: [src/controllers/] → Handle request/response, call services
- Services: [src/services/] → Business logic, call database
- Middleware: [src/middleware/] → Auth, validation, logging

## Adding a New Endpoint
1. Add route in [src/routes/{resource}.ts]
2. Add controller in [src/controllers/{resource}.ts]
3. Add service logic in [src/services/{resource}.ts]
4. Add tests in [src/routes/{resource}.test.ts]
5. Register route in [src/routes/index.ts]

## Patterns
- [All routes use async/await with try-catch]
- [Validation with zod/joi at route level]
- [Auth middleware applied per-route, not globally]
- [Error responses follow format: { error: string, code: string }]

## Do NOT
- [Never put business logic in route handlers]
- [Never access database directly from controllers]
- [Never return raw database errors to client]

## Skills to Use
- Before adding a new endpoint → use `/smart-edit` to follow existing patterns
- Before modifying API logic → use `/explore-area src/api/` to understand the area
- After changes → use `/review` to check quality and security
- For TDD approach → use `/tdd` to write tests first

<!-- Rule template by Huzefa Nalkheda Wala | claude-code-optimizer -->
