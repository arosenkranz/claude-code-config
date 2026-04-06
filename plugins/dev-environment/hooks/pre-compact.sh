#!/bin/bash
# PreCompact Hook - Save state before context compaction
# Recreated locally from everything-claude-code plugin

CLAUDE_DIR="$HOME/.claude"
SESSIONS_DIR="$CLAUDE_DIR/sessions"
COMPACTION_LOG="$SESSIONS_DIR/compaction-log.txt"

# Ensure sessions directory exists
mkdir -p "$SESSIONS_DIR"

# Get current timestamp
DATETIME=$(date +"%Y-%m-%d %H:%M:%S")
TIME=$(date +"%H:%M")

# Log compaction event
echo "[$DATETIME] Context compaction triggered" >> "$COMPACTION_LOG"
echo "[PreCompact] Context compaction at $TIME" >&2

# Find the most recent session .tmp file
# Use stat to get modification time for sorting (cross-platform)
recent_session=$(find "$SESSIONS_DIR" -name "*-session.tmp" -type f 2>/dev/null | \
    while read -r file; do
        if [[ -f "$file" ]]; then
            # macOS uses -f %m, Linux uses -c %Y
            mtime=$(stat -f "%m" "$file" 2>/dev/null || stat -c "%Y" "$file" 2>/dev/null)
            echo "$mtime $file"
        fi
    done | sort -rn | head -1 | cut -d' ' -f2-)

# Append compaction marker to active session file
if [[ -n "$recent_session" ]] && [[ -f "$recent_session" ]]; then
    echo "" >> "$recent_session"
    echo "--- Compacted at $TIME ---" >> "$recent_session"
    echo "" >> "$recent_session"
    echo "[PreCompact] Marker added to session file" >&2
fi

exit 0
