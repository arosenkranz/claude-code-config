---
name: managing-jira-tickets
description: Create and manage Jira tickets on the TRAIN board following team conventions, including CET labels, epic structure, and required fields. Use when creating tickets, documenting work, applying labels, or structuring Jira issues.
---

# Jira Ticket Management

Standards and templates for creating well-structured Jira tickets on the TRAIN board.

## Board Configuration

* **Jira Instance**: datadoghq.atlassian.net
* **Project**: TRAIN
* **Board ID**: 1886
* **Board URL**: https://datadoghq.atlassian.net/jira/software/c/projects/TRAIN/boards/1886

## CET Label System

**All tickets MUST have at least one `cet-*` label.** Apply labels that describe the work type:

### Content & Learning Labels
* `cet-course`: Work impacting a course in the learning center (`/courses` folder)
* `cet-workshop`: Work impacting a workshop (`/workshops` folder)
* `cet-cert`: Certification-related work
* `cet-localization`: Workshop localization work

### Development & Operations Labels
* `cet-ops`: Operations work (replacing old `training-ops` label)
* `cet-demoapp`: Work on storedog, techstories, or other demo apps
* `cet-docs`: Documentation work
* `cet-analytics`: Data analytics work

### Fix & Maintenance Labels
* `cet-bug`: Breaking fix/typo/screenshots (urgent)
* `cet-maintenance`: Nice-to-have fixes, nothing breaking (non-urgent)

### Planning & Ideas Labels
* `cet-idea`: Suggestion for a workshop or course
* `cet-icebox`: Backburner work (place in `backlog` column)
* `cet-skunkworks`: Side projects/brown bag deliverables

**Label Combinations:**
* Course work: Use `cet-course` + secondary label (e.g., `cet-bug`, `cet-maintenance`)
* Workshop work: Use `cet-workshop` + secondary label
* Never create new `cet-*` labels - mix existing ones as needed

## Required Ticket Fields

### Must Have
* **Summary**: Clear, concise title
* **Description**: Detailed explanation with context
* **Labels**: At least one `cet-*` label
* **Issue Type**: Story, Task, Bug, etc.
* **Definition of Done**: In dedicated field (NOT in description)

### Recommended
* **Epic Link**: Use current quarter's unscheduled work epics (`COUR`, `WORK`, `PLAT`)
* **Story Points**: For sprint planning
* **Assignee**: Team member responsible
* **Priority**: Critical, High, Medium, Low
* **Course/Workshop URLs**: Link to source files and `course_info.yml`

## Ticket Creation Template

### Standard Structure

```markdown
## Summary
[Clear, action-oriented title]

## Description

### Context
[Background information and why this work is needed]

### Scope
[What's included in this work]

### Out of Scope
[What's explicitly NOT included]

### Course/Workshop Information
* **Name**: [Course/Workshop name from course_info.yml]
* **URL**: https://learn.datadoghq.com/...
* **Source**: [Link to GitHub source files]

### Related Links
* [Documentation]
* [Design doc]
* [Previous tickets]

## Definition of Done
* [ ] Specific, measurable completion criterion 1
* [ ] Specific, measurable completion criterion 2
* [ ] All tests passing
* [ ] Documentation updated
* [ ] Peer review completed
```

### Bug Ticket Template

```markdown
## Summary
[Component/feature] - [brief description of bug]

## Description

### Steps to Reproduce
1. Go to [location]
1. Click on [element]
1. Observe [issue]

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Environment
* Browser/Platform: [e.g., Chrome 120, Safari on iOS]
* Course/Workshop: [name and link]
* User Type: [student, instructor, admin]

### Screenshots
[Attach screenshots if applicable]

### Impact
* **Severity**: [Critical/High/Medium/Low]
* **Users Affected**: [Number or percentage]
* **Workaround Available**: [Yes/No - describe if yes]

## Labels
`cet-bug`, `cet-course` (or `cet-workshop`)
```

### Feature/Enhancement Template

```markdown
## Summary
[Feature name] - [brief value proposition]

## Description

### User Story
As a [user type], I want [feature] so that [benefit].

### Acceptance Criteria
* [ ] Criterion 1 with specific, testable condition
* [ ] Criterion 2 with specific, testable condition
* [ ] Criterion 3 with specific, testable condition

### Use Cases
1. **Scenario 1**: [Description]
   * **Given**: [Context]
   * **When**: [Action]
   * **Then**: [Expected outcome]

### Technical Considerations
* [Dependencies]
* [Performance implications]
* [Security considerations]

### Open Questions
* [ ] Question 1?
* [ ] Question 2?

## Labels
`cet-course`, `cet-maintenance` (or other appropriate combination)
```

## Priority Guidelines

### Critical
* Platform down or inaccessible
* Data loss or corruption
* Security vulnerabilities
* Blocking issue for imminent launch

### High
* Significant feature broken
* Affects many users
* Deadline-driven work
* Customer escalation

### Medium
* Minor feature issues
* Cosmetic bugs
* Enhancement requests
* Tech debt

### Low
* Nice-to-have improvements
* Future considerations
* Documentation updates

## Epic Structure

Use these epics for unscheduled work:

* **COUR Epics**: Course-related unscheduled work
* **WORK Epics**: Workshop-related unscheduled work
* **PLAT Epics**: Platform/ops unscheduled work

Check for current quarter epics before creating tickets.

## Ticket Hygiene Checklist

Before creating ticket:
- [ ] Searched for existing similar tickets
- [ ] Title is clear and actionable
- [ ] Description provides sufficient context
- [ ] All required fields completed
- [ ] At least one `cet-*` label applied
- [ ] Definition of Done in correct field
- [ ] Epic linked (if applicable)
- [ ] Priority set appropriately
- [ ] Course/workshop links included (if applicable)

## Common JQL Queries

```sql
-- Find tickets without labels
project = TRAIN AND labels is EMPTY

-- Find tickets missing CET labels
project = TRAIN AND labels not in (cet-course, cet-workshop, cet-idea,
  cet-ops, cet-icebox, cet-bug, cet-demoapp, cet-docs, cet-maintenance,
  cet-analytics, cet-skunkworks, cet-localization, cet-cert)

-- Open urgent fixes
project = TRAIN AND labels = cet-bug AND status != Done

-- Recent tickets without epics
project = TRAIN AND "Epic Link" is EMPTY AND created >= -30d

-- Unassigned urgent tickets
project = TRAIN AND assignee is EMPTY AND priority in (Critical, High)

-- Content work without target release
project = TRAIN AND labels in (cet-course, cet-workshop) AND fixVersion is EMPTY
```

## Workflow States

Typical ticket progression:
1. **Backlog** - Not yet prioritized
2. **To Do** - Prioritized, ready to work
3. **In Progress** - Currently being worked on
4. **Review** - Awaiting peer review
5. **Done** - Completed and verified

Always update ticket status as work progresses.

## MCP-Based Ticket Creation

When creating tickets programmatically via the Atlassian MCP (`mcp__atlassian__createJiraIssue`), use these settled values and patterns.

### Fixed Parameters for TRAIN

* **cloudId**: `datadoghq.atlassian.net` (pass the hostname directly; avoids the extra `getAccessibleAtlassianResources` round-trip)
* **projectKey**: `TRAIN`
* **issueTypeName**: `Task` is the team default. Epics (`Epic`) are reserved for quarterly strategic containers (e.g., `2026Q2-5.2 [P1] PLAT ...`). Do not create Stories unless a specific report depends on that type.

### Custom Field IDs (TRAIN project)

| Field | ID | Schema | Wire Format |
|---|---|---|---|
| Definition of Done | `customfield_11875` | `textarea` | **ADF required** (schema lies) |
| Epic Link (legacy) | `customfield_10014` | any | Prefer `parent` instead |
| Story point estimate | `customfield_10016` | number | Plain number |
| Start date | `customfield_10015` | date | ISO date string |

**Critical quirk:** `customfield_11875` (Definition of Done) reports schema type `string` / `textarea` in metadata, but the actual API requires Atlassian Document Format. Sending a plain string produces:
```
"Operation value must be an Atlassian Document (see the Atlassian Document Format)"
```

### ADF Wrapper for Definition of Done

Wrap DoD bullets in this structure:

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                { "type": "text", "text": "Your DoD criterion here" }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Parenting to an Epic

Use the system `parent` field, not `Epic Link`:

```json
"additional_fields": {
  "parent": { "key": "TRAIN-3948" },
  "priority": { "name": "Medium" },
  "labels": ["cet-ops"],
  "customfield_11875": { /* ADF doc from above */ }
}
```

The `description` field accepts markdown when `contentFormat: "markdown"` is set — but this does **not** extend to custom fields, which still need pre-formed ADF.

### Linking Dependencies

Use `mcp__atlassian__createIssueLink` with type `Blocks`.

**Semantics (easy to get backwards):**
* `inwardIssue` = the blocker
* `outwardIssue` = the blocked issue

So "A blocks B" → `inwardIssue: A, outwardIssue: B`.

### Recommended Flow for Multi-Ticket Epic Breakdown

1. Fetch the epic with `getJiraIssue` and narrow `fields` to avoid giant payloads (e.g., `["summary", "description", "status", "issuetype", "labels", "parent"]`).
2. Use `AskUserQuestion` to settle scope, ownership, ticket shape, and supporting work before drafting.
3. Draft each ticket (summary, description, DoD) and surface them to the user for review *before* creation.
4. Create tickets in parallel once approved (they're independent).
5. Create `Blocks` links between them sequentially or in parallel after all keys return.

### Minimal Verified Example

See the TRAIN-3975 / 3976 / 3977 trio (created under TRAIN-3948) for a working reference: all three were created with parent, priority, labels, and ADF-wrapped DoD in a single `createJiraIssue` call each.
