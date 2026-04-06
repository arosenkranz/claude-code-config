---
name: morning-plan
description: Generate a morning briefing from today's daily note, open tasks, carryover from yesterday, and Jira sprint items. Use when the user says "morning", "start my day", "daily plan", "what's on today", or "plan my day".
---

# Morning Plan

Refer to `~/.claude/skills/obsidian-core/SKILL.md` for CLI patterns, preflight checks, and error handling.

## Mode Selection

Check the user's invocation:
* **Guided mode** (default): Walk through each data source and section conversationally, asking questions and waiting for responses before proceeding
* **Quick mode**: If the user says "quick", "fast", "just dump it", or "summary mode", run all data gathering steps, present the full briefing, then walk through section fill-in (Steps 4-5)

## Workflow (Guided Mode)

### Step 1: Carryover Check

Read today's daily note first (to know what template sections exist):
```bash
obsidian daily:read 2>/dev/null
```

Then read yesterday's daily note (compute YYYY-MM-DD for yesterday):
```bash
obsidian read path="Ideas and Journal/YYYY-MM-DD.md" 2>/dev/null
```

Look for:
* Unchecked `- [ ]` items
* Sections labeled "Tomorrow", "Carryover", or "Carry forward"

Show any unchecked items found. Ask: "For each of these — carry forward to today, drop it, or already done?"

Wait for response. Note confirmed carryovers before proceeding.

### Step 2: Open Tasks

```bash
obsidian tasks todo 2>/dev/null
```

Show the top 5 open vault-wide tasks (exclude today's carryovers already addressed). Ask: "Any of these a priority for today?"

Wait for response before proceeding.

### Step 3: Jira Sprint

If the Atlassian MCP is available (`mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql`), query:
```
project = TRAIN AND assignee = currentUser() AND sprint in openSprints() AND status != Done ORDER BY priority DESC
```

Show the sprint items. Ask: "Which of these are you tackling today?"

Wait for response. If MCP is unavailable, skip this step silently and proceed.

### Step 4: Section Fill-In

Walk through each section of the daily note template **one at a time**, incorporating what you've already learned from Steps 1-3. Use the sections detected in today's daily note.

**Do this conversationally, section by section.** Do not ask all sections at once. Wait for the user's response before moving to the next section.

Work through these sections in order:

1. **Today's Focus** — "What do you want to focus on today? (List your top 2-4 priorities)" — pre-populate with confirmed carryovers and Jira items the user flagged; ask them to confirm or adjust.
1. **Meetings & Calls** — "What meetings do you have today? Give me the name and time for each, and any notes on purpose or attendees if helpful."
1. **Learning & Development** — "Anything you want to learn or explore today? (Optional — skip if nothing specific)"
1. **Tomorrow's Prep** — "Anything you want to remember to do tomorrow? (Optional — skip if nothing yet)"

Skip a section only if the user explicitly says to skip it or says they have nothing for it.

**Important:** If the user provides multiple sections' worth of information in a single message (e.g., "1:1 w/ Naris @1pm, 1:1 w/ Jeremy @4pm, review the course, perf reviews"), parse it intelligently:
* Items with times/people: Meetings & Calls
* Work tasks: Today's Focus
* Do not re-ask for sections the user has already answered; confirm what you've inferred and ask only about remaining sections.

### Step 5: Write the Completed Daily Note

Once all sections are collected, present the assembled content for confirmation. Then write using `daily:prepend`:

**Note:** `obsidian create` does NOT overwrite existing files — it creates a numbered duplicate (e.g., `2026-03-03 1.md`). To rewrite an existing daily note, use the Write tool directly on the vault file at `/Users/alex.rosenkranz/Documents/main-vault/Ideas and Journal/YYYY-MM-DD.md`. Use `daily:prepend` only when adding content to an otherwise-complete note.

```bash
obsidian daily:prepend content="## Today's Focus
- [ ] Priority 1
- [ ] Priority 2

## Meetings & Calls
### 1:1 w/ Name - Time
**Purpose:**
**Action Items:**
- [ ]

## Learning & Development
[what they said, or omit if skipped]

## Tomorrow's Prep
- [ ] [what they said, or omit if skipped]

"
```

Confirm with the user before writing if there are any ambiguities. After writing, confirm what was saved and where.

## Notes

* If no daily note exists yet, `daily:prepend` will create it
* Do not write to the daily note until the user has confirmed all sections
* The goal is a structured, useful daily note — not just a task list
* Be flexible: users may dump everything in one message; parse smartly instead of asking redundant follow-up questions
