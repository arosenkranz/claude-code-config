# Memory System

SQLite-backed knowledge graph at `~/.claude/memory.db`. Use these tools proactively.

## When to STORE (`memory_store`)
- Architecture decisions and why they were made
- Preferences discovered during a session (tools, patterns, approaches)
- Project context: tech stack, active work, blockers
- Learnings from debugging or fixing bugs
- Session summaries at natural stopping points

## When to QUERY (`memory_query`, `memory_get_entity`)
- Session start — check for prior context on the current project
- Before making architectural decisions — see what was decided before
- When user says "we've done this before" or context seems missing
- Before recommending tools or approaches — check preferences

## Entity Types
- `project` — codebases, repos, active work
- `decision` — architectural choices with rationale
- `service` — tools, APIs, external services
- `preference` — user preferences and workflow choices
- `instinct` — learned patterns from the learning system
- `learning` — insights from sessions or debugging
- `person` — collaborators, stakeholders

## Scoping
- `global` — applies across all projects
- `project:<name>` — specific to one project (e.g., `project:claude-memory`)
- `homelab` — Raspberry Pi / self-hosting context

## Example Usage
```
memory_store(name="claude-memory", entity_type="project", scope="project:claude-memory",
  content="SQLite MCP server for cross-session memory. Built Mar 2026.", confidence=1.0)

memory_query(query="authentication decision", scope="project:my-app")

memory_briefing(scope="project:claude-memory")  # session-start context dump
```
