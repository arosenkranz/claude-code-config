---
name: vault-search
description: Advanced Obsidian vault search by tag, text, backlinks, orphans, or dead ends. Use when the user says "find notes tagged", "search by property", "what links to", "show backlinks", or "vault search".
---

# Vault Search

Refer to `~/.claude/skills/obsidian-core/SKILL.md` for CLI patterns, preflight checks, and error handling.

## Intent Routing

Parse the user's request and route to the appropriate CLI command:

### By Tag

Triggers: "find notes tagged X", "notes with tag X", "#X notes"

```bash
obsidian tag name="<tag>" verbose 2>/dev/null
```

### By Text (Vault-Wide)

Triggers: "search for X", "find notes about X", "where do I have notes on X"

```bash
obsidian search:context query="<text>" format=json limit=20 2>/dev/null
```

### By Text + Folder

Triggers: "search for X in Sessions", "find X in Datadog folder"

```bash
obsidian search:context query="<text>" path="<folder>" format=json limit=20 2>/dev/null
```

### By Backlinks

Triggers: "what links to X", "show backlinks for X", "which notes reference X"

Use `path=` when the user provides a file path:

```bash
obsidian backlinks path="<note-path>" counts 2>/dev/null
```

Use `file=` when the user provides a note name (fuzzy match):

```bash
obsidian backlinks file="<note name>" counts 2>/dev/null
```

### Orphaned Notes

Triggers: "show orphans", "notes with no links", "disconnected notes"

```bash
obsidian orphans 2>/dev/null
```

### Dead-End Notes

Triggers: "show dead ends", "notes that link nowhere", "notes with no outgoing links"

```bash
obsidian deadends 2>/dev/null
```

## Output Format

* Show matching note paths and relevant excerpts
* For backlinks: show link counts per note
* For tag searches: show note titles and relevant excerpt
* Always report result count (including zero)
* Zero results: report "No notes found for [query]" — never silently return nothing
