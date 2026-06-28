---
name: start-task
description: Start a new task from a Jira ticket. Pulls latest from main, fetches ticket details via Atlassian MCP, runs preflight checks, creates a feature branch, and presents a task summary. Invoke when asked to "start task TRAIN-123", "start working on <ticket>", "begin task", "pick up ticket", "start a new feature branch", or any variant of starting work on a TRAIN board ticket.
---

# Start Task

Start a new task from a Jira ticket. Accepts a TRAIN board ticket ID as input (e.g., `TRAIN-456`). If no ticket ID is provided, ask: "Which ticket are you starting work on?"

---

## Step 1: Preflight Checks

Before touching git, verify the environment is safe to start work:

**1a. Check for a git repository:**
```bash
git rev-parse --is-inside-work-tree 2>/dev/null || echo "NOT_GIT"
```
If not in a git repo, stop and report: "Not inside a git repository. Navigate to your project directory first."

**1b. Check for a dirty working tree:**
```bash
git status --porcelain
```
If there are uncommitted changes, report them and ask: "Your working tree has uncommitted changes. Stash, commit, or discard them before starting a new task?"
Do not proceed until the user confirms the tree is clean.

**1c. Determine the source-of-truth branch:**
Default to `main`. If `main` doesn't exist, check for `master`:
```bash
git branch -r | grep -E 'origin/(main|master)' | head -1
```

**1d. Pull latest:**
```bash
git checkout main && git pull origin main
```
If this fails (e.g., merge conflicts, network error), stop and report the error.

---

## Step 2: Fetch Ticket Details

Use the Atlassian MCP to fetch the ticket. The Jira cloud ID for `datadoghq.atlassian.net` is `66c05bee-f5ff-4718-b6fc-81351e5ef659`.

Call `mcp__plugin_atlassian_atlassian__getJiraIssue` with the provided ticket ID.

Extract and display:
* **Summary**: The ticket title
* **Type**: Bug / Story / Task / etc.
* **Status**: Current status
* **Priority**: If set
* **Description**: First 300 characters (truncate with "..." if longer)
* **Labels**: All CET labels
* **Epic/Parent**: If set
* **Acceptance Criteria / Definition of Done**: If present in the description or a custom field

If the ticket is not found, report: "Ticket <ID> not found on the TRAIN board. Check the ticket ID and try again."

---

## Step 3: Generate Branch Name

From the ticket summary, generate a kebab-case branch name:
* Lowercase all words
* Replace spaces and special characters with hyphens
* Remove articles (a, an, the) and filler words
* Keep it under 50 characters total
* Format: `<TICKET-ID>-<short-description>`

Examples:
* `TRAIN-456` "Add dark mode toggle to dashboard" → `train-456-dark-mode-dashboard`
* `TRAIN-123` "Fix NPE in user auth flow" → `train-123-fix-npe-user-auth`

**Check for branch name collision:**
```bash
git branch -a | grep "<generated-branch-name>"
```
If the branch already exists locally or remotely, append `-2` (or increment) and report to the user.

---

## Step 4: Create the Branch

```bash
git checkout -b <generated-branch-name>
```

Confirm success:
```bash
git branch --show-current
```

---

## Step 5: Present Task Summary

Output a structured summary:

```
## Task Started: <TICKET-ID>

**Branch**: `<branch-name>`
**Ticket**: <TICKET-ID> — <Summary>
**Type**: <Issue Type> | **Priority**: <Priority> | **Status**: <Status>
**Epic**: <Epic name or "None">
**Labels**: <labels or "None">

### What to build
<Description excerpt>

### Definition of Done
<DoD bullets if present, or "See ticket for details">

### Suggested next steps
* Review the full ticket: https://datadoghq.atlassian.net/browse/<TICKET-ID>
* Create an ExecPlan: `mkdir -p ~/workspace/work-artifacts/<TICKET-ID>` then use plan mode (simple tasks) or the ExecPlan template at `~/.claude/templates/PLANS.md` (multi-session work)
* When done: use `commit-push-pr` skill to commit, push, and open a PR
```

---

## Error Handling

| Situation | Response |
|-----------|----------|
| Not in git repo | Stop, explain, suggest `cd` to project |
| Dirty working tree | Show changes, ask user to resolve first |
| Ticket not found | Report clearly, check spelling |
| Branch already exists | Suggest incrementing suffix, ask user |
| Pull fails | Show error, do not create branch |
| Atlassian MCP unavailable | Report MCP error, offer to create branch with just the ticket ID |
