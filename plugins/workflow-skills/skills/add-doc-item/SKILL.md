---
name: add-doc-item
description: >
  Quickly capture a new documentation item to the Documentation backlog in the Obsidian vault.
  Use this skill whenever the user wants to log something they need to document, add a doc item,
  track a documentation gap, or capture something for Confluence later. Trigger phrases include
  "add a doc item", "I need to document", "log this for documentation", "new doc entry",
  "add to my documentation list", "documentation backlog", "I should document this",
  "capture this for docs", or any mention of adding items to the Documentation folder.
  Also trigger when the user says things like "remind me to write docs about X" or
  "this needs to be documented". Always use this skill proactively when the user's intent
  is clearly about capturing something that needs documentation — even if they don't use
  the exact words above.
---

# Add Documentation Item

You help Alex quickly capture documentation items into the Obsidian vault. Each item becomes
its own markdown file in the Documentation folder, ready to be fleshed out and eventually
published to Confluence.

**Documentation folder:** `~/Documents/main-vault/Datadog/Documentation/`

---

## How it works

When Alex tells you about something that needs documenting, follow these steps:

### Step 1: Gather the details

If Alex gave you everything in their message, great — extract what you need. If not,
ask using `AskUserQuestion` with these fields:

- **Title**: A short, descriptive name for what needs documenting (used as the filename)
- **Description**: What should the documentation cover? Context, scope, audience, key points.
- **Tags**: Categories that help organize and filter items. Common tags include:
  `runbook`, `onboarding`, `architecture`, `process`, `troubleshooting`, `reference`,
  `how-to`, `api`, `integration`, `course-content`, `lab`, `workshop`

Be smart about inferring tags from context. If Alex says "we need docs on how to set up
a new Instruqt lab environment," you can reasonably tag that as `how-to`, `lab` without
asking.

### Step 2: Create the file

Generate a filename from the title: lowercase, hyphens for spaces, no special characters.
For example, "Set Up Instruqt Lab Environment" becomes `set-up-instruqt-lab-environment.md`.

Write the file using this template:

```markdown
---
type: work
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [documentation, <additional-tags>]
status: backlog
confluence_status: not_started
---
# <Title>

## What needs to be documented
<Description — what this doc should cover, who it's for, why it matters>

## Notes
-

## Related resources
-
```

Always include `documentation` as a tag alongside whatever specific tags apply.
Use today's date for both `created` and `modified`.
The `status` field starts as `backlog` (other states: `drafting`, `review`, `published`).
The `confluence_status` field tracks the Confluence publishing state: `not_started`, `draft_created`, `published`.

### Step 3: Confirm

After creating the file, give Alex a brief confirmation showing the title, tags,
and a link to the file. Keep it short — they're probably in brain-dump mode and want
to keep going.

---

## Batch mode

If Alex rattles off multiple items at once (e.g., "I need to document X, Y, and Z"),
create all of them in one go. For each item, infer reasonable tags from context.
After creating them all, show a summary table:

| Item | Tags | File |
|------|------|------|
| Title 1 | tag1, tag2 | `filename-1.md` |
| Title 2 | tag1, tag3 | `filename-2.md` |

---

## Tips for good captures

The goal is speed — help Alex get items out of their head and into the vault with
minimal friction. Don't over-ask for details. A title and one-sentence description is
perfectly fine. They can flesh things out later. If they give you a wall of context,
distill it into a clear description rather than dumping it in verbatim.
