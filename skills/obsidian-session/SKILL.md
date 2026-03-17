---
name: obsidian-session
description: Track and document Claude Code sessions in the Obsidian vault. Creates or updates session notes with timestamps, learnings, code snippets, and file references. Use when asked to "document session", "write session notes", "save what we did", "log this session", "session summary", or "track this work".
---

# Obsidian Session Tracking

Refer to `~/.claude/skills/obsidian-core/SKILL.md` for CLI patterns, preflight checks, and error handling.

## Session File Naming

Session files use kebab-case in the `Sessions/` folder:

```
Sessions/YYYY-MM-DD-brief-description.md
```

Example: `Sessions/2026-03-02-docker-compose-setup.md`

---

## Modes

1. **Full Session Lifecycle** - Start, update, and end sessions with structured tracking
1. **Quick Summary** - Review the current conversation and write a single session entry

---

## Full Session Lifecycle

### Actions

* `start` - Begin a new session with timestamp and objective
* `update` - Add content to current session
* `end` - Finalize session with summary and learnings
* `link` - Cross-reference with projects or daily notes

### Process

1. **Check if session file exists**:

   ```bash
   obsidian read path="Sessions/YYYY-MM-DD-brief-description.md" 2>/dev/null
   ```

   Empty output = file does not exist yet.

1. **Create new session file** (if it doesn't exist):

   ```bash
   obsidian create path="Sessions/YYYY-MM-DD-brief-description.md" content="---\ntype: session\nstatus: in-progress\ndate: YYYY-MM-DD\n---\n\n# Session Title\n"
   ```

1. **Append session content** (if it already exists):

   ```bash
   obsidian append path="Sessions/YYYY-MM-DD-brief-description.md" content="## HH:MM - Session Title\n..."
   ```

1. **Set metadata on finalize**:

   ```bash
   obsidian property:set path="Sessions/YYYY-MM-DD-brief-description.md" name="status" value="complete"
   ```

### Session Format

```markdown
## HH:MM - [Session Title]

### Objective
[Brief description of session goal]

### Problems Solved
- [Problem 1 and solution]

### Code Snippets
\```language
[Relevant code]
\```

### Commands Used
\```bash
[Commands executed]
\```

### Key Learnings
- [Learning point 1]

### Files Modified
- [File path 1]

### Gotchas/Notes
- [Important discovery or warning]
```

---

## Quick Summary

Review the current conversation and write a concise session note.

### Quick Summary Format

```markdown
## HH:MM - Brief Session Title
- **Objective**: What we accomplished
- **Problem**: Issues encountered or tasks completed
- **Solution**: Approach taken
- **Key Learning**: Important discoveries or patterns
- **Files**: List of created/modified files with full paths
```

### Steps

1. Derive a kebab-case filename from the session topic
1. Check if `Sessions/YYYY-MM-DD-<topic>.md` exists using `obsidian read`
1. Create (first entry) or append (subsequent entries) using CLI
1. Set `status: complete` via `obsidian property:set`
