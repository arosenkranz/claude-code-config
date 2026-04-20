---
name: refine
description: Iterative visual/UI refinement mode. Make one change at a time, describe it, wait for feedback. Use when tuning visual effects, layouts, or styling. Invoke with /refine.
---

# Refine Workflow (/refine)

Iterative visual and UI refinement loop. Make one change, describe it, wait for feedback, adjust. Repeat until approved. Invoke with `/refine`.

## When to Use

Use `/refine` when tuning visual appearance, styling, layout, animations, shaders, or any UI element that requires subjective evaluation. This skill prevents the overcorrection cycle (too subtle -> too intense -> still wrong) by enforcing small, deliberate steps.

## The Loop

### Step 1: Make ONE change

Make a single, focused modification. Examples of one change:
- Adjust a single CSS property (font size, color, spacing)
- Modify one shader parameter (intensity, blend mode, frequency)
- Change one layout property (flex direction, grid gap, alignment)

Never batch multiple visual changes together. If the task requires several changes, make them one at a time through the loop.

### Step 2: Describe what changed

Tell the user:
- What specifically changed (property, value, file)
- Why this value was chosen
- What to look for when evaluating

### Step 3: Wait for feedback

Stop and wait for the user to respond. Do not proceed until they provide feedback. Valid responses:

- "looks good" / "done" / "approved" -> exit the loop
- "too much" / "too intense" / "dial it back" -> reduce by ~30%
- "too little" / "too subtle" / "more" -> increase by ~30%
- "wrong direction" / "try something else" -> revert and try a different approach
- Specific feedback -> apply exactly as described

### Step 4: Adjust proportionally

When adjusting based on feedback:
- **"too much"** -> reduce by approximately 30%, not 90%. Overcorrecting wastes rounds.
- **"too little"** -> increase by approximately 30%, not 300%.
- **"perfect but also change X"** -> make only the X change, do not touch the approved part.

### Step 5: Repeat

Go back to Step 1. Continue until the user explicitly approves.

## Constraints

- **One change per iteration** — never batch visual changes
- **Match the project's existing theme and palette** — do not introduce new colors or styles without asking
- **No decorative additions** — no emoji, per-item color coding, gradients, or ornamental elements unless the user explicitly requests them
- **Shader/WebGL caution** — for changes to `.glsl`, `.frag`, `.vert` files or Three.js shader code, effects compound quickly. Test each change individually and describe the expected visual impact before applying.
- **Never assume done** — keep the loop until the user says "looks good", "done", or "approved"
- **Preserve working state** — if a change breaks rendering or layout, revert immediately before trying the next approach
