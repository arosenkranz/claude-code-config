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

# Also write session summary to SQLite memory DB (dual-write: Obsidian for humans, SQLite for machines)
MEMORY_DB="${MEMORY_DB_PATH:-$HOME/.claude/memory.db}"
if [[ -f "$MEMORY_DB" ]] && command -v sqlite3 >/dev/null 2>&1 && [[ -n "$summary" ]]; then
    PROJECT_NAME=$(basename "$cwd")
    PROJECT_SCOPE="project:$PROJECT_NAME"
    ESCAPED_SUMMARY=$(echo "$summary" | head -20 | tr "'" '"')
    ESCAPED_CWD=$(echo "$cwd" | tr "'" '"')

    sqlite3 "$MEMORY_DB" "
        INSERT OR IGNORE INTO entities (name, entity_type, scope)
        VALUES ('$PROJECT_NAME', 'project', '$PROJECT_SCOPE');

        INSERT INTO observations (entity_id, content, source, confidence)
        SELECT id, 'Session $DATE $TIMESTAMP: $ESCAPED_CWD', 'hook:session-end', 0.9
        FROM entities WHERE name = '$PROJECT_NAME' AND scope = '$PROJECT_SCOPE';
    " 2>/dev/null
fi

# Harvest CLAUDE.md sections into SQLite memory (idempotent via MD5 hash)
CLAUDE_MD="$cwd/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]] && [[ -f "$MEMORY_DB" ]] && command -v sqlite3 >/dev/null 2>&1; then
    CURRENT_HASH=$(md5 -q "$CLAUDE_MD" 2>/dev/null || md5sum "$CLAUDE_MD" 2>/dev/null | cut -d' ' -f1)
    HASH_ENTITY="${PROJECT_NAME}-claude-md-hash"
    STORED_HASH=$(sqlite3 "$MEMORY_DB" "
        SELECT o.content FROM observations o
        JOIN entities e ON e.id = o.entity_id
        WHERE e.name = '${HASH_ENTITY}' AND o.source = 'hook:harvest'
        ORDER BY o.created_at DESC LIMIT 1;
    " 2>/dev/null)

    if [[ "$CURRENT_HASH" != "$STORED_HASH" ]]; then
        # Extract a section from CLAUDE.md by heading prefix, trim to 1000 chars
        extract_section() {
            local heading="$1"
            local content
            content=$(awk -v h="$heading" '
                /^## / { if (found) exit; if (index($0, h) > 0) found=1; next }
                found { print }
            ' "$CLAUDE_MD" | head -40 | tr -d '\000-\010\013\014\016-\037')
            echo "${content:0:1000}"
        }

        # section_heading | entity_suffix | entity_type
        declare -a SECTIONS=(
            "Architecture|architecture|decision"
            "Scheduling|scheduling|decision"
            "Data flow|data-flow|decision"
            "Key hooks|key-hooks|decision"
            "Routing|routing|decision"
            "Channel import|channel-import|decision"
            "Constraints|constraints|decision"
            "Key Patterns|key-patterns|decision"
            "Tech Stack|tech-stack|project"
            "Observability|observability|service"
        )

        for entry in "${SECTIONS[@]}"; do
            IFS='|' read -r heading suffix etype <<< "$entry"
            content=$(extract_section "$heading")
            [[ -z "$content" ]] && continue

            entity_name="${PROJECT_NAME}-${suffix}"
            escaped_content=$(echo "$content" | sed "s/'/''/g")

            sqlite3 "$MEMORY_DB" "
                INSERT OR IGNORE INTO entities (name, entity_type, scope)
                VALUES ('${entity_name}', '${etype}', '${PROJECT_SCOPE}');

                DELETE FROM observations
                WHERE entity_id = (SELECT id FROM entities WHERE name = '${entity_name}' AND scope = '${PROJECT_SCOPE}')
                  AND source = 'hook:harvest';

                INSERT INTO observations (entity_id, content, source, confidence)
                SELECT id, '${escaped_content}', 'hook:harvest', 0.85
                FROM entities WHERE name = '${entity_name}' AND scope = '${PROJECT_SCOPE}';
            " 2>/dev/null
        done

        # Store new hash for change detection
        sqlite3 "$MEMORY_DB" "
            INSERT OR IGNORE INTO entities (name, entity_type, scope)
            VALUES ('${HASH_ENTITY}', 'project', '${PROJECT_SCOPE}');

            DELETE FROM observations
            WHERE entity_id = (SELECT id FROM entities WHERE name = '${HASH_ENTITY}' AND scope = '${PROJECT_SCOPE}')
              AND source = 'hook:harvest';

            INSERT INTO observations (entity_id, content, source, confidence)
            SELECT id, '${CURRENT_HASH}', 'hook:harvest', 1.0
            FROM entities WHERE name = '${HASH_ENTITY}' AND scope = '${PROJECT_SCOPE}';
        " 2>/dev/null
    fi
fi


exit 0
