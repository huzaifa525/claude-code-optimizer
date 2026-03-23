---
paths:
  - "src/components/**"
  - "src/pages/**"
  - "src/views/**"
  - "src/app/**"
  - "**/*.tsx"
  - "**/*.jsx"
---

# Frontend Rules

## Component Structure
- [Describe your component patterns here]
- [Props interface naming: {Component}Props]
- [State management approach]

## Styling
- [CSS Modules / Tailwind / Styled Components / etc.]
- [Where styles live relative to components]

## Key Components
- [ComponentName] (path) → [purpose, variants, key props]
- [ComponentName] (path) → [purpose, variants, key props]

## Patterns to Follow
- [Look at src/components/Button.tsx for the standard component pattern]
- [All forms use react-hook-form with zod validation]
- [Data fetching uses React Query / SWR / etc.]

## Do NOT
- [Don't use class components]
- [Don't import from barrel files in the same module]

## Skills to Use
- Before adding a new component → use `/smart-edit` to match existing component patterns
- Before touching unfamiliar components → use `/explore-area src/components/`
- For performance issues → use `/perf-check` to detect unnecessary re-renders, large imports
- After changes → use `/review` to check quality

<!-- Rule template by Huzefa Nalkheda Wala | claude-code-optimizer -->
