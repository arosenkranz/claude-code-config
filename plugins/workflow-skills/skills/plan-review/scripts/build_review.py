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
