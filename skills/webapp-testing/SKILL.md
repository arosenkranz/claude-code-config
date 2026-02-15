---
name: webapp-testing
description: Toolkit for interacting with and testing local web applications using agent-browser. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.
allowed-tools: Bash(agent-browser:*)
---

# Web Application Testing

Use `agent-browser` CLI for all browser automation and web app testing.

## Core Workflow

1. Navigate: `agent-browser open <url>`
2. Snapshot: `agent-browser snapshot -i` (returns elements with refs like `@e1`, `@e2`)
3. Interact using refs from the snapshot
4. Re-snapshot after navigation or significant DOM changes

## Decision Tree

```
User task -> Is it static HTML?
    |-- Yes -> Read HTML file directly, or open with agent-browser
    |
    |-- No (dynamic webapp) -> Is the server already running?
        |-- No -> Start server first, then use agent-browser
        |
        |-- Yes -> Reconnaissance-then-action:
            1. agent-browser open <url>
            2. agent-browser wait --load networkidle
            3. agent-browser snapshot -i
            4. Interact using @refs from snapshot
```

## Quick Reference

```bash
agent-browser open <url>              # Navigate
agent-browser snapshot -i             # Get interactive elements with refs
agent-browser click @e1               # Click by ref
agent-browser fill @e2 "text"         # Fill input by ref
agent-browser screenshot page.png     # Take screenshot
agent-browser wait --load networkidle # Wait for page load
agent-browser close                   # Close browser
```

## Example: Form Testing

```bash
agent-browser open http://localhost:5173/form
agent-browser snapshot -i
# Output: textbox "Email" [ref=e1], textbox "Password" [ref=e2], button "Submit" [ref=e3]

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i  # Verify result
```

## Common Pitfall

- **Don't** snapshot before the page has loaded on dynamic apps
- **Do** use `agent-browser wait --load networkidle` before inspecting

## Best Practices

- Always snapshot before interacting to get current @refs
- Use `--json` flag for machine-readable output
- Use semantic locators as alternatives: `agent-browser find role button click --name "Submit"`
- Save auth state with `agent-browser state save auth.json` for reuse
