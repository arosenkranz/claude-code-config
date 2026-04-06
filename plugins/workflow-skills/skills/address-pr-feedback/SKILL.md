---
name: address-pr-feedback
description: Systematic 5-phase workflow for handling PR review comments. Fetches review threads via gh api (not gh pr view), triages by priority, executes fixes via sub-agent, posts inline GitHub replies, and commits. Invoke when asked to "address PR feedback", "respond to review comments", or "handle PR review".
---

# Address PR Feedback

Systematic workflow for triaging and resolving GitHub PR review comments. This skill covers the full cycle: fetch, plan, fix, reply, and finalize.

## Required Input

Before starting, confirm:
* PR number (e.g., `42`)
* Repo in `owner/repo` format (e.g., `DataDog/my-repo`)
* Ticket ID if available (for work-artifacts path)

If not provided, ask: "Which PR number and repo should I address feedback for?"

---

## Phase 1: Fetch and Organize

### Fetch review comments

Use the full REST API to get pull request review comment IDs. These are the IDs needed for inline replies and are different from the general PR comment IDs returned by `gh pr view`.

```bash
gh api repos/<owner>/<repo>/pulls/<number>/comments \
  --jq '[.[] | {id: .id, path: .path, line: .line, body: .body, user: .user.login, url: .html_url, diff_hunk: .diff_hunk}]'
```

Also fetch general (non-inline) PR comments:
```bash
gh api repos/<owner>/<repo>/issues/<number>/comments \
  --jq '[.[] | {id: .id, body: .body, user: .user.login}]'
```

### Create review notes file

Save to `~/workspace/work-artifacts/<TICKET-ID>/pr-<number>-review.md` (create directory if needed):

```markdown
# PR #<number> Review Notes

**PR**: <url>
**Date**: <YYYY-MM-DD>
**Reviewer(s)**: <list>

## Triage

### P0 — Must Fix (correctness, security, blocking)
- [ ] Comment ID `<id>` [@<user>, `<file>:<line>`]: <summary>

### P1 — Should Fix (important improvements, style violations)
- [ ] Comment ID `<id>` [@<user>, `<file>:<line>`]: <summary>

### P2 — Nice to Have (suggestions, optional improvements)
- [ ] Comment ID `<id>` [@<user>, `<file>:<line>`]: <summary>

### Acknowledged (no change needed — explain why)
- Comment ID `<id>`: <reason for no-change>

## Reply Drafts

For each comment, draft a reply here before posting:

### Comment <id>
**Fix**: <what will be done>
**Reply**: "<draft reply text>"
```

### Triage criteria

* **P0**: Bugs, security issues, broken tests, API contract violations, anything that would cause a prod incident.
* **P1**: Style guide violations (Conventional Commits, TypeScript types, missing tests), significant design concerns, unclear logic.
* **P2**: Nits, stylistic preferences, optional suggestions. Always acknowledge these even if not implementing.

Present the triage to the user and get approval before proceeding to Phase 2.

---

## Phase 2: Plan

For P0 and P1 items, outline the fix approach:

* Which files need to change
* Whether tests need updating
* If multiple comments touch the same area, batch them into a single commit

For P2 and Acknowledged items, draft a reply explaining why no change is being made (or that a follow-up ticket has been created).

Present the fix plan to the user. Confirm before executing.

---

## Phase 3: Execute Fixes

Launch a sub-agent (general-purpose) to implement the changes:

> "Implement the following PR feedback fixes for PR #<number> in <owner>/<repo>. Changes needed: [paste P0/P1 fix list from review notes]. Follow existing code conventions, use TypeScript, run tests after changes."

Monitor and verify:
* After each logical group of fixes, run relevant tests:
  * `npm test` / `npm run test` for JS/TS
  * `pytest` for Python
* Do not commit until tests pass.

Commit using Conventional Commits. Stage specific files only:
```bash
git add <specific files>
git commit -m "fix(<scope>): <description addressing review feedback>"
```

Do not include Claude attribution in commits. Do not use `--no-verify`.

---

## Phase 4: Post GitHub Replies

For each comment addressed (P0, P1, P2, Acknowledged), post an inline reply using the pull request review comment ID obtained in Phase 1.

**Important**: Use the review comment ID (from `/pulls/<number>/comments`), not the issue comment ID:

```bash
gh api repos/<owner>/<repo>/pulls/comments/<comment-id>/replies \
  --method POST \
  --field body="<reply text>"
```

Reply guidelines:
* For fixes: "Fixed in <commit-sha-short>. <brief explanation of what changed>."
* For acknowledged/no-change: "Thanks for the suggestion. <reason no change is being made>. Happy to discuss further if you feel strongly."
* For P2 not implemented: "Good point — I've opened TRAIN-XXX to track this as a follow-up rather than block this PR."

After posting all replies, verify they appear correctly:
```bash
gh pr view <number> --repo <owner>/<repo> --comments
```

---

## Phase 5: Finalize

1. Push the branch:
   ```bash
   git push
   ```

2. Update the review notes file with final status (mark all items complete).

3. If all reviewers' concerns are addressed, re-request review:
   ```bash
   gh pr edit <number> --repo <owner>/<repo> --add-reviewer <reviewer-username>
   ```
   (Only do this if the user confirms.)

4. Report to user:
   * How many comments addressed (P0/P1/P2/Acknowledged breakdown)
   * Commits made
   * Replies posted
   * Any items deferred to follow-up tickets

---

## Notes

* Never mark a comment as "Acknowledged" without posting a reply explaining why.
* If a reviewer's comment is unclear, post a clarifying question as a reply before guessing at a fix.
* Work artifacts go in `~/workspace/work-artifacts/` — create the directory if it doesn't exist.
* If there is no ticket ID, use `pr-<number>` as the directory name: `~/workspace/work-artifacts/pr-<number>/`.
