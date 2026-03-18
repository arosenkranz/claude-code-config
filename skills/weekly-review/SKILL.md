---
name: weekly-review
description: Guided weekly review covering inbox audit, session summary, task review, vault health check, and brag candidates. Use when the user says "weekly review", "review my week", "Friday review", or "weekly summary".
---

# Weekly Review

Refer to `~/.claude/skills/obsidian-core/SKILL.md` for CLI patterns, preflight checks, and error handling.

## Mode Selection

Check the user's invocation:
* **Guided mode** (default): Walk through each section conversationally, asking questions and waiting for responses before proceeding
* **Quick mode**: If the user says "quick", "fast", "just dump it", or "summary mode", run all data gathering steps and present the full summary at once (original behavior — use the structured review format from the Notes section)

## Workflow (Guided Mode)

Work through each phase one at a time. After each phase, wait for the user's response before moving to the next.

### Phase 1: Inbox

```bash
obsidian files folder=Inbox 2>/dev/null
```

Show the list of inbox items. For each item, suggest a destination folder or action (file it, archive it, delete it). Ask: "Want me to move any of these? Tell me which ones and where, or say 'skip' to move on."

Wait for response. Execute confirmed moves before proceeding.

### Phase 2: Sessions

```bash
obsidian files folder=Sessions 2>/dev/null
```

Filter to files from the past 7 days (date prefix `YYYY-MM-DD-*`). Summarize: what topics were worked on, what was completed, any patterns noticed.

Then ask:
* "What else did you work on this week that isn't captured in a session note?"
* "Any patterns you noticed in how your week went?"

Wait for response before continuing.

### Phase 3: Tasks

```bash
obsidian tasks todo 2>/dev/null
```

Identify stale tasks (from daily notes older than 3 days). Present them in batches of 5, not all at once. For each batch, ask: "For these tasks: carry forward, archive, or close? You can answer per-item or say 'all forward', 'all close', etc."

Wait for response after each batch before showing the next.

### Phase 4: Vault Health

```bash
obsidian orphans 2>/dev/null
obsidian unresolved 2>/dev/null
```

Report counts of orphaned notes and unresolved links. Show the list of orphaned notes. Ask: "Want me to clean any of these up, or just note them for now?"

Wait for response. Do not auto-delete anything.

### Phase 5: Brag Candidates

```bash
obsidian search:context query="completed" path="Sessions" format=json limit=5 2>/dev/null
obsidian search:context query="shipped" path="Sessions" format=json limit=5 2>/dev/null
```

Surface any notable accomplishments found this week. Then ask: "Anything else you shipped or accomplished this week that you're proud of? Anything that felt like a win, even if it's not in a session note?"

Wait for response.

### Phase 6: Retrospective

Ask each of these questions one at a time, waiting for a response between each:

1. "What was your biggest win this week?"
1. "What blocked you or slowed you down?"
1. "What would you do differently next week?"
1. "What did you learn?"

### Phase 7: Wrap-Up

Summarize the key decisions and insights from the review (moves made, tasks closed/archived, retrospective answers, brag candidates noted).

Then ask: "Want me to write a weekly review note to `Sessions/YYYY-MM-DD-weekly-review.md` capturing the highlights, decisions, and retrospective answers?"

If yes, write the note using the Write tool at the appropriate path under `/Users/alex.rosenkranz/Documents/main-vault/Sessions/`.

## Notes

* Never move or modify files without explicit user confirmation
* If any CLI command returns an error, report it and continue with the other steps
* The weekly review is read-heavy; write operations only happen after user approval
* Quick mode structured format:

```
## Weekly Review — Week of [YYYY-MM-DD]

### Inbox (N items)
- [item]: suggested action

### Sessions This Week
- [YYYY-MM-DD-topic]: [brief outcome]

### Stale Tasks
- [task]: from [date] — keep / archive / close?

### Vault Health
- Orphaned notes: N
- Unresolved links: N

### Potential Brag Candidates
- [accomplishment summary]
```
