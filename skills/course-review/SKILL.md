---
name: course-review
description: >
  Interactive, lesson-by-lesson course content review for the learning-center
  repository. Reviews LMS lessons and lab assignment.md files against the
  Learning Center style guides and Google Technical Writing best practices.
  Presents findings conversationally one lesson at a time, pausing between
  lessons for the reviewer to absorb results. Read-only: flags issues with
  severity ratings and suggests fixes but never modifies files or leaves PR
  comments. Use when the user says "review course", "course review", "review
  lessons", "review this course", or asks for a content/style review while
  working in the learning-center repository.
---

# Course Review

## Overview

This skill performs an interactive, lesson-by-lesson style and content review of a Learning Center course. It flags issues with severity ratings and suggests fixes but never modifies files or leaves PR comments.

The review runs in up to three focused passes per lesson, each with a different reading strategy:

| Pass | Name | Reading strategy |
|------|------|-----------------|
| 1 | Structure & Format | Scanning for rule violations (mechanical, rules-based) |
| 2 | Writing Quality | Close reading at sentence/paragraph level (judgment-based) |
| 3 | Content & Flow | Reading as a learner would (narrative-level, holistic) |

**Hard constraints:**
- Never modify any file.
- Never leave PR comments or create GitHub issues.
- Always pause after every lesson and wait for explicit user input before continuing.
- Do not flag `{target="_blank"}` on links.

## Prerequisites

- Must be run from inside the `learning-center` repository (typically `~/workspace/learning-center/`).
- Style guides live at `docs/style-guide/` in the repo. Consult them for edge cases not covered by the pass reference files.

## Workflow

### Step 1: Determine course path

1. If the user provided a path argument (e.g., "review courses/getting-started-monitors/"), use it.
1. If the current working directory is inside a `courses/<name>/` directory, infer the course from cwd.
1. Otherwise, list available courses and ask the user which to review.

### Step 2: Check for PR review context

1. Run `gh pr list --head $(git branch --show-current) --json number,url --jq '.[0]'` to detect an open PR for the current branch.
1. If a PR exists, fetch existing review comments: `gh api repos/{owner}/{repo}/pulls/{number}/comments`.
1. Store these comments to display in the course overview (Step 4). Group by file, showing: comment author, file, line number, and a snippet of the comment body.
1. If no PR exists or the directory is not a git repo, skip silently.

### Step 3: Discover and order lessons

Scan the course directory for reviewable content:

1. **LMS lessons**: files matching `lms/*.md`, sorted by numeric prefix (e.g., `01-intro.md`, `02-concepts.md`).
1. **Lab tracks**: directories matching `labs/*/`, sorted by numeric prefix (e.g., `labs/01-setup/`, `labs/02-instrument/`). Each lab track is one review unit. Review all `assignment.md` files within the track together.
1. Merge into a single ordered list by numeric prefix.
1. Note lesson type (LMS or Lab) for each entry.

### Step 4: Present course overview and select passes

Before reviewing any lessons, present:

- Course name and path
- Total lesson count
- Breakdown by type (LMS vs. Lab)
- Ordered lesson list with types and file paths

If PR review comments were found in Step 2, display them under a `## Prior PR Review Comments` heading, grouped by file.

Then prompt for lesson selection:

> Ready to start reviewing? Or would you like to select specific lessons?

If the user selects specific lessons, adjust the review queue accordingly.

Then prompt for pass selection:

> Which review passes would you like to run?
> 1. **Structure & Format** — heading hierarchy, formatting rules, accessibility, style guide compliance
> 1. **Writing Quality** — sentence clarity, active voice, paragraph structure (Google Technical Writing)
> 1. **Content & Flow** — readthrough as a learner, logical flow, step gaps, pacing
>
> Default: all three. Say "1 and 3", "just 2", or "all" to choose.

### Step 5: Load reference files

After pass selection, read only the reference files for the selected passes:

- Pass 1 selected: read `~/.claude/skills/course-review/references/pass-1-structure-format.md`
- Pass 2 selected: read `~/.claude/skills/course-review/references/pass-2-writing-quality.md`
- Pass 3 selected: read `~/.claude/skills/course-review/references/pass-3-content-flow.md`

For edge cases not covered by the pass files, consult the raw style guides in `docs/style-guide/`.

### Step 6: Lesson-by-lesson review loop

For each lesson in the queue:

1. **Announce the lesson**: name, type, and file path(s).
1. **Read the lesson file(s)** using the Read tool.
1. **Run selected passes in order.** For each selected pass:
   - Apply the pass reference file to the lesson content.
   - Which pass rules apply per lesson type:
     - **Pass 1**: All lessons use the "All Content" sections. LMS lessons also use the LMS section. Lab lessons also use the Lab Instructions section.
     - **Pass 2**: All lessons.
     - **Pass 3**: All lessons. Step gap detection applies to Lab lessons only.
1. **Present findings** grouped by pass, using the format below.
1. **Present lesson summary** after all pass findings.
1. **Pause**: Output "Ready for the next lesson? (say **next**, **skip**, or **stop**)" and wait for user input.
   - **next**: continue to the next lesson.
   - **skip**: jump to the lesson after the next.
   - **stop**: end the review and present the course-level summary.

### Step 7: Course-level summary

After all lessons are reviewed (or the user says "stop"), present:

- Total findings by severity across all reviewed lessons (critical: x, major: x, minor: x)
- Lessons with the most findings
- Top recurring issue patterns (e.g., "Passive voice appears in 4 of 6 lessons")

---

## Finding Format

Before listing detailed findings for a lesson, output a summary table with a `Pass` column:

```text
| # | Pass | Line(s) | Severity | Rule |
|---|------|---------|----------|------|
| 1 | 1    | 12      | critical | No H1 headings in LMS |
| 2 | 2    | 23-25   | major    | One idea per sentence |
| 3 | 3    | 34-40   | major    | Missing context switch |
```

Then group detailed findings by pass, with a pass header for each:

```text
## Pass 1: Structure & Format
[detailed findings]

## Pass 2: Writing Quality
[detailed findings]

## Pass 3: Content & Flow
[detailed findings]
```

Use this exact format for each detailed finding:

```text
### Finding [N] - [critical/major/minor]
**File:** `path/to/file.md` | **Line(s):** [line number or range]
**Pass:** [1 / 2 / 3] | **Rule:** [Rule name from the pass reference file]
**Issue:** [What is wrong, in one sentence]
> [Quoted offending text, verbatim from the file]
**Suggested fix:**
> [Corrected text or a description of the fix needed]
```

Group related findings when the same issue appears multiple times in one lesson and the same pass. For example, if passive voice appears on lines 12, 34, and 67, report it as a single finding with all three line numbers.

After all pass findings for a lesson:

```text
**Lesson summary:** [N] findings (critical: x, major: x, minor: x)

Ready for the next lesson? (say **next**, **skip**, or **stop**)
```

If a lesson has no findings across all selected passes, say so explicitly:

```text
**Lesson summary:** No findings. This lesson looks great.

Ready for the next lesson? (say **next**, **skip**, or **stop**)
```

---

## Severity Definitions

| Severity | Definition |
|----------|------------|
| `critical` | Incorrect information, broken instructions, missing steps that block a learner, accessibility violations (missing alt text, skipped heading ranks, H1 in LMS). |
| `major` | Style guide violations affecting clarity or professionalism: wrong terminology, passive voice in instructions, heading case violations, missing activity/lab summaries, wrong navigation format. |
| `minor` | Style guide violations that don't impede learning (missing Oxford comma, em dash spacing, minor formatting) and improvement suggestions (sentence clarity, word choice, paragraph structure). |

---

## Interaction Rules

- Never modify files.
- Never leave PR comments or create issues.
- Do not flag `{target="_blank"}` on links.
- Pause after every lesson and wait for explicit user input ("next", "skip", or "stop").
- When referencing rules in findings, use the exact heading text from the pass reference file.
- For edge cases not in the pass reference files, consult the raw style guide files in `docs/style-guide/`.
- Group related findings when the same issue recurs in one lesson and the same pass.
- If a lesson has no issues, say so and move on.
- Only report findings you are confident about. Do not mention an issue and then retract it. If you are unsure whether something is a violation, silently skip it. Never say "on second thought" or "actually, this might be fine."
