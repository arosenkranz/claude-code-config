---
name: patrol
description: patrol
---

# Patrol Cycle

Execute a full Gas Town system patrol in sequence without pausing for confirmation between steps. Report a single summary at the end.

## Patrol Sequence

Run all 6 components in this exact order:

1. **hooks** — Verify all hook scripts exist and are executable (`~/.claude/hooks/`)
2. **inboxes** — Scan inbox directories for pending items; count unprocessed files
3. **convoys** — Check convoy health: active count, throughput, last heartbeat
4. **worker pools** — Inspect utilization; detect zombie/stale workers
5. **cleanup** — Remove stale wisps, temp files, and orphaned lock files
6. **health** — Aggregate system health summary

## Issue Classification

For every anomaly found, classify as one of:

- `KNOWN_FIX` — Matches a known failure pattern; auto-resolve immediately
- `NOVEL` — Unfamiliar issue; escalate to escalation inbox with diagnostic context

### Known Fixes (auto-resolve without confirmation)

| Pattern | Detection | Action |
|---------|-----------|--------|
| Stale wisps | Files in wisp dir older than 1 hour | Delete stale files |
| Zombie processes | Process in worker pool with no heartbeat >5 min | `kill -9`, respawn |
| Stale heartbeats | Heartbeat timestamp >10 min old | Reset heartbeat, mark worker idle |
| Broken symlinks | `find` returns symlinks with missing targets | Remove broken links |
| Empty inbox dirs | Inbox exists but contains zero files | Log as healthy, no action |
| Orphaned lock files | Lock file with no associated live PID | Remove lock file |

### Novel Issue Escalation

When a NOVEL issue is found:
1. Write a diagnostic record to `~/.claude/escalations/` with timestamp
2. Include: component name, error description, relevant file paths, suggested investigation steps
3. Continue patrol — do not halt on NOVEL issues

## Output Format

After completing all 6 steps, output a single Markdown table:

```
| Component    | Status  | Last Checked        | Action Taken              |
|--------------|---------|---------------------|---------------------------|
| hooks        | OK      | 2026-02-28 14:32:01 | none                      |
| inboxes      | OK      | 2026-02-28 14:32:02 | 3 items processed         |
| convoys      | WARN    | 2026-02-28 14:32:03 | reset stale heartbeat     |
| worker pools | OK      | 2026-02-28 14:32:04 | none                      |
| cleanup      | OK      | 2026-02-28 14:32:05 | 2 stale wisps removed     |
| health       | OK      | 2026-02-28 14:32:06 | 1 NOVEL issue escalated   |
```

Status values: `OK` | `WARN` | `ERROR` | `ESCALATED`

## Headless / Long-Running Behavior

- Never pause for confirmation between steps
- After 20 patrol cycles, output a clean handoff summary: total issues found, KNOWN_FIX resolved, NOVEL escalated, next recommended action
- If a step takes >30s, log timeout and move to next step — do not block the cycle
- Do not open editors, browsers, or interactive processes during patrol