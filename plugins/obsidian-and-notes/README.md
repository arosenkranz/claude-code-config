# obsidian-and-notes

Obsidian vault integration — session logging, note search, quick capture, and continuous learning from tool-use patterns.

## Skills

| Skill | Purpose |
|---|---|
| `obsidian-core` | Core vault operations (create, update, search notes) |
| `obsidian-session` | Log a session summary into the vault |
| `read-notes` | Read and summarize notes matching a query |
| `vault-search` | Search vault content with CQL-style queries |
| `continuous-learning-v2` | Observe tool-use patterns and write instincts to vault |

## Requirements

| Tool | Purpose | Install |
|---|---|---|
| Obsidian app | Vault host | [obsidian.md](https://obsidian.md) |
| Obsidian CLI | File operations from shell | Available from Obsidian v1.12.4+ |
| Python 3 | `continuous-learning-v2` observer | `brew install python` |
| `jq` | JSON processing in hooks | `brew install jq` |

**Check CLI is available:**
```bash
which obsidian
```

## Vault Structure

Skills assume this layout — adjust paths in skill files if your vault differs:

```
~/Documents/main-vault/
├── Ideas and Journal/YYYY-MM-DD.md   # daily notes
├── Sessions/                          # session logs
├── Inbox/                             # quick capture
└── 99-Meta/                           # templates
```

## Hooks

`obsidian-and-notes` registers a `PreToolUse` + `PostToolUse` hook for `continuous-learning-v2`. This hook observes every tool call and periodically writes pattern-based "instincts" to the vault. It creates `~/.claude/homunculus/` on first run.

To disable without removing the plugin, comment out the hook entries in `hooks.json`.

## Notes

- Session logging (`obsidian-session`) is also triggered by the `dev-environment` plugin's `SessionEnd` hook — both write to the vault, but through different paths
- `continuous-learning-v2` is noisy during active sessions; the observer batches writes to avoid flooding the vault
