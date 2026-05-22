#!/bin/bash
# SessionEnd Hook - Write useful session summaries to Obsidian vault

input=$(cat)

session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
reason=$(echo "$input" | jq -r '.reason // ""')
cwd=$(echo "$input" | jq -r '.cwd // ""')

[[ "$reason" == "clear" ]] && exit 0
[[ ! -f "$transcript_path" ]] && exit 0

SESSIONS_DIR="$HOME/Documents/main-vault/Sessions"
DATE=$(date +%Y-%m-%d)
NOTE_FILE="$SESSIONS_DIR/$DATE.md"
TIMESTAMP=$(date +"%H:%M")

mkdir -p "$SESSIONS_DIR"

# Skip if already logged
if [[ -f "$NOTE_FILE" ]] && grep -q "<!-- session:${session_id} -->" "$NOTE_FILE" 2>/dev/null; then
    exit 0
fi

# Extract session content from transcript using python3
session_data=$(python3 - "$transcript_path" "$cwd" <<'PYEOF'
import json
import sys
import os
import re

transcript_path = sys.argv[1]
cwd = sys.argv[2]

lines = []
try:
    with open(transcript_path) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    lines.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
except Exception:
    sys.exit(1)

# Skip trivial sessions (< 3 assistant turns)
assistant_count = sum(1 for l in lines if l.get('type') == 'assistant')
if assistant_count < 2:
    print("SKIP")
    sys.exit(0)

files_modified = []
bash_cmds = []
last_assistant_text = ""
user_messages = []

for entry in lines:
    t = entry.get('type')

    if t == 'assistant':
        content = entry.get('message', {}).get('content', [])
        for block in content:
            if block.get('type') == 'text' and block.get('text', '').strip():
                last_assistant_text = block['text'].strip()
            elif block.get('type') == 'tool_use':
                name = block.get('name', '')
                inp = block.get('input', {})
                if name in ('Edit', 'Write'):
                    path = inp.get('file_path', '')
                    if path and path not in files_modified:
                        files_modified.append(path)
                elif name == 'Bash':
                    cmd = inp.get('command', '').strip()
                    # Skip noisy read-only and hook-internal commands
                    if cmd and not re.match(r'^(cat|ls|find|grep|echo|head|tail|wc|jq|stat|diff)\b', cmd):
                        bash_cmds.append(cmd[:100])

    elif t == 'user':
        content = entry.get('message', {}).get('content', [])
        for block in content:
            if isinstance(block, dict) and block.get('type') == 'text':
                txt = block.get('text', '').strip()
                if txt and len(txt) > 10:
                    user_messages.append(txt[:200])
            elif isinstance(block, str) and len(block) > 10:
                user_messages.append(block[:200])

# Derive topic from first user message
topic = user_messages[0] if user_messages else "session"
# Truncate and clean for display
topic_short = topic[:80].replace('\n', ' ')

# Shorten file paths relative to cwd or home
home = os.path.expanduser('~')
def shorten(path):
    if path.startswith(cwd + '/'):
        return path[len(cwd)+1:]
    if path.startswith(home + '/'):
        return '~/' + path[len(home)+1:]
    return path

files_display = [shorten(f) for f in files_modified[:10]]

# Build the summary text block
out = []
out.append(f"**Topic**: {topic_short}")
out.append("")

if files_display:
    out.append("**Files changed**:")
    for f in files_display:
        out.append(f"- `{f}`")
    out.append("")

if last_assistant_text:
    # Trim to a useful length for a note
    summary_text = last_assistant_text[:500]
    if len(last_assistant_text) > 500:
        summary_text += "…"
    out.append("**Summary**:")
    out.append(summary_text)
    out.append("")

print('\n'.join(out))
PYEOF
)

# Skip trivial/empty sessions
if [[ "$session_data" == "SKIP" ]] || [[ -z "$session_data" ]]; then
    exit 0
fi

project_name=$(basename "$cwd")

# Build tags from actual file types modified
tags=("session")
echo "$session_data" | grep -q '\.ts\|\.tsx\|\.js\|\.jsx\|package\.json' && tags+=("javascript")
echo "$session_data" | grep -q '\.go\b\|go\.mod' && tags+=("golang")
echo "$session_data" | grep -q '\.py\b\|requirements\|pyproject' && tags+=("python")
echo "$session_data" | grep -q 'Dockerfile\|docker-compose' && tags+=("docker")
echo "$session_data" | grep -q '\.sh\b' && tags+=("shell")
echo "$session_data" | grep -q '\.md\b' && tags+=("docs")
[[ "$cwd" == *"/Code/"* ]] && tags+=("personal-project")

tags_yaml=""
for tag in "${tags[@]}"; do
    tags_yaml+="  - $tag"$'\n'
done

entry="<!-- session:${session_id} -->
## ${TIMESTAMP} — ${project_name}

${session_data}
---"

if [[ -f "$NOTE_FILE" ]]; then
    printf '\n%s\n' "$entry" >> "$NOTE_FILE"
else
    cat > "$NOTE_FILE" <<HEADER
---
date: $DATE
tags:
${tags_yaml}project: $project_name
project_path: $cwd
---

# Session Notes - $DATE

$entry
HEADER
fi

exit 0
