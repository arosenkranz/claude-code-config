---
name: js-codereview
description: Perform comprehensive JavaScript and TypeScript code review checking for logging, error handling, TypeScript strictness, React/hooks correctness, performance, security, and architecture patterns. Checks on .js, .ts, .jsx, .tsx, .astro, and .vue files.
disable-model-invocation: true
---

# Code Review Task

Perform comprehensive code review. Be thorough but concise.

## Check For:

**Logging** - No console.log statements, uses proper logger with context
**Error Handling** - Try-catch for async, centralized handlers, helpful messages
**TypeScript** - No `any` types, proper interfaces, no @ts-ignore
**Production Readiness** - No debug statements, no TODOs, no hardcoded secrets
**React/Hooks** - Effects have cleanup, dependencies complete, no infinite loops
**Performance** - No unnecessary re-renders, expensive calcs memoized
**Security** - Auth checked, inputs validated, RLS policies in place
**Architecture** - Follows existing patterns, code in correct directory

## Output Format

### Looks Good
- [Item 1]
- [Item 2]

### Issues Found
- **[Severity]** [File:line] - [Issue description]
  - Fix: [Suggested fix]

### Summary
- Files reviewed: X
- Critical issues: X
- Warnings: X

## Severity Levels
- **CRITICAL** - Security, data loss, crashes
- **HIGH** - Bugs, performance issues, bad UX
- **MEDIUM** - Code quality, maintainability
- **LOW** - Style, minor improvements
