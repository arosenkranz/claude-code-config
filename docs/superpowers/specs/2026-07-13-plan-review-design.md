# Design: Interactive Plan Review (`plan-review` skill)

## Problem

CLAUDE.md Guardrail #9 states plans should be pressure-tested by the Goldeneye agents and presented as something the user can annotate directly, rather than chat text — but no concrete mechanism exists yet. This design builds that mechanism.

## Goals

- Before a non-trivial plan is presented for approval, run it past `trevelyan` (adversarial reviewer) and `m` (planning/architecture) for critique.
- Present the plan as a self-contained HTML page the user can open in a real browser, read the critique, and leave feedback per-section plus a general comment.
- Get that feedback back into the conversation via copy/paste (no file-watching, no server).

## Non-goals

- Not replacing the existing `writing-plans` (superpowers) plan format — this skill consumes an already-written plan file and produces a review artifact from it.
- Not a general-purpose artifact builder — no React/build step. Single static HTML file, vanilla JS.
- Not fixing the stale `/spec-and-plan` reference in Guardrail #3 (that skill doesn't exist in this repo) — noted as a separate, pre-existing gap, out of scope here.

## Architecture

New skill: `plan-review`, added to the `workflow-skills` plugin at `plugins/workflow-skills/skills/plan-review/`.

Invocation:
1. **Automatic** — Guardrail #9 instructs future sessions to invoke this skill before presenting a non-trivial plan for approval.
2. **Explicit** — `/plan-review <path-to-plan.md>` to re-run review on an existing plan.

Flow:

```
plan.md
  -> Agent(trevelyan, critique prompt) \
  -> Agent(m, critique prompt)          }  run in parallel
  -> combine critique text
  -> generator script (plan.md + critique -> HTML)
  -> open /tmp/claude-plan-review-<slug>-<timestamp>.html   (macOS `open`)
  -> user reads, annotates, clicks "Copy Feedback"
  -> user pastes Markdown feedback blob into chat
  -> Claude incorporates feedback per Guardrail #2 (iterate/re-approve)
```

## Components

### 1. Critique step

Spawn `trevelyan` and `m` in parallel via the Agent tool against the plan file content. Prompt each to critique the plan *as a plan* — risks, gaps, scope questions, sequencing issues — not to review code (no code exists yet at plan stage). Combine both responses into one "Goldeneye Review" block, keeping each agent's voice/output separately labeled (Trevelyan / M) rather than merging into one blob.

If either agent call fails or times out, proceed with whatever is available; render "critique unavailable" for the missing one rather than blocking the whole flow.

### 2. HTML generator

Language: Python (matches this repo's precedent — `skill-creator`'s scripts are Python; this repo doesn't use Node for skill-internal scripts).

Script: `plugins/workflow-skills/skills/plan-review/scripts/build_review.py`

Input: plan markdown file path, critique text (trevelyan + m).
Output: one self-contained `.html` file (inline `<style>` and `<script>`, no external assets).

Behavior:
- Parse the plan into sections by splitting on `##`-level headings. If no `##` headings exist, treat the entire file as one section titled "Plan".
- Escape all markdown content as HTML-safe text (avoid injection from plan content — even though it's locally generated, still don't blindly interpolate raw strings into HTML/script contexts).
- Render:
  - Header: plan title (first `#` heading or filename), generation timestamp, source file path
  - Goldeneye Review panel (collapsible, expanded by default): Trevelyan's critique and M's critique in labeled subsections
  - One card per plan section: original content + a `<textarea>` for feedback on that section (collapsed placeholder, expands on focus)
  - General feedback textarea (not tied to a section)
  - Approve / Request changes radio toggle
  - Sticky "Copy Feedback" button

### 3. Copy Feedback behavior (client-side JS in the generated HTML)

On click:
1. Serialize: approve/changes choice, general feedback, and each non-empty per-section textarea (labeled by section heading) into a Markdown blob.
2. Try `navigator.clipboard.writeText(blob)`. On success, show "Copied!" confirmation near the button.
3. On failure (thrown exception, e.g. clipboard blocked on `file://`), reveal a `<textarea readonly>` pre-filled with the same blob, focused and select-all'd, so the user can copy manually instead.

### 4. Skill definition (`SKILL.md`)

Documents the orchestration sequence above: run critique agents → generate HTML via `build_review.py` → `open <path>` → tell the user to review, annotate, and paste feedback back → wait for the pasted response before continuing.

## Data flow

`plan.md` (text) → 2 parallel Agent calls → critique text (2 strings) → `build_review.py` (plan + critique in, HTML out) → `/tmp/claude-plan-review-<slug>-<timestamp>.html` → opened via macOS `open` in the user's default browser (human-driven — not `agent-browser`, which is for Claude-driven automation, not applicable here) → clipboard → pasted into chat → Claude reads the pasted Markdown and continues the plan-refinement loop.

## Error handling & edge cases

- Plan has no `##` headings → single fallback section, not an error.
- Clipboard API blocked → visible fallback textarea for manual copy.
- Critique agent failure → proceed with partial critique, label the gap.
- Multiple reviews per session → timestamped filenames avoid collisions in `/tmp`.
- macOS-only (`open` command) — consistent with the rest of this environment; not a cross-platform concern.

## Testing approach

Personal tooling, not shipped product code — no automated test suite. Verification is manual: generate a real HTML file from a sample plan with sample critique text, open it in an actual browser, and confirm sections render, textareas work, the copy button produces correct Markdown, and the fallback textarea appears when clipboard access is forced to fail.

## Open items for implementation plan

- Exact critique prompt wording for `trevelyan` and `m` (plan-mode framing, not code-review framing).
- Slug generation for filenames (derive from plan title / file basename).
- Whether Guardrail #9's wording in `~/.claude/CLAUDE.md` needs updating to name this skill explicitly (recommended: yes, replace "tooling for this isn't built yet" language).
