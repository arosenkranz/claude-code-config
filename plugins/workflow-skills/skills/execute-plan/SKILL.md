---
name: execute-plan
description: Execute a feature implementation plan precisely as documented, writing elegant modular code that follows existing codebase conventions. Updates progress tracking as each step completes. For ExecPlan living documents, delegates to the execplan-executor agent.
disable-model-invocation: true
---

# Plan Execution

## Execution Mode

**If the plan is an ExecPlan** (has a `Progress` table, `Surprises & Discoveries`, and `Decision Log` sections — typically at `~/workspace/work-artifacts/<TICKET-ID>/<TICKET-ID>-plan.md`):

Use the `execplan-executor` agent. It handles step verification, progress updates, and decision logging automatically:

> "Use the execplan-executor agent to execute `<path-to-plan>`"

The execplan-executor will:
- Read the full plan and identify the first incomplete step
- Run tests/verification before marking each step done
- Record surprises and decisions inline in the plan file
- Pause and report on any blockers

---

**If the plan is a quick checklist** (inline or simple markdown):

Implement precisely as planned, in full.

Implementation Requirements:
- Write elegant, minimal, modular code.
- Adhere strictly to existing code patterns, conventions, and best practices.
- Do not add scope, features, or improvements beyond what the plan specifies.
- As you implement each step, update the markdown tracking document with checkbox status and overall progress percentage.
- Use Conventional Commits format for any commits: `<type>(<scope>): <description>`.
- Do not include Claude attribution in commits.
