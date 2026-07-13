# Interactive Plan Review Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a `plan-review` skill that runs a plan past the `trevelyan` and `m` Goldeneye agents, renders the plan + critique as a self-contained interactive HTML page, and lets the user leave per-section and general feedback that copies to clipboard as Markdown for pasting back into chat.

**Architecture:** A pure-stdlib Python script (`build_review.py`) parses a plan markdown file into sections, escapes all content, and renders one static HTML file with inline CSS/JS (no build step, no external assets). A new `SKILL.md` in the `workflow-skills` plugin orchestrates: spawn `trevelyan` + `m` critique agents in parallel, write their output to temp files, invoke the script, `open` the result. `~/.claude/CLAUDE.md` Guardrail #9 is updated to name this skill explicitly.

**Tech Stack:** Python 3 standard library only (`re`, `html`, `os`, `datetime`, `argparse`), vanilla JS/CSS in the generated HTML, macOS `open` command, pytest for the Python unit tests.

## Global Constraints

- macOS only (uses the `open` command) — matches this environment.
- No external Python dependencies — stdlib only (`re`, `html`, `os`, `datetime`, `argparse`).
- No build step for the HTML — one self-contained file, inline CSS/JS, no bundler.
- Generated files are written to `/tmp/claude-plan-review-<slug>-<timestamp>.html`.
- All interpolated plan/critique content must be HTML-escaped before being placed into the generated HTML (via `html.escape(text, quote=True)`).
- Plan sections are split on level-2 (`## `) markdown headings only; a plan with no such headings becomes a single fallback section titled `"Plan"`.

---

### Task 1: Section parsing, slugify, and HTML escaping helpers

**Files:**
- Create: `plugins/workflow-skills/skills/plan-review/scripts/build_review.py`
- Test: `plugins/workflow-skills/skills/plan-review/scripts/test_build_review.py`

**Interfaces:**
- Produces: `parse_sections(markdown_text: str) -> list[dict]` — each dict is `{"heading": str, "content": str}`. Returns `[{"heading": "Plan", "content": markdown_text.strip()}]` if no `## ` headings are found.
- Produces: `slugify(name: str, max_len: int = 40) -> str` — lowercase, non-alphanumeric runs replaced with `-`, stripped of leading/trailing `-`, truncated to `max_len`, falls back to `"plan"` if the result is empty.
- Produces: `escape_html(text: str) -> str` — wraps `html.escape(text, quote=True)`.

- [ ] **Step 1: Write the failing tests**

Create `plugins/workflow-skills/skills/plan-review/scripts/test_build_review.py`:

```python
from build_review import parse_sections, slugify, escape_html


def test_parse_sections_splits_on_level_two_headings():
    text = "# Title\n\nIntro text.\n\n## First\ncontent one\n\n## Second\ncontent two\n"
    sections = parse_sections(text)
    assert len(sections) == 3
    assert sections[0]["heading"] == "Plan"
    assert "Title" in sections[0]["content"]
    assert sections[1]["heading"] == "First"
    assert sections[1]["content"] == "content one"
    assert sections[2]["heading"] == "Second"
    assert sections[2]["content"] == "content two"


def test_parse_sections_no_headings_returns_single_fallback_section():
    text = "Just a flat plan with no headings at all."
    sections = parse_sections(text)
    assert sections == [{"heading": "Plan", "content": text}]


def test_parse_sections_ignores_level_three_headings():
    text = "## Phase 1\n### Step A\ndetail\n"
    sections = parse_sections(text)
    assert len(sections) == 1
    assert sections[0]["heading"] == "Phase 1"
    assert "### Step A" in sections[0]["content"]


def test_slugify_basic():
    assert slugify("Add Plan Review Skill") == "add-plan-review-skill"


def test_slugify_truncates():
    result = slugify("a" * 50, max_len=10)
    assert result == "a" * 10


def test_slugify_empty_input_returns_fallback():
    assert slugify("!!!") == "plan"


def test_escape_html_escapes_special_characters():
    assert escape_html("<script>&\"'") == "&lt;script&gt;&amp;&quot;&#x27;"
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd plugins/workflow-skills/skills/plan-review/scripts && python3 -m pytest test_build_review.py -v`
Expected: FAIL / ERROR — `ModuleNotFoundError: No module named 'build_review'` (file doesn't exist yet).

- [ ] **Step 3: Implement the helpers**

Create `plugins/workflow-skills/skills/plan-review/scripts/build_review.py`:

```python
import html
import re


def parse_sections(markdown_text: str) -> list[dict]:
    lines = markdown_text.splitlines()
    sections = []
    current_heading = None
    current_lines = []

    def flush():
        if current_heading is not None or current_lines:
            heading = current_heading if current_heading is not None else "Plan"
            content = "\n".join(current_lines).strip()
            sections.append({"heading": heading, "content": content})

    for line in lines:
        if line.startswith("## "):
            flush()
            current_heading = line[3:].strip()
            current_lines = []
        else:
            current_lines.append(line)
    flush()

    if not sections:
        return [{"heading": "Plan", "content": markdown_text.strip()}]
    return sections


def slugify(name: str, max_len: int = 40) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    return slug[:max_len].strip("-") or "plan"


def escape_html(text: str) -> str:
    return html.escape(text, quote=True)
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd plugins/workflow-skills/skills/plan-review/scripts && python3 -m pytest test_build_review.py -v`
Expected: PASS — 7 tests pass.

- [ ] **Step 5: Commit**

```bash
git add plugins/workflow-skills/skills/plan-review/scripts/build_review.py plugins/workflow-skills/skills/plan-review/scripts/test_build_review.py
git commit -m "feat: add plan-review section parsing and formatting helpers"
```

---

### Task 2: HTML rendering with embedded critique panel and feedback UI

**Files:**
- Modify: `plugins/workflow-skills/skills/plan-review/scripts/build_review.py`
- Modify: `plugins/workflow-skills/skills/plan-review/scripts/test_build_review.py`

**Interfaces:**
- Consumes: `escape_html(text: str) -> str` from Task 1.
- Produces: `render_html(plan_title: str, source_path: str, generated_at: str, critique: dict, sections: list) -> str` — `critique` is `{"trevelyan": str | None, "m": str | None}`; `sections` is the list returned by `parse_sections`. Returns a complete HTML document as a string. Missing critique (`None`) renders as `"Critique unavailable."` for that agent. The returned HTML always contains the literal string `"Copy Feedback"` (button label) and `"navigator.clipboard.writeText"` (used by later tasks/tests to confirm the feedback UI is present).

- [ ] **Step 1: Write the failing test**

Append to `plugins/workflow-skills/skills/plan-review/scripts/test_build_review.py`:

```python
from build_review import render_html


def test_render_html_includes_sections_and_critique_and_escapes_content():
    sections = [{"heading": "Phase 1 <script>", "content": "Do the thing & verify."}]
    html_out = render_html(
        plan_title="Sample Plan",
        source_path="/tmp/sample.md",
        generated_at="2026-07-13 10:00:00",
        critique={"trevelyan": "Watch for race conditions.", "m": None},
        sections=sections,
    )
    assert "Sample Plan" in html_out
    assert "Phase 1 &lt;script&gt;" in html_out
    assert "Do the thing &amp; verify." in html_out
    assert "Watch for race conditions." in html_out
    assert "Critique unavailable." in html_out
    assert "Copy Feedback" in html_out
    assert "navigator.clipboard.writeText" in html_out
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd plugins/workflow-skills/skills/plan-review/scripts && python3 -m pytest test_build_review.py -v`
Expected: FAIL — `ImportError: cannot import name 'render_html'`.

- [ ] **Step 3: Implement `render_html`**

Append to `plugins/workflow-skills/skills/plan-review/scripts/build_review.py`:

```python
def render_html(plan_title: str, source_path: str, generated_at: str, critique: dict, sections: list) -> str:
    trevelyan_text = critique.get("trevelyan")
    m_text = critique.get("m")

    def critique_block(label, text):
        if text:
            return f'<div class="critique-agent"><h3>{escape_html(label)}</h3><pre>{escape_html(text)}</pre></div>'
        return f'<div class="critique-agent critique-missing"><h3>{escape_html(label)}</h3><p>Critique unavailable.</p></div>'

    critique_html = critique_block("Trevelyan", trevelyan_text) + critique_block("M", m_text)

    section_blocks = []
    for section in sections:
        heading = escape_html(section["heading"])
        content = escape_html(section["content"])
        section_blocks.append(f'''
        <section class="plan-section">
          <h2>{heading}</h2>
          <pre>{content}</pre>
          <label class="feedback-label">Feedback on this section</label>
          <textarea class="section-feedback" data-heading="{heading}" placeholder="Leave feedback on this section..."></textarea>
        </section>''')
    sections_html = "\n".join(section_blocks)

    return f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Plan Review: {escape_html(plan_title)}</title>
<style>
  body {{ font-family: -apple-system, BlinkMacSystemFont, sans-serif; max-width: 860px; margin: 0 auto; padding: 2rem 1.5rem 6rem; line-height: 1.5; color: #1a1a1a; }}
  header {{ margin-bottom: 2rem; border-bottom: 1px solid #ddd; padding-bottom: 1rem; }}
  header p {{ color: #666; font-size: 0.9rem; margin: 0.2rem 0; }}
  .critique-panel {{ background: #fff7e6; border: 1px solid #f0c36d; border-radius: 8px; padding: 1rem 1.25rem; margin-bottom: 2rem; }}
  .critique-agent {{ margin-bottom: 1rem; }}
  .critique-agent h3 {{ margin: 0 0 0.4rem; }}
  .critique-missing p {{ color: #999; font-style: italic; }}
  .plan-section {{ border: 1px solid #ddd; border-radius: 8px; padding: 1rem 1.25rem; margin-bottom: 1.25rem; }}
  .plan-section h2 {{ margin-top: 0; }}
  pre {{ white-space: pre-wrap; word-wrap: break-word; font-family: ui-monospace, monospace; font-size: 0.9rem; background: #fafafa; padding: 0.75rem; border-radius: 6px; }}
  .feedback-label {{ display: block; font-size: 0.85rem; color: #555; margin-top: 0.75rem; margin-bottom: 0.25rem; }}
  textarea {{ width: 100%; min-height: 3rem; box-sizing: border-box; font-family: inherit; font-size: 0.95rem; padding: 0.5rem; border: 1px solid #ccc; border-radius: 6px; }}
  .general-feedback, .decision {{ margin-bottom: 1.5rem; }}
  .copy-bar {{ position: fixed; bottom: 0; left: 0; right: 0; background: #fff; border-top: 1px solid #ddd; padding: 1rem 1.5rem; display: flex; align-items: center; gap: 1rem; justify-content: center; }}
  #copy-btn {{ background: #1a1a1a; color: #fff; border: none; padding: 0.6rem 1.2rem; border-radius: 6px; font-size: 0.95rem; cursor: pointer; }}
  #copy-status {{ color: #2a7a2a; font-size: 0.9rem; }}
  #fallback-output {{ display: none; width: 100%; max-width: 860px; margin: 0.5rem auto 0; }}
</style>
</head>
<body>
<header>
  <h1>{escape_html(plan_title)}</h1>
  <p>Source: {escape_html(source_path)}</p>
  <p>Generated: {escape_html(generated_at)}</p>
</header>

<details class="critique-panel" open>
  <summary><strong>Goldeneye Review</strong> (trevelyan + m)</summary>
  {critique_html}
</details>

{sections_html}

<div class="general-feedback">
  <h2>General Feedback</h2>
  <textarea id="general-feedback" placeholder="Overall feedback not tied to one section..."></textarea>
</div>

<div class="decision">
  <h2>Decision</h2>
  <label><input type="radio" name="decision" value="approve" checked> Approve</label>
  <label style="margin-left:1.5rem"><input type="radio" name="decision" value="changes"> Request changes</label>
</div>

<textarea id="fallback-output" readonly rows="10"></textarea>

<div class="copy-bar">
  <button id="copy-btn">Copy Feedback</button>
  <span id="copy-status"></span>
</div>

<script>
function buildFeedbackMarkdown() {{
  const decision = document.querySelector('input[name="decision"]:checked').value;
  const general = document.getElementById('general-feedback').value.trim();
  const sectionInputs = document.querySelectorAll('.section-feedback');
  let lines = [];
  lines.push('## Plan Feedback');
  lines.push('');
  lines.push('Decision: ' + (decision === 'approve' ? 'Approve' : 'Request changes'));
  lines.push('');
  if (general) {{
    lines.push('### General');
    lines.push(general);
    lines.push('');
  }}
  sectionInputs.forEach(function (el) {{
    const text = el.value.trim();
    if (text) {{
      lines.push('### Section: ' + el.dataset.heading);
      lines.push(text);
      lines.push('');
    }}
  }});
  return lines.join('\\n').trim();
}}

document.getElementById('copy-btn').addEventListener('click', function () {{
  const md = buildFeedbackMarkdown();
  const status = document.getElementById('copy-status');
  const fallback = document.getElementById('fallback-output');
  navigator.clipboard.writeText(md).then(function () {{
    status.textContent = 'Copied!';
    fallback.style.display = 'none';
    setTimeout(function () {{ status.textContent = ''; }}, 2000);
  }}).catch(function () {{
    fallback.value = md;
    fallback.style.display = 'block';
    fallback.focus();
    fallback.select();
    status.textContent = 'Clipboard unavailable — copy manually below';
  }});
}});
</script>
</body>
</html>'''
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd plugins/workflow-skills/skills/plan-review/scripts && python3 -m pytest test_build_review.py -v`
Expected: PASS — 8 tests pass.

- [ ] **Step 5: Commit**

```bash
git add plugins/workflow-skills/skills/plan-review/scripts/build_review.py plugins/workflow-skills/skills/plan-review/scripts/test_build_review.py
git commit -m "feat: render plan-review HTML with critique panel and feedback UI"
```

---

### Task 3: `build_review` file writer and CLI entry point

**Files:**
- Modify: `plugins/workflow-skills/skills/plan-review/scripts/build_review.py`
- Modify: `plugins/workflow-skills/skills/plan-review/scripts/test_build_review.py`

**Interfaces:**
- Consumes: `parse_sections`, `render_html`, `slugify` from Tasks 1–2.
- Produces: `build_review(plan_path: str, trevelyan_critique: str | None, m_critique: str | None, output_dir: str = "/tmp") -> str` — reads the plan file, writes `<output_dir>/claude-plan-review-<slug>-<timestamp>.html`, returns the written path.
- Produces: CLI `python3 build_review.py <plan_path> [--trevelyan-file PATH] [--m-file PATH] [--output-dir DIR]` — prints the generated file path to stdout. This is what `SKILL.md` (Task 5) invokes via `Bash`.

- [ ] **Step 1: Write the failing test**

Append to `plugins/workflow-skills/skills/plan-review/scripts/test_build_review.py`:

```python
import os

from build_review import build_review


def test_build_review_writes_html_file_and_returns_path(tmp_path):
    plan_file = tmp_path / "sample-plan.md"
    plan_file.write_text("# My Sample Plan\n\n## Overview\nDo the thing.\n")

    output_path = build_review(
        plan_path=str(plan_file),
        trevelyan_critique="Looks risky.",
        m_critique=None,
        output_dir=str(tmp_path),
    )

    assert os.path.exists(output_path)
    assert output_path.startswith(str(tmp_path))
    content = open(output_path, encoding="utf-8").read()
    assert "My Sample Plan" in content
    assert "Looks risky." in content
    assert "Critique unavailable." in content
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd plugins/workflow-skills/skills/plan-review/scripts && python3 -m pytest test_build_review.py -v`
Expected: FAIL — `ImportError: cannot import name 'build_review'`.

- [ ] **Step 3: Implement `build_review` and the CLI**

Append to `plugins/workflow-skills/skills/plan-review/scripts/build_review.py`:

```python
import argparse
import datetime
import os


def build_review(plan_path: str, trevelyan_critique: str | None, m_critique: str | None, output_dir: str = "/tmp") -> str:
    with open(plan_path, "r", encoding="utf-8") as f:
        plan_text = f.read()

    sections = parse_sections(plan_text)

    stripped = plan_text.strip()
    first_line = stripped.splitlines()[0] if stripped else ""
    plan_title = first_line.lstrip("#").strip() if first_line.startswith("#") else os.path.basename(plan_path)

    generated_at = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    slug = slugify(plan_title)
    output_path = os.path.join(output_dir, f"claude-plan-review-{slug}-{timestamp}.html")

    html_out = render_html(
        plan_title=plan_title,
        source_path=plan_path,
        generated_at=generated_at,
        critique={"trevelyan": trevelyan_critique, "m": m_critique},
        sections=sections,
    )

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(html_out)

    return output_path


def _read_optional_file(path):
    if not path:
        return None
    with open(path, "r", encoding="utf-8") as f:
        return f.read().strip() or None


def main():
    parser = argparse.ArgumentParser(description="Generate an interactive HTML plan review page.")
    parser.add_argument("plan_path", help="Path to the plan markdown file")
    parser.add_argument("--trevelyan-file", help="Path to a file containing trevelyan's critique text")
    parser.add_argument("--m-file", help="Path to a file containing m's critique text")
    parser.add_argument("--output-dir", default="/tmp", help="Directory to write the generated HTML file (default: /tmp)")
    args = parser.parse_args()

    trevelyan_critique = _read_optional_file(args.trevelyan_file)
    m_critique = _read_optional_file(args.m_file)

    output_path = build_review(args.plan_path, trevelyan_critique, m_critique, args.output_dir)
    print(output_path)


if __name__ == "__main__":
    main()
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd plugins/workflow-skills/skills/plan-review/scripts && python3 -m pytest test_build_review.py -v`
Expected: PASS — 9 tests pass.

- [ ] **Step 5: Manually verify the CLI end-to-end**

Run:
```bash
cd plugins/workflow-skills/skills/plan-review/scripts
echo "Watch for race conditions in step 3." > /tmp/trevelyan-test.txt
python3 build_review.py test_build_review.py --trevelyan-file /tmp/trevelyan-test.txt --output-dir /tmp
```
Expected: prints a path like `/tmp/claude-plan-review-test-build-review-py-<timestamp>.html` (the CLI treats its own test file as the "plan" here purely to confirm the command runs end-to-end — any text file works). Verify the file exists: `ls -la /tmp/claude-plan-review-*.html`.

- [ ] **Step 6: Commit**

```bash
git add plugins/workflow-skills/skills/plan-review/scripts/build_review.py plugins/workflow-skills/skills/plan-review/scripts/test_build_review.py
git commit -m "feat: add build_review file writer and CLI entry point"
```

---

### Task 4: Manual browser verification of the generated HTML

**Files:** None created/modified — this task exercises the output of Tasks 1–3 in a real browser, per this project's stated testing approach (personal tooling; manual verification instead of an automated UI test suite).

**Interfaces:**
- Consumes: the CLI from Task 3.

- [ ] **Step 1: Generate a realistic sample review page**

```bash
cd plugins/workflow-skills/skills/plan-review/scripts
cat > /tmp/sample-plan.md <<'EOF'
# Sample Feature Plan

## Overview
Add a caching layer in front of the slow API.

## Phase 1: Cache implementation
Add an in-memory LRU cache keyed by request params.

## Phase 2: Invalidation
Invalidate entries on write.
EOF

echo "Cache invalidation on write is risky if writes race with reads — what's the locking story?" > /tmp/trevelyan-sample.txt
echo "Phasing looks right. Confirm cache size limits before Phase 1 ships." > /tmp/m-sample.txt

python3 build_review.py /tmp/sample-plan.md --trevelyan-file /tmp/trevelyan-sample.txt --m-file /tmp/m-sample.txt --output-dir /tmp
```
Expected: prints `/tmp/claude-plan-review-sample-feature-plan-<timestamp>.html`.

- [ ] **Step 2: Open it and verify the happy path**

```bash
open /tmp/claude-plan-review-sample-feature-plan-*.html
```
In the browser, confirm: the Goldeneye Review panel shows both Trevelyan's and M's critique text; three plan sections render (Overview, Phase 1, Phase 2) each with its own feedback textarea; type text into one section's textarea and the general feedback box; click "Copy Feedback"; confirm the "Copied!" status appears. Paste the clipboard contents into a text editor and confirm it's a Markdown blob with a `Decision:` line, your general feedback under `### General`, and your section feedback under `### Section: <heading>`.

- [ ] **Step 3: Verify the clipboard-failure fallback**

In the browser's DevTools console (on the same open page), run:
```js
navigator.clipboard.writeText = () => Promise.reject(new Error("blocked"));
```
Click "Copy Feedback" again. Confirm the status text changes to "Clipboard unavailable — copy manually below" and a read-only textarea appears below the button, pre-filled with the same Markdown blob, focused and selected.

- [ ] **Step 4: Clean up test artifacts**

```bash
rm -f /tmp/claude-plan-review-*.html /tmp/sample-plan.md /tmp/trevelyan-sample.txt /tmp/m-sample.txt /tmp/trevelyan-test.txt
```

No commit for this task — nothing in the repo changed.

---

### Task 5: `plan-review` SKILL.md

**Files:**
- Create: `plugins/workflow-skills/skills/plan-review/SKILL.md`

**Interfaces:**
- Consumes: the CLI from Task 3 (`python3 <skill_dir>/scripts/build_review.py ...`).
- Consumes: the `trevelyan` and `m` agents from the `goldeneye-agents` plugin (dispatched via the `Agent` tool, per that plugin's existing usage pattern).

- [ ] **Step 1: Write the skill definition**

Create `plugins/workflow-skills/skills/plan-review/SKILL.md`:

```markdown
---
name: plan-review
description: "Generate an interactive HTML review page for an implementation plan — runs the plan past the trevelyan and m Goldeneye agents for critique, then renders the plan and critique as a page with per-section and general feedback boxes that copy to clipboard as Markdown. Use before a non-trivial plan is presented for approval, or on demand via /plan-review <path-to-plan.md>. Triggers on \"review this plan\", \"plan review\", \"pressure-test this plan\"."
---

# Plan Review

Turn a plan markdown file into an interactive HTML page for critique and feedback, instead of presenting the plan as chat text.

## When to use

- Automatically, per CLAUDE.md Guardrail #9, before a non-trivial plan is presented for approval.
- Explicitly via `/plan-review <path-to-plan.md>`.

## Steps

1. **Critique the plan.** Dispatch two `Agent` calls in parallel against the plan file:
   - `trevelyan`: "Critique this implementation PLAN — not code, no code exists yet. Read the plan below and identify: assumptions it makes, failure modes it doesn't address, scope creep or ambiguity, and whether the phased/task breakdown makes sense. Be direct and specific, referencing exact section headings where relevant.\n\n<plan file contents>"
   - `m`: "Sanity-check this implementation plan's architecture and phasing. Identify: missing steps, risky sequencing, unaddressed edge cases, and whether the file/component breakdown is sound. Be specific and reference exact section headings where relevant.\n\n<plan file contents>"

   If either agent call fails, proceed with whatever critique is available — do not block on it.

2. **Write critique to temp files.** Write each agent's response text to its own file (e.g. `/tmp/plan-review-trevelyan.txt`, `/tmp/plan-review-m.txt`) rather than passing it as a shell argument — critique text is long and can contain quotes/newlines that break shell escaping.

3. **Generate the HTML.** Run:
   ```bash
   python3 <this skill's directory>/scripts/build_review.py <plan_path> --trevelyan-file /tmp/plan-review-trevelyan.txt --m-file /tmp/plan-review-m.txt
   ```
   This prints the generated file path (e.g. `/tmp/claude-plan-review-<slug>-<timestamp>.html`).

4. **Open it.** Run `open <printed path>`.

5. **Wait for feedback.** Tell the user the page is open, ask them to review the Goldeneye critique, leave feedback per-section and/or generally, choose Approve/Request changes, click "Copy Feedback", and paste the result back into the conversation. Do not proceed with the plan until they respond.

6. **Incorporate feedback.** Once the user pastes their feedback Markdown, treat it like any other plan-approval response per Guardrail #2 — revise and re-present if changes were requested, proceed if approved.
```

- [ ] **Step 2: Commit**

```bash
git add plugins/workflow-skills/skills/plan-review/SKILL.md
git commit -m "feat: add plan-review SKILL.md orchestration"
```

---

### Task 6: Update CLAUDE.md Guardrail #9 to name the skill explicitly

**Files:**
- Modify: `/Users/alex.rosenkranz/.claude/CLAUDE.md`

**Interfaces:** None (documentation-only change).

- [ ] **Step 1: Update the guardrail text**

In `/Users/alex.rosenkranz/.claude/CLAUDE.md`, find:

```
9. **Interactive plan review** — Before I approve a non-trivial plan, proactively run it past the goldeneye agents (`trevelyan`, `m`) for critique, then present the plan to me as an interactive artifact (e.g. an HTML page), not just chat text — walk me through it, make it something I can leave targeted inline feedback on and paste back. The exact tooling for this isn't built yet; use judgment on the best available mechanism until we design a dedicated flow.
```

Replace it with:

```
9. **Interactive plan review** — Before I approve a non-trivial plan, use the `plan-review` skill (`claude-code-config` repo, `workflow-skills` plugin) to run it past the goldeneye agents (`trevelyan`, `m`) for critique and present it as an interactive HTML page with per-section feedback boxes. Wait for me to paste back my feedback before proceeding.
```

- [ ] **Step 2: Commit**

This file lives outside the `claude-code-config` repo (it's `~/.claude/CLAUDE.md`, not tracked in this project's git history) — no `git commit` here. Just save the edit.

---

### Task 7: Document the new skill in the plugin README

**Files:**
- Modify: `/Users/alex.rosenkranz/workspace/claude-code-config/README.md`

**Interfaces:** None (documentation-only change).

- [ ] **Step 1: Add `/plan-review` to the workflow-skills list**

In `README.md`, find the `workflow-skills` section's command list (currently listing things like `/morning-plan`, `/patrol`, `/spec-and-plan`, etc.) and add `/plan-review` to it. Read the current list first with `grep -n "workflow-skills" -A 20 README.md` to find the exact block, then add the entry alongside the existing ones without altering unrelated lines.

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: list /plan-review in workflow-skills plugin commands"
```

---

### Task 8: Open the PR

**Files:** None.

- [ ] **Step 1: Push the branch**

```bash
git push -u origin add-plan-review-skill
```

- [ ] **Step 2: Create the PR**

```bash
gh pr create --title "Add interactive plan-review skill" --body "$(cat <<'EOF'
- Adds `plan-review` skill: runs a plan past trevelyan + m for critique, renders it as a self-contained HTML page with per-section/general feedback boxes and a copy-to-clipboard button
- Updates CLAUDE.md Guardrail #9 to name the new skill explicitly
- Lists /plan-review in the workflow-skills README section

## Test plan
- [x] `python3 -m pytest test_build_review.py -v` passes (9 tests)
- [x] Manually verified in a real browser: critique panel, per-section feedback, copy-to-clipboard, and the clipboard-failure fallback textarea
EOF
)"
```

- [ ] **Step 3: Verify**

```bash
gh pr view
```
Expected: PR shown with status `OPEN`, correct base (`main`) and head (`add-plan-review-skill`) branches.
