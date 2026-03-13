---
name: verify-ui
description: Use when asked to verify UI changes, check the frontend visually, confirm a page looks correct, test UI interactions, or validate that recent frontend changes work. Invoke via /verify-ui. Accepts optional path (e.g. /verify-ui /dashboard) and optional "deep" argument for interactive testing.
---

# verify-ui — Browser-Based UI Verification

Visually verify UI changes using agent-browser: screenshot + accessibility check + error scan. Add `deep` for interactive testing.

## Usage

```
/verify-ui                      # Quick mode: screenshot + a11y + errors
/verify-ui /dashboard           # Quick mode at specific path
/verify-ui deep                 # Deep mode: also clicks, fills, navigates
/verify-ui /dashboard deep      # Deep mode at specific path
```

## Step 1: Detect Project & Port

Read `package.json` scripts to find the dev command and port:

```bash
cat package.json | grep -E '"dev"|"start"'
```

**Framework port defaults:**

| Framework | Default Port |
|-----------|-------------|
| Astro     | 4321        |
| Vite      | 5173        |
| Next.js   | 3000        |
| Generic   | 3000        |

Check `--port` flags in dev scripts first, fall back to framework defaults.

## Step 2: Check if Server is Running

```bash
lsof -i :<port> | grep LISTEN
```

- **Running** → skip to Step 3
- **Not running** → detect package manager and start:

```bash
# Detect package manager from lockfile
ls bun.lock 2>/dev/null && PM=bun || \
ls pnpm-lock.yaml 2>/dev/null && PM=pnpm || \
ls yarn.lock 2>/dev/null && PM=yarn || PM=npm

# Start in background
$PM run dev &
```

Then poll until ready (up to 30s):
```bash
agent-browser open http://localhost:<port>
```

**Track** whether you started the server so you can offer cleanup at the end.

## Step 3: Navigate

```bash
# Default: project root
agent-browser open http://localhost:<port>

# With path argument
agent-browser open http://localhost:<port>/the-path

# With full URL
agent-browser open <url>
```

Wait for page load:
```bash
agent-browser wait --load networkidle
```

## Step 4: Quick Verification (always run)

Run these three checks in sequence:

**4a. Screenshot**
```bash
agent-browser screenshot
```
Analyze the screenshot: layout issues, broken styles, missing content, visual regressions.

**4b. Accessibility snapshot**
```bash
agent-browser snapshot -i
```
Check for: interactive elements present, proper labels, navigation structure, no missing headings.

**4c. Console errors**
```bash
agent-browser errors
```
Flag any JS errors, failed network requests, or console warnings.

**4d. Report**
Summarize inline:
- Screenshot: what you see (layout, content, styles)
- Elements found: key interactive components
- Errors: any JS errors (NONE is good)
- Issues: anything that looks broken

## Step 5: Deep Verification (only when `deep` argument passed)

All of quick mode, plus:

**5a. Identify interactive elements**
From the snapshot refs (`@e1`, `@e2`, etc.), identify:
- Primary CTA buttons → click them, screenshot after
- Navigation links → click, verify URL changes, go back
- Forms → fill with test data, submit, check validation

**5b. Click primary buttons**
```bash
agent-browser click @e<ref>
agent-browser wait --load networkidle
agent-browser screenshot
agent-browser errors
```

**5c. Test forms**
```bash
agent-browser fill @e<ref> "test@example.com"  # email fields
agent-browser fill @e<ref> "Test Input"          # text fields
agent-browser click @e<submit-ref>
agent-browser wait --load networkidle
agent-browser screenshot
```

**5d. Check responsive behavior**
```bash
agent-browser set viewport 375 812   # Mobile
agent-browser screenshot

agent-browser set viewport 768 1024  # Tablet
agent-browser screenshot

agent-browser set viewport 1440 900  # Desktop
agent-browser screenshot
```

**5e. Report**
Include interaction outcomes, navigation flow, form behavior, and responsive screenshots.

## Step 6: Cleanup

If you started the dev server:
```bash
kill %1  # or the PID you tracked
```

Always close the browser session:
```bash
agent-browser close
```

## Common Issues

| Symptom | Fix |
|---------|-----|
| Port already in use | Check `lsof -i :<port>` — something else may be running there |
| `agent-browser open` times out | Server may need more time to start; wait and retry |
| Screenshot is blank | Wait for `networkidle` before screenshotting |
| No interactive elements in snapshot | Page may be fully static; that's OK — report what you see |
| Server won't start | Check `package.json` dev script, report the error |
