---
name: cleanup-worktrees
description: Safely scans all git worktrees, checks merge status and PR state, categorizes them (Merged/PR Closed/Remote Deleted/Active), presents a report, and deletes with user approval. Never deletes the current worktree. Invoke when asked to "clean up worktrees", "remove merged worktrees", or "prune worktrees".
---

# Cleanup Worktrees

Intelligent git worktree cleanup. Discovers all worktrees, checks their status, categorizes them, and removes stale ones safely.

## Phase 1: Discover Worktrees

List all worktrees:
```bash
git worktree list --porcelain
```

Parse the output to collect:
* Worktree path
* Branch name (or detached HEAD SHA)
* Whether it is the currently checked-out worktree (marked `HEAD` in output)

**Skip automatically:**
* The main worktree (primary repo checkout)
* The current worktree (where this command is being run from)
* Worktrees under `~/.claude/worktrees/` (Claude Code internal worktrees — managed separately)

Also run a basic sanity check:
```bash
git worktree list
```
If any worktree paths are missing from disk (unlocked but directory gone), note them as "orphaned" — they should be pruned first:
```bash
git worktree prune
```

---

## Phase 2: Check Status of Each Worktree

For each remaining worktree branch, check in this order:

**2a. Is the branch merged into main?**
```bash
git branch --merged main | grep "<branch-name>"
```
If it appears: category = **Merged**.

**2b. Is there an open or closed PR?**
```bash
gh pr list --head "<branch-name>" --state all --json number,state,title,mergedAt
```
* If `state: MERGED`: category = **PR Merged** (if not already caught by 2a)
* If `state: CLOSED` (not merged): category = **PR Closed (Abandoned)**
* If `state: OPEN`: category = **Active** (has open PR — do not delete)
* If no PR found: continue to 2c

**2c. Does the remote branch still exist?**
```bash
git ls-remote --heads origin "<branch-name>"
```
* If empty: category = **Remote Deleted**
* If exists: category = **Active**

**2d. Does the worktree have uncommitted changes?**
```bash
git -C "<worktree-path>" status --porcelain
```
If there are uncommitted changes, mark as **Dirty** regardless of other categories. Never auto-delete dirty worktrees.

---

## Phase 3: Present Categorized Report

Display the results in a clear table:

```
## Worktree Status Report

### Safe to Delete

| Branch | Path | Reason | PR |
|--------|------|--------|----|
| train-123-my-feature | ~/workspace/... | Merged | #45 (merged) |
| train-456-old-thing  | ~/workspace/... | Remote deleted | None |

### Active (keeping)

| Branch | Path | Status |
|--------|------|--------|
| train-789-current | ~/workspace/... | Open PR #67 |

### Dirty (manual review needed)

| Branch | Path | Changes |
|--------|------|---------|
| train-999-wip | ~/workspace/... | 3 modified files |

### Skipped

| Path | Reason |
|------|--------|
| ~/.claude/worktrees/... | Claude Code internal worktree |
| (main worktree) | Primary checkout |
```

If there is nothing to delete, say so clearly and stop.

---

## Phase 4: Confirm and Delete

Present the "Safe to Delete" list and ask:

> "Ready to remove N worktrees listed above. Proceed? (This removes the worktree directories and their local branch refs.)"

Wait for explicit user confirmation before deleting anything.

**If confirmed**, for each worktree in the "Safe to Delete" list:

```bash
git worktree remove "<worktree-path>" --force
git branch -d "<branch-name>"
```

Notes on `--force`: Only use it for worktrees where the branch is confirmed merged or remote-deleted. If `git worktree remove` without `--force` fails for an unexpected reason, stop and report — do not blindly retry with `--force`.

For dirty worktrees: never delete. Tell the user to commit, stash, or discard changes manually first.

---

## Phase 5: Confirm Results

After deletion, run:
```bash
git worktree list
```

Report:
* How many worktrees were removed
* How many remain active
* Whether a final `git worktree prune` was run to clean up any remaining administrative files

---

## Safety Rules

* Never delete the worktree you are currently inside.
* Never delete a worktree with uncommitted changes.
* Never delete a worktree for a branch with an open PR.
* Always confirm with the user before any deletion.
* Do not guess at branch merge status — run the checks explicitly.
* If `git worktree remove` fails unexpectedly, stop and report rather than escalating with destructive flags.
