---
name: problem-statement
description: Problem Statement Co-Authoring Skill
---

# Problem Statement Co-Authoring Skill

Guide users through drafting RFC problem statements using a structured workflow that focuses on the "why" before the "how."

## Triggers

* User invokes `/problem-statement`
* User wants to write an RFC or problem statement
* User needs help articulating a problem before designing a solution

## Workflow Overview

This skill guides co-authoring through four stages:

1. **Context Gathering** - Understand the problem space
2. **Section Drafting** - Work through each section iteratively
3. **Refinement** - Review for clarity and completeness
4. **Output** - Save the final markdown

## Stage 1: Context Gathering

Start by understanding what the user is trying to solve:

```
I'll help you draft a problem statement. Let's start by understanding the problem space.

Tell me about the problem you're trying to solve:
* What's happening (or not happening) that's causing pain?
* Who is affected?
* How urgent is this? (blocking work, causing incidents, gradual degradation, opportunity cost)

Feel free to share raw notes, slack threads, or just talk through it.
```

**Fast-path option:** If the user has existing notes or a rough draft, offer to work from that instead of starting from scratch.

## Stage 2: Section Drafting

Work through sections in this order (the most effective sequence for problem articulation):

### 2a. Problem Description (Start Here)

This is the core. Focus on:
* What is the current situation?
* Why is this a problem?
* What are the specific pain points?
* What is the impact if we don't solve it?

**Coaching prompt:**
```
Let's nail down the problem first. Based on what you've shared:

[Draft problem description]

Does this capture the core issue? What's missing or incorrect?
```

### 2b. Overview (Elevator Pitch)

Derive from the problem description - a 2-3 sentence summary.

```
Now let's create the elevator pitch - if you had 30 seconds to explain this to a stakeholder, what would you say?

Here's a draft based on our problem description:

[Draft overview]
```

### 2c. Stakeholders

Map the dependency graph:
* Who depends on this being solved?
* Who do we depend on?
* Who needs to be consulted?

### 2d. Requirements

Can be deferred if unknown. Ask:
```
Do you have a sense of the requirements yet, or is that still emerging?

If you know some constraints (timeline, compatibility needs, performance targets), let's capture those. Otherwise, we can mark this as "TBD pending discovery."
```

### 2e. Out of Scope

Critical for preventing scope creep:
```
What should this project explicitly NOT address?

Think about:
* Adjacent problems you're intentionally deferring
* Features that might seem related but aren't included
* Future phases that are out of scope for now
```

## Stage 3: Refinement

Review the complete draft for:

1. **Clarity** - Is each section understandable to someone outside the immediate team?
2. **Completeness** - Are all required sections filled in (or explicitly marked TBD)?
3. **Focus** - Are we describing the problem, not proposing solutions?

**Solution creep check:**
```
Let me check: are we describing the problem or accidentally proposing solutions?

[Flag any solution language found]

Problem statements should focus on the "why" - the "how" comes later in the design doc.
```

## Stage 4: Output

Generate the final markdown and save to the drafts folder.

1. Ask for a short title (for the filename):
   ```
   What short title should we use for this? (This becomes the filename, e.g., "api-rate-limiting")
   ```

2. Generate the filename: `YYYY-MM-DD-{short-title}.md`

3. Save to: `/Users/alex.rosenkranz/workspace/alex/alex-admin/docs/drafts/problem-statements/`

4. Confirm:
   ```
   Saved to: docs/drafts/problem-statements/YYYY-MM-DD-short-title.md

   Next steps:
   * Review and refine as needed
   * When ready for formal review, copy to Google Docs and add the metadata table
   * Share with stakeholders for feedback
   ```

## Template Reference

Load the template from the repository to ensure consistency:

**Template location:** `/Users/alex.rosenkranz/workspace/alex/alex-admin/docs/templates/problem-statement.md`

Always read this template at the start of the workflow to ensure the output matches the current template structure.

## Key Behaviors

* **Ask before writing** - Gather context through questions, don't assume
* **Focus on "why"** - Resist jumping to solutions; redirect if the user goes there
* **Allow iteration** - Each section can be revised multiple times
* **Keep language crisp** - Problem statements should be clear and stakeholder-friendly
* **Explicit scope boundaries** - Out of Scope is as important as Requirements
* **Check for solutions** - Explicitly review for accidental solutioning before finalizing

## Example Interaction

```
User: /problem-statement

Claude: I'll help you draft a problem statement. Let's start by understanding the problem space.

Tell me about the problem you're trying to solve:
* What's happening (or not happening) that's causing pain?
* Who is affected?
* How urgent is this?

Feel free to share raw notes, slack threads, or just talk through it.

User: Our API keeps hitting rate limits when customers do bulk imports. It's causing support tickets and customers are frustrated.

Claude: Got it - API rate limiting during bulk imports is causing customer pain and support burden. Let me ask a few clarifying questions:

1. How often is this happening? (daily, weekly, during specific events?)
2. What's the current rate limit, and what are customers trying to do that exceeds it?
3. Is this affecting all customers or specific tiers/use cases?
4. What happens when they hit the limit - do they get useful error messages?

[Continues through workflow...]
```

## Related

* Template: `docs/templates/problem-statement.md`
* Drafts folder: `docs/drafts/problem-statements/`
* README with workflow: `docs/README.md`