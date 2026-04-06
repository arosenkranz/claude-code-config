---
name: workspace
description: Set up a 3-pane cmux workspace — lazygit (top-right) for live diffs and yazi (bottom-right) for file navigation. Use at the start of a coding session.
user-invocable: true
---

# /workspace — 3-Pane Workspace Setup

Sets up a split-pane layout in cmux with lazygit in the top-right pane for live diff tracking and yazi in the bottom-right pane for file navigation, alongside your Claude Code session on the left.

## Implementation Notes (Read First)

- **One command per Bash call**: Every bash block below is a single command. No pipes, no variable assignments. Claude holds surface IDs in its own reasoning between calls.
- **Surface ID parsing**: `cmux new-split` outputs `OK surface:N workspace:N`. Extract the `surface:N` token (e.g., `surface:3`) from the output and remember it for subsequent commands.
- **Always include `\n`** in `cmux send` to submit the command. Without it, text is typed but not executed.
- **Cleanup is idempotent**: If close-surface fails, continue. If there are no extra surfaces, skip cleanup.
- **Yazi config is idempotent**: Check before writing. Skip if `show_hidden` already present.

---

## Steps

### 1. Check cmux environment

```bash
echo "${CMUX_WORKSPACE_ID:-NOT_SET}"
```

If output is `NOT_SET`, stop and tell Alex: "Not running inside a cmux workspace. Launch Claude Code via cmux to use this skill."

### 2. Detect project directory

```bash
pwd
```

Remember this path as the project directory. Use it in all subsequent `cd` and `yazi` commands.

### 3. Ensure yazi shows hidden files

Create the config directory if it doesn't exist:

```bash
mkdir -p ~/.config/yazi
```

Always write the config (overwrite to ensure correct structure):

```bash
printf '[manager]\nshow_hidden = true\n' > ~/.config/yazi/yazi.toml
```

Verify it was written correctly:

```bash
cat ~/.config/yazi/yazi.toml
```

Expected output:
```
[manager]
show_hidden = true
```

If the output doesn't match, warn Alex: "Could not write yazi config — hidden files may not show" and continue.

### 4. Clean up existing surfaces

Get the current (Claude Code) surface identifier:

```bash
cmux identify
```

The output is `surface:N workspace:N`. Remember the `surface:N` value — this is the Claude Code surface to preserve.

List all panes in the workspace:

```bash
cmux list-panes
```

For each `pane:N` token in the output, list its surfaces:

```bash
cmux list-pane-surfaces --pane <pane-ref>
```

Collect every `surface:N` token returned across all panes. For each surface that is NOT the Claude Code surface identified above, close it:

```bash
cmux close-surface --surface <ref>
```

If `close-surface` fails for any surface, ignore the error and continue. If no extra surfaces are found across any pane, skip closing and proceed directly to Step 5.

After closing all extra surfaces, wait for cmux to settle:

```bash
sleep 0.5
```

### 5. Create right split for lazygit

```bash
cmux new-split right
```

Output format: `OK surface:N workspace:N`. Extract and remember the `surface:N` value — this is the **lazygit surface**.

If the command fails or output contains no `surface:N`, stop and tell Alex: "Failed to create lazygit pane. Check that cmux is running and healthy."

### 6. Launch lazygit

Use the lazygit surface from Step 5. Replace `<lazygit-surface>` and `<project-dir>` with the remembered values:

```bash
cmux send --surface <lazygit-surface> "cd \"<project-dir>\" && lazygit\n"
```

### 7. Create bottom split for yazi

Split downward from the lazygit surface to create the yazi pane:

```bash
cmux new-split down --surface <lazygit-surface>
```

Output format: `OK surface:N workspace:N`. Extract and remember the `surface:N` value — this is the **yazi surface**.

If the command fails, warn Alex: "Failed to create yazi pane. Lazygit pane may still be usable." and skip Steps 8–9.

### 8. Launch yazi

Use the yazi surface from Step 7 and the project directory from Step 2:

```bash
cmux send --surface <yazi-surface> "yazi \"<project-dir>\"\n"
```

### 9. Wait for panes to initialize

```bash
sleep 1
```

### 10. Verify lazygit

```bash
cmux read-screen --surface <lazygit-surface>
```

Inspect the output and handle:

- **Git UI visible** (branches, commits, files): Success — proceed.
- **"Create a new git repository?" prompt**: Tell Alex: "lazygit is asking to init a repo. Reply 'y' to create or 'N' to cancel." Wait for Alex's choice, then send it.
- **Branch name prompt**: Send `\n` to accept default: `cmux send --surface <lazygit-surface> "\n"`
- **Welcome/dialog overlay**: Send `\n` to dismiss.
- **"command not found"**: Tell Alex: "lazygit not installed. Run: `brew install lazygit`"
- **Blank or shell prompt**: Re-send: `cmux send --surface <lazygit-surface> "lazygit\n"`

### 11. Verify yazi

```bash
cmux read-screen --surface <yazi-surface>
```

Inspect the output and handle:

- **Directory tree visible**: Success — proceed.
- **Blank or shell prompt**: Re-send: `cmux send --surface <yazi-surface> "yazi\n"`
- **"command not found"**: Tell Alex: "yazi not installed. Run: `brew install yazi`"
- **Permission error**: Warn Alex: "yazi started but encountered a permission error. Check directory permissions."

### 12. Confirm layout

Output the layout summary using the actual surface IDs remembered from earlier steps:

```
Workspace layout active:
  Left         → Claude Code session
  Top-right    → lazygit (surface:N) — live diffs
  Bottom-right → yazi (surface:N) — file navigator

lazygit tips:
  - Auto-refreshes as agents write code
  - j/k or arrow keys to navigate
  - space to stage files, c to commit, p to push
  - q to quit

yazi tips:
  - Arrow keys + Enter to navigate
  - . to toggle hidden files
  - / to search by filename, S for ripgrep content search, Z for fzf
  - Git status indicators shown inline
  - q to quit

Debug:
  cmux read-screen --surface <lazygit-surface>
  cmux read-screen --surface <yazi-surface>
```

---

## Error Table

| Condition | Action |
|-----------|--------|
| `$CMUX_WORKSPACE_ID` not set | "Not running inside a cmux workspace. Launch Claude Code via cmux." Stop. |
| `cmux new-split right` fails | "Failed to create lazygit pane. Check cmux is running." Stop. |
| No `surface:N` in split output | "Could not parse surface ID. Expected 'OK surface:N workspace:N'." Stop. |
| `cmux new-split down` fails | "Failed to create yazi pane. Lazygit may still be usable." Continue. |
| `close-surface` fails | Surface already closed or missing. Continue. |
| `yazi.toml` write fails | "Could not write yazi config — hidden files may not show." Continue. |
| No extra surfaces across any pane | Skip cleanup, go straight to Step 5. |
| lazygit shows git-init prompt | Ask Alex: "Init repo here? Reply y or N." |
| lazygit not installed | "Run: `brew install lazygit`" |
| yazi not installed | "Run: `brew install yazi`" |
| Terminal too small | Soft warning: "Terminal may be too small for 3 panes. Resize if needed." Continue. |

---

## When Assisting Alex in This Workspace

Use these tools via the Bash tool proactively — all are installed:

| Alex asks... | Claude does... |
|---|---|
| Find a file by name | `fzf` or `rg --files \| fzf` |
| Find files containing a pattern | `rg "<pattern>" --type ts -l` |
| Search with context | `rg "<pattern>" -C 3` |
| Preview a file | `bat <file>` |
| Preview a range | `bat -r 10:50 <file>` |
| Review git changes | `git diff \| delta` |
| Find all usages of X | `rg "X" --type ts -n` |
| Chain search + preview | `rg "X" -l \| xargs bat` |

These are inline Bash tool calls. The right panes update automatically as you work.
