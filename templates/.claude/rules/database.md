---
paths:
  - "src/database/**"
  - "src/models/**"
  - "src/migrations/**"
  - "prisma/**"
  - "**/*.sql"
---

# Database Rules

## ORM/Query Layer
- [Prisma / Sequelize / TypeORM / Drizzle / raw SQL]
- Schema: [prisma/schema.prisma | src/models/]
- Migrations: [prisma/migrations/ | src/migrations/]

## Migration Rules
- NEVER edit existing migrations
- Always create new migrations for changes
- Run: [npx prisma migrate dev | npm run migrate]
- Test migrations: [npm run migrate:test]

## Models
- [User] → [src/models/user.ts] — core user model
- [Post] → [src/models/post.ts] — content model
- [Add your models here]

## Query Patterns
- [Use transactions for multi-table writes]
- [Always paginate list queries]
- [Soft delete preferred over hard delete]
- [Index foreign keys and frequently queried columns]

## Do NOT
- [Never use raw SQL unless ORM can't handle it]
- [Never store passwords in plain text]
- [Never return full user objects with password hashes]

## Skills to Use
- Before modifying schema → use `/explore-area src/models/` or `/explore-area prisma/`
- For new migrations → use `/smart-edit` to follow existing migration patterns
- For query performance → use `/perf-check` to detect N+1 queries, missing indexes
- For security → use `/security-scan` to check for data exposure

<!-- Rule template by Huzefa Nalkheda Wala | claude-code-optimizer -->
