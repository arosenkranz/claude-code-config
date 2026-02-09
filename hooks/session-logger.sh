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

# Extract conversation summary using claude
summary=$(claude -p --model haiku --tools "" --max-budget-usd 0.2 <<EOF
You are summarizing a Claude Code session transcript for personal notes.

Analyze this transcript and create a concise summary in the following format:

### Session $TIMESTAMP - [Brief Topic in 3-5 words]

**Host**: $HOSTNAME
**Working Directory**: \`$cwd\`

**Summary**: [1-2 sentences describing what was accomplished]

**Accomplishments**:
- [Key things completed]

**Learnings**:
- [New concepts or insights]

**Commands/Code**:
\`\`\`bash
# Key commands used (if any)
\`\`\`

**Next Steps**:
- [ ] [Follow-up tasks if any]

---

Here is the transcript (JSONL format):
$(cat "$transcript_path" | head -100)
EOF
)

# Check if we got a valid summary
if [[ -z "$summary" || "$summary" == "null" ]]; then
    # Fallback to a simple log entry
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

# Detect project and technologies from working directory
project_name=$(basename "$cwd")
project_path="$cwd"

# Detect technologies based on files in directory
tags=("session")

if [[ -f "$cwd/package.json" ]]; then
    tags+=("javascript")

    # Check for specific frameworks
    if grep -q "astro" "$cwd/package.json" 2>/dev/null; then
        tags+=("astro")
    fi
    if grep -q "react" "$cwd/package.json" 2>/dev/null; then
        tags+=("react")
    fi
    if grep -q "next" "$cwd/package.json" 2>/dev/null; then
        tags+=("nextjs")
    fi
    if grep -q "typescript" "$cwd/package.json" 2>/dev/null; then
        tags+=("typescript")
    fi
    if grep -q "tailwind" "$cwd/package.json" 2>/dev/null; then
        tags+=("tailwind")
    fi
    if grep -q "vite" "$cwd/package.json" 2>/dev/null; then
        tags+=("vite")
    fi
fi

if [[ -f "$cwd/docker-compose.yml" ]] || [[ -f "$cwd/Dockerfile" ]]; then
    tags+=("docker")
fi

if [[ -f "$cwd/terraform.tf" ]] || [[ -d "$cwd/.terraform" ]]; then
    tags+=("terraform")
fi

if [[ -f "$cwd/requirements.txt" ]] || [[ -f "$cwd/setup.py" ]] || [[ -f "$cwd/pyproject.toml" ]]; then
    tags+=("python")
fi

if [[ -f "$cwd/go.mod" ]]; then
    tags+=("golang")
fi

# Detect project type
project_type=""
if [[ "$cwd" == *"/Code/"* ]]; then
    project_type="personal-project"
elif [[ "$cwd" == *"/homelab/"* ]] || [[ "$cwd" == *"/pi/"* ]]; then
    project_type="homelab"
else
    project_type="development"
fi

tags+=("$project_type")

# Build tags string for frontmatter
tags_yaml=""
for tag in "${tags[@]}"; do
    tags_yaml+="  - $tag"$'\n'
done

# Determine session status (default to in-progress, can be updated manually)
status="complete"

# Append to daily note
if [[ -f "$NOTE_FILE" ]]; then
    # File exists, append to it
    echo "" >> "$NOTE_FILE"
    echo "$summary" >> "$NOTE_FILE"
else
    # Create new file with frontmatter
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
