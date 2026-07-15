# Coding Style

## Core Preferences

- **Immutability** — create new objects/arrays instead of mutating (spread, `map`/`filter`, not in-place assignment).
- **Many small files over few large ones** — high cohesion, low coupling. 200-400 lines typical, 800 max. Organize by feature/domain, not by type.
- **Validate external input** at the boundary (zod or equivalent); trust internal data.
- **Handle errors where you can add context** — catch, log with context, rethrow a user-meaningful error. Don't swallow.

## Quality Checklist

Before marking work complete:
- [ ] Functions small (<50 lines), no deep nesting (>4 levels)
- [ ] No leftover console.log / debug statements
- [ ] No hardcoded values or secrets
- [ ] No mutation of shared state
