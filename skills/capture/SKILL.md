---
name: capture
description: Quick capture to the Obsidian vault. Routes content to daily note or Inbox based on type. Use when the user says "capture", "note this", "jot down", "quick note", "add to inbox", or "meeting note".
---

# Capture

Refer to `~/.claude/skills/obsidian-core/SKILL.md` for CLI patterns, preflight checks, and error handling.

## Workflow

### 1. Accept Content

Accept whatever the user wants to capture. No required format.

### 2. Classify Type

| Type | Signals |
|------|---------|
| Task | "todo", "remember to", "need to", action verb + object |
| Meeting note | "meeting", "standup", "sync", "call with", "sprint planning", "1:1" |
| Idea | "idea", "what if", "brainstorm", speculative language |
| Link/Resource | URL present, "article", "read this", "resource", "link" |
| Quick note | Anything else |

### 3. Route to Destination

**Task** — append to today's daily note:

```bash
obsidian daily:append content="- [ ] <task>" 2>/dev/null
```

**Meeting note** — create in Inbox with meeting structure:

```bash
obsidian create path="Inbox/YYYY-MM-DD Meeting Name.md" content="---\ntype: meeting\ntags: [meeting]\ndate: YYYY-MM-DD\n---\n\n# Meeting Name\n\n## Attendees\n- \n\n## Key Points\n- \n\n## Action Items\n- [ ] \n\n## Decisions Made\n- \n\n## Follow-up\n- \n"
```

**Idea** — append to today's daily note:

```bash
obsidian daily:append content="\n**Idea**: <content>" 2>/dev/null
```

**Link/Resource** — append to today's daily note:

```bash
obsidian daily:append content="- [<title>](<url>) - <brief note>" 2>/dev/null
```

**Quick note** — create in Inbox:

```bash
obsidian create path="Inbox/<title>.md" content="<content>"
```

### 4. Confirm

Tell the user what was captured and where:

* "Task added to today's daily note"
* "Meeting note created at Inbox/YYYY-MM-DD Sprint Planning.md"
* "Idea added to today's daily note"

## Design Principles

* Default to Inbox or daily note; never guess a deeper folder
* Minimal questions: infer type from content, ask only if genuinely ambiguous
* If no daily note exists, `daily:append` will create it automatically
