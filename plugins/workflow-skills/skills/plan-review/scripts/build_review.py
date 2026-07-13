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
