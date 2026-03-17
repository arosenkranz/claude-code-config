---
name: obsidian-core
description: Shared CLI reference for Obsidian operations. Not user-invoked; read by other skills for consistent CLI patterns.
---

# Obsidian CLI Reference

**CLI version tested**: 1.12.4 (shipped Feb 2026, early access — syntax may evolve; update this file if commands change)

## Preflight Check

Before any CLI operation, verify the binary is available and Obsidian is running:

```bash
which obsidian > /dev/null 2>&1 || { echo "obsidian CLI not in PATH"; exit 1; }
pgrep -x Obsidian > /dev/null 2>&1 || { echo "Obsidian app must be running for CLI commands"; exit 1; }
```

If Obsidian is not running, prompt the user to open it before retrying.

## Stderr Policy

The CLI always emits a version-loading line to stderr on every invocation.

* **Reads**: Use `2>/dev/null` — safe to suppress, exit code still signals real errors
* **Writes**: Check exit code; do not blindly suppress stderr (surface real failures)

```bash
# Read (stderr suppression OK)
obsidian daily:read 2>/dev/null

# Write (check exit code)
obsidian create path="Inbox/Note.md" content="..." && echo "Created" || echo "Failed"
```

## Path Parameters

* **Always prefer `path=`** for automation — deterministic, uses exact vault-relative path
* Use `file=` only for interactive/fuzzy lookups where the user provides a note name

## Vault Folder Conventions

| Folder | Purpose |
|--------|---------|
| `Ideas and Journal/YYYY-MM-DD.md` | Daily notes |
| `Sessions/YYYY-MM-DD-description.md` | Session logs (kebab-case filenames) |
| `Inbox/` | Quick capture, triaged weekly |
| `Datadog/Active/` | Active work notes |
| `99-Meta/` | Templates and guides |

## Core Commands

### Daily Notes
```bash
obsidian daily:read 2>/dev/null                              # Read today's daily note
obsidian daily:append content="- [ ] Task" 2>/dev/null      # Append to daily note
obsidian daily:prepend content="## Focus\n- [ ] Task"       # Prepend to daily note
```

### Files
```bash
obsidian read path="Sessions/2026-03-02-example.md" 2>/dev/null
obsidian create path="Inbox/Note.md" content="..."
obsidian append path="Inbox/Note.md" content="..."
obsidian files folder=Inbox 2>/dev/null
```

### Search
```bash
obsidian search:context query="terraform" format=json limit=10 2>/dev/null
obsidian search:context query="topic" path="Sessions" format=json limit=10 2>/dev/null
obsidian backlinks path="Sessions/2026-03-02-example.md" 2>/dev/null
obsidian backlinks file="note name" counts 2>/dev/null
obsidian orphans 2>/dev/null
obsidian deadends 2>/dev/null
obsidian unresolved 2>/dev/null
```

### Tasks
```bash
obsidian tasks todo 2>/dev/null     # All open tasks vault-wide
obsidian tasks daily 2>/dev/null    # Today's tasks (done + todo)
```

### Properties & Tags
```bash
obsidian property:set path="Note.md" name="status" value="done"
obsidian tag name="meeting" verbose 2>/dev/null
```

## Content Escaping

* Use `\n` for newlines in content strings
* Quote values containing spaces: `content="My note title"`
* For large multi-line content, write a temp file and pipe if the CLI supports it

## Error Handling

* Empty output from `format=json` = no results (not an error)
* Non-zero exit from write commands = failure; surface the error to the user
* If the CLI returns nothing for a read command, the note does not exist yet
