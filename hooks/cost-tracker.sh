#!/usr/bin/env bash
# cost-tracker.sh — Log token usage and estimated cost per session.
# Triggered via Stop hook (async). Appends to ~/.claude/cost-log.jsonl.
# Uses CLAUDE_SESSION_ID and tool_use_count from the session context.

set -euo pipefail

LOG_FILE="$HOME/.claude/cost-log.jsonl"

# Read the stop event input from stdin
input=$(cat)

# Extract session_id and transcript if available
session_id=$(echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('session_id', 'unknown'))
except:
    print('unknown')
" 2>/dev/null || echo "unknown")

# Get the transcript path from environment if available
transcript="${CLAUDE_TRANSCRIPT_PATH:-}"

# Count tool uses from transcript if available
tool_count=0
if [[ -n "$transcript" && -f "$transcript" ]]; then
  tool_count=$(grep -c '"type":"tool_use"' "$transcript" 2>/dev/null || echo "0")
fi

# Log entry
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "{\"timestamp\":\"$timestamp\",\"session_id\":\"$session_id\",\"tool_uses\":$tool_count}" >> "$LOG_FILE"

exit 0
