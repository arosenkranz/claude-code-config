---
name: harvest-memory
description: Scan CLAUDE.md and extract architectural decisions, constraints, tech stack, and key patterns into the memory system. Use when starting a new project, after updating CLAUDE.md, or to sync project docs into cross-session memory.
allowed-tools: Bash, Read, Glob, Grep
---

# Harvest Memory

Read CLAUDE.md with full comprehension, classify sections intelligently, and store high-value entries in the memory system using `mcp__memory__*` tools.

## Usage

- `/harvest-memory` — harvest CLAUDE.md in current working directory
- `/harvest-memory --all` — harvest CLAUDE.md from every project under `~/Code/`

## Steps

1. **Locate CLAUDE.md**: Check `./CLAUDE.md`, then `./.claude/CLAUDE.md`. If `--all` flag is provided, glob `~/Code/*/CLAUDE.md` and process each project in turn.

2. **Derive scope**: Use `project:<basename-of-cwd>` as the scope (e.g., `project:kranz-tv`).

3. **Parse sections**: Split the file by `##` headings. For each section, classify as **high-value** or **skip**:

   | Section heading contains | Entity suffix | entity_type | Skip? |
   |--------------------------|---------------|-------------|-------|
   | Architecture             | architecture  | decision    | No    |
   | Scheduling               | scheduling    | decision    | No    |
   | Data flow                | data-flow     | decision    | No    |
   | Key hooks                | key-hooks     | decision    | No    |
   | Routing                  | routing       | decision    | No    |
   | Channel import           | channel-import| decision    | No    |
   | Constraints              | constraints   | decision    | No    |
   | Key Patterns             | key-patterns  | decision    | No    |
   | Tech Stack               | tech-stack    | project     | No    |
   | Observability            | observability | service     | No    |
   | Commands                 | —             | —           | Yes   |
   | Environment Variables    | —             | —           | Yes   |
   | Testing                  | —             | —           | Yes   |
   | TypeScript               | —             | —           | Yes   |

4. **Check existing entries**: For each high-value section, call `mcp__memory__memory_get_entity` with `name=<project>-<suffix>` and `scope=project:<project>`. Compare stored content to current section content.

5. **Store or update**:
   - If no existing entry → call `mcp__memory__memory_store` with `confidence=0.95` and `source='skill:harvest-memory'`
   - If content has changed → call `mcp__memory__memory_store` to update (the tool upserts)
   - If content is identical → skip (note as "unchanged" in output)

6. **Output results table**:

   ```
   | Entity Name              | Type     | Action           | Preview (60 chars)                  |
   |--------------------------|----------|------------------|-------------------------------------|
   | kranz-tv-architecture    | decision | created          | KranzTV is a retro cable TV experi… |
   | kranz-tv-scheduling      | decision | updated          | getSchedulePosition(channel, times… |
   | kranz-tv-tech-stack      | project  | unchanged        | —                                   |
   ```

## Key Differences from Hook

The SessionEnd hook harvests sections via raw `awk` text extraction into SQLite directly. This skill uses Claude's full comprehension to:
- Understand context and nuance in each section
- Write cleaner, more useful summaries if the raw text is too long
- Cross-reference sections for relationships
- Detect implicit constraints not marked with a specific heading

Use source tag `skill:harvest-memory` so hook entries (tagged `hook:harvest`) coexist without conflict.

## Notes

- Trim section content to 1000 chars max before storing
- Ignore frontmatter and top-level `#` heading
- If CLAUDE.md is missing entirely, report clearly and exit
- For `--all` mode, process each project directory and report a combined results table
