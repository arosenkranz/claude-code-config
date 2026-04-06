---
name: end-of-day
description: End-of-day wrap-up that summarizes completed tasks, surfaces carryover items, and appends to today's daily note. Use when the user says "end of day", "eod", "wrap up", "done for today", or "daily wrap".
---

# End of Day

Refer to `~/.claude/skills/obsidian-core/SKILL.md` for CLI patterns, preflight checks, and error handling.

## Mode Selection

Check the user's invocation:
* **Guided mode** (default): Walk through completed tasks, open tasks, and reflection conversationally, waiting for responses before proceeding
* **Quick mode**: If the user says "quick", "fast", "just dump it", or "summary mode", gather all data and present the full EOD summary for confirmation in one pass (original behavior)

## Depth Mode

Determine reflection depth based on context:
* **Light touch** (default on weekdays): 2 reflection questions — biggest win and anything for tomorrow
* **Deep reflection** (default on Fridays, or if the user says "deep" or "reflect"): 4 questions — wins, blockers, what you'd do differently, and what you learned

Check today's day of week (from the date) to set the default.

## Workflow (Guided Mode)

### Step 1: Gather Data

Run these in parallel — this is background data gathering, not a user interaction step:

```bash
obsidian daily:read 2>/dev/null
obsidian tasks daily 2>/dev/null
obsidian files folder=Sessions 2>/dev/null
```

From `tasks daily`, separate completed (`- [x]`) and open (`- [ ]`) tasks. From `files folder=Sessions`, filter for files matching today's date prefix `YYYY-MM-DD-*`.

### Step 2: Completed Tasks

Show the completed tasks found. Ask: "Anything else you finished today that isn't tracked here?"

Wait for response. Add any extras to the completed list.

### Step 3: Open Tasks

Show open tasks in batches of 5. For each batch, ask: "For these — carry forward to tomorrow, drop them, or already done?"

Wait for response after each batch before showing the next.

### Step 4: Reflection

Ask reflection questions one at a time, waiting for a response between each.

**Light touch (weekdays):**
1. "What was your biggest win today?"
1. "Anything you want to remember for tomorrow?"

**Deep reflection (Fridays or "deep"/"reflect" invocation):**
1. "What was your biggest win today?"
1. "What blocked you or slowed you down?"
1. "What would you do differently?"
1. "What did you learn today?"

### Step 5: Summary and Append

Assemble the EOD summary from everything collected and present it for confirmation:

```
## EOD Summary — YYYY-MM-DD

**Completed today:**
- [x] Task 1
- [x] Task 2

**Carry to tomorrow:**
- [ ] Unfinished item A

**Key accomplishments:**
- [wins from reflection]

**Sessions worked:**
- [session file names / topics]

**Reflection:**
- [answers from Step 4]
```

After the user confirms, append to the daily note:

```bash
obsidian daily:append content="---\n## EOD Summary\n\n**Completed:**\n- [x] ...\n\n**Carry forward:**\n- [ ] ...\n\n**Accomplishments:**\n- ...\n\n**Reflection:**\n- ...\n"
```

## Notes

* Always present the summary for review before appending — never write silently
* Carry-forward items are informational; they surface in tomorrow's `morning-plan` carryover check
* If the daily note doesn't exist, the append command will create it
