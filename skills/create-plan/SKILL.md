---
name: create-plan
description: Create a structured feature implementation plan as a markdown document with progress tracking, status indicators, critical decisions, and modular task breakdown. For multi-session or ticket-driven work, creates a full ExecPlan living document.
disable-model-invocation: true
---

> **[DEPRECATED]** Candidate for removal (2026-03-03). Replaced by plan mode (simple tasks) and ExecPlan template (multi-session). If unused by 2026-03-17, delete this skill.

# Plan Creation Stage

Based on our full exchange, produce a plan document. Choose the appropriate mode:

## Mode Selection

**Quick mode** — for simple tasks (fewer than ~5 steps, single session, no ticket ID):
Produce a lightweight checklist plan inline or as a file.

**ExecPlan mode** — for multi-step, ticket-driven, or potentially multi-session work:
Use the ExecPlan specification at `~/.claude/templates/PLANS.md`. Save the plan to:
`~/workspace/work-artifacts/<TICKET-ID>/<TICKET-ID>-plan.md`

When in doubt, default to ExecPlan mode. A plan that can be resumed by any agent without conversation history is always more valuable than one that cannot.

---

## Quick Mode Template

Requirements:
- Include clear, minimal, concise steps.
- Track status with checkboxes.
- Include dynamic tracking of overall progress percentage (at top).
- Do NOT add extra scope or unnecessary complexity beyond explicitly clarified details.
- Steps should be modular, elegant, minimal, and integrate seamlessly within the existing codebase.

```markdown
# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Short summary of what we're building and why.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: [choice] - [brief rationale]
- Decision 2: [choice] - [brief rationale]

## Tasks:

- [ ] **Step 1: [Name]**
  - [ ] Subtask 1
  - [ ] Subtask 2

- [ ] **Step 2: [Name]**
  - [ ] Subtask 1
  - [ ] Subtask 2
```

---

## ExecPlan Mode

Follow the full ExecPlan specification at `~/.claude/templates/PLANS.md`. The plan must include:
- `Progress` table with per-step status
- `Surprises & Discoveries` section
- `Decision Log` table
- `Outcomes & Retrospective` section
- Explicit acceptance criteria for each step

Once the plan is written, tell the user they can execute it with:
> "Use the execplan-executor agent to execute `~/workspace/work-artifacts/<TICKET-ID>/<TICKET-ID>-plan.md`"

---

Again, it's still not time to build yet. Just write the clear plan document. No extra complexity or extra scope beyond what we discussed.
