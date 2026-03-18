---
name: read-notes
description: Search and read Obsidian vault notes by topic. Use when needing context from past sessions, project notes, or any stored knowledge.
---

# Read Obsidian Notes by Topic

Refer to `~/.claude/skills/obsidian-core/SKILL.md` for CLI patterns, preflight checks, and error handling.

If no argument is provided, inform the user they need to pass a topic as an argument.

## Search Strategy

1. **Primary search** — full-text search across the vault:
   ```bash
   obsidian search:context query="<topic>" format=json limit=10 2>/dev/null
   ```

1. **Folder-scoped search** — when the user specifies a context or folder:
   ```bash
   obsidian search:context query="<topic>" path="Sessions" format=json limit=10 2>/dev/null
   ```

1. **Tag-based search** — secondary vector when the topic maps to a known tag:
   ```bash
   obsidian tag name="<topic>" verbose 2>/dev/null
   ```

1. **Backlinks** — for the top result, surface related notes:
   ```bash
   obsidian backlinks path="<top-result-path>" 2>/dev/null
   ```

## Output Format

* List files with relevance indicators
* Show brief excerpts of matching content
* Group by category: Sessions, Projects, Daily Notes, General
* Include note paths for easy navigation
* Show total match count
* Exclude template files (anything in `99-Meta/`) from results

## Multiple Topics

For space- or comma-separated topics, run a separate search per term then merge and deduplicate results by note path.

## Priority Order

1. Exact matches in file names or headers
1. Session notes that mention the topic
1. Project notes containing the topic
1. General content matches

## Examples

* `/read-notes terraform` - Find notes about Terraform
* `/read-notes docker kubernetes` - Find notes about Docker or Kubernetes
* `/read-notes "datadog curriculum"` - Find notes about Datadog curriculum
