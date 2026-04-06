# dev-environment

Core dev automation — lifecycle hooks, coding standards commands, statusline, guardrails, and Claude Island integration.

## Hooks

All lifecycle hooks are consolidated here for deterministic ordering.

| Event | Scripts |
|---|---|
| `SessionStart` | `session-start.sh` (env setup, wade hint) + `claude-island-state.py` |
| `SessionEnd` | `session-logger.sh` (Obsidian + SQLite) + `claude-island-state.py` |
| `PreCompact` | `pre-compact.sh` + `claude-island-state.py` |
| `PostToolUse` (Edit) | `post-edit-format.sh` (formatter) + `check-console-log.sh` |
| `PostToolUse` (Write) | `check-console-log.sh` |
| `PreToolUse`, `Stop`, `SubagentStop`, `UserPromptSubmit`, `Notification` | `claude-island-state.py` |
| `PermissionRequest` | `afplay` ping sound + `claude-island-state.py` |

## Commands (Coding Standards)

Coding standards distributed as commands — invoke via `/dev-environment:coding-style`, etc.

- `coding-style` — Immutability, file organization, error handling
- `git-workflow` — Commit format, PR workflow, gh CLI usage
- `memory-system` — Auto-memory system guidelines
- `performance` — Model selection, context management, ultrathink
- `security` — Mandatory security checks, secret management
- `testing` — TDD workflow, coverage requirements

## Claude Island

`claude-island-state.py` syncs session state to the Claude Island macOS companion app via Unix socket. Comment out its entries in `hooks.json` if the app isn't installed.
