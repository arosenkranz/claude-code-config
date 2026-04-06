#!/bin/bash
# Session Logger Hook for Claude Code
# Automatically creates session summaries in Obsidian vault

# Read JSON input from stdin
input=$(cat)

# Extract values from input
session_id=$(echo "$input" | jq -r '.session_id')
transcript_path=$(echo "$input" | jq -r '.transcript_path')
reason=$(echo "$input" | jq -r '.reason')
cwd=$(echo "$input" | jq -r '.cwd')
HOSTNAME=$(hostname)

# Skip logging for very short sessions or certain exit reasons
if [[ "$reason" == "clear" ]]; then
    exit 0
fi

# Check if transcript exists
if [[ ! -f "$transcript_path" ]]; then
    exit 0
fi

# Count messages to skip trivial sessions
message_count=$(wc -l < "$transcript_path" | tr -d ' ')
if [[ "$message_count" -lt 4 ]]; then
    exit 0
fi

# Set up paths
SESSIONS_DIR="$HOME/Documents/main-vault/Sessions"
DATE=$(date +%Y-%m-%d)
NOTE_FILE="$SESSIONS_DIR/$DATE.md"
TIMESTAMP=$(date +"%H:%M:%S")

# Create sessions directory if it doesn't exist
mkdir -p "$SESSIONS_DIR"

# Deduplication: skip if this session_id was already logged
if [[ -f "$NOTE_FILE" ]] && grep -q "<!-- session:${session_id} -->" "$NOTE_FILE" 2>/dev/null; then
    exit 0
fi

# Delegate summary generation to Node script
# The script prints the summary markdown to stdout
LOG_SESSION_SCRIPT="$HOME/Code/claude-memory/dist/scripts/log-session.js"
project_name=$(basename "$cwd")
project_path="$cwd"

if [[ -f "$LOG_SESSION_SCRIPT" ]] && command -v node >/dev/null 2>&1; then
    summary=$(node "$LOG_SESSION_SCRIPT" \
        --session-id "$session_id" \
        --transcript "$transcript_path" \
        --cwd "$cwd" \
        --hostname "$HOSTNAME" 2>>/tmp/session-logger.log)
fi

# Fallback if script unavailable or returned empty
if [[ -z "$summary" ]]; then
    summary="### Session $TIMESTAMP

**Host**: $HOSTNAME
**Working Directory**: \`$cwd\`
**Session ID**: \`$session_id\`

*Auto-logged session - summary generation failed*

---"
fi

# Prepend session_id marker for deduplication (hidden in Obsidian)
summary="<!-- session:${session_id} -->
${summary}"

# Build tags for Obsidian frontmatter
tags=("session")
[[ -f "$cwd/package.json" ]] && tags+=("javascript")
[[ -f "$cwd/go.mod" ]] && tags+=("golang")
[[ -f "$cwd/pyproject.toml" || -f "$cwd/requirements.txt" ]] && tags+=("python")
[[ -f "$cwd/docker-compose.yml" || -f "$cwd/Dockerfile" ]] && tags+=("docker")
[[ "$cwd" == *"/Code/"* ]] && tags+=("personal-project") || tags+=("development")

tags_yaml=""
for tag in "${tags[@]}"; do
    tags_yaml+="  - $tag"$'\n'
done

status="complete"

# Append to daily note
if [[ -f "$NOTE_FILE" ]]; then
    echo "" >> "$NOTE_FILE"
    echo "$summary" >> "$NOTE_FILE"
else
    cat > "$NOTE_FILE" << HEADER
---
date: $DATE
tags:
$tags_yaml
project: $project_name
project_path: $project_path
status: $status
---

# Session Notes - $DATE

$summary
HEADER
fi

exit 0
