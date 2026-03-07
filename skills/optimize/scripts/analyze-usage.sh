#!/usr/bin/env bash
# analyze-usage.sh — Parse Claude usage data into structured JSON for /optimize skill
set -euo pipefail

# Verify jq is available
if ! command -v jq &>/dev/null; then
  echo '{"error": "jq is required but not installed. Run: brew install jq"}' >&2
  exit 1
fi

SESSION_META_DIR="$HOME/.claude/usage-data/session-meta"
FACETS_DIR="$HOME/.claude/usage-data/facets"
HISTORY_FILE="$HOME/.claude/history.jsonl"
OBSERVATIONS_FILE="$HOME/.claude/homunculus/observations.jsonl"

# ── Session meta aggregation ────────────────────────────────────────────────
total_sessions=0
earliest=""
latest=""
skill_invocations=0
agent_invocations=0

for f in "$SESSION_META_DIR"/*.json; do
  [[ -f "$f" ]] || continue
  ((total_sessions++))

  start=$(jq -r '.start_time // empty' "$f")
  if [[ -n "$start" ]]; then
    [[ -z "$earliest" || "$start" < "$earliest" ]] && earliest="$start"
    [[ -z "$latest"   || "$start" > "$latest"   ]] && latest="$start"
  fi

  # Accumulate skill and agent/task tool counts
  skill_count=$(jq '.tool_counts.Skill // 0' "$f")
  task_count=$(jq '(.tool_counts.Task // 0) + (.tool_counts.Agent // 0)' "$f")
  skill_invocations=$((skill_invocations + skill_count))
  agent_invocations=$((agent_invocations + task_count))
done

# ── Slash command counts from history.jsonl ──────────────────────────────────
slash_cmd_json="{}"
if [[ -f "$HISTORY_FILE" ]]; then
  slash_cmd_json=$(python3 - <<'PYEOF'
import json, sys, re

counts = {}
try:
    with open('/Users/alexrosenkranz/.claude/history.jsonl') as f:
        for line in f:
            try:
                d = json.loads(line)
                display = d.get('display', '').strip()
                if display.startswith('/'):
                    cmd = display.split()[0].lower()
                    # Only count user-defined / skill-style commands (not built-ins)
                    if cmd not in {'/exit', '/clear', '/mcp', '/model', '/resume',
                                   '/context', '/doctor', '/statusline', '/config',
                                   '/compact', '/memory', '/branch', '/init',
                                   '/plugin', '/rate-limit-options', '/sandbox',
                                   '/install-github-app', '/save-session', '/agents',
                                   '/status', '/usage', '/terminal-setup', '/fork',
                                   '/merge-and-create-branch', '/eit'}:
                        counts[cmd] = counts.get(cmd, 0) + 1
            except Exception:
                pass
except Exception:
    pass

print(json.dumps(counts))
PYEOF
)
fi

# ── Facets aggregation ───────────────────────────────────────────────────────
achieved=0
partially=0
not_achieved=0
friction_sessions='[]'

if [[ -d "$FACETS_DIR" ]]; then
  facets_data=$(python3 - <<'PYEOF'
import json, glob, os

achieved = 0
partially = 0
not_achieved = 0
friction_sessions = []

for f in glob.glob('/Users/alexrosenkranz/.claude/usage-data/facets/*.json'):
    try:
        with open(f) as fh:
            d = json.load(fh)
        outcome = d.get('outcome', '')
        if outcome == 'achieved':
            achieved += 1
        elif outcome == 'partially_achieved':
            partially += 1
        elif outcome == 'not_achieved':
            not_achieved += 1

        fc = d.get('friction_counts', {})
        if fc:
            friction_sessions.append({
                'id': d.get('session_id', ''),
                'friction': d.get('friction_detail', ''),
                'friction_types': list(fc.keys()),
                'outcome': outcome
            })
    except Exception:
        pass

print(json.dumps({
    'achieved': achieved,
    'partially_achieved': partially,
    'not_achieved': not_achieved,
    'friction_sessions': friction_sessions[:10]  # cap at 10
}))
PYEOF
)
  achieved=$(echo "$facets_data" | jq '.achieved')
  partially=$(echo "$facets_data" | jq '.partially_achieved')
  not_achieved=$(echo "$facets_data" | jq '.not_achieved')
  friction_sessions=$(echo "$facets_data" | jq '.friction_sessions')
fi

# ── Homunculus Skill events ──────────────────────────────────────────────────
homunculus_skill_count=0
if [[ -f "$OBSERVATIONS_FILE" ]]; then
  homunculus_skill_count=$(python3 - <<'PYEOF'
import json

count = 0
try:
    with open('/Users/alexrosenkranz/.claude/homunculus/observations.jsonl') as f:
        for line in f:
            try:
                d = json.loads(line)
                if d.get('tool') == 'Skill' and d.get('event') == 'tool_complete':
                    count += 1
            except Exception:
                pass
except Exception:
    pass
print(count)
PYEOF
)
fi

# ── Output final JSON ────────────────────────────────────────────────────────
jq -n \
  --argjson total_sessions "$total_sessions" \
  --arg earliest "$earliest" \
  --arg latest "$latest" \
  --argjson slash_command_counts "$slash_cmd_json" \
  --argjson skill_tool_invocations "$skill_invocations" \
  --argjson agent_tool_invocations "$agent_invocations" \
  --argjson homunculus_skill_events "$homunculus_skill_count" \
  --argjson achieved "$achieved" \
  --argjson partially "$partially" \
  --argjson not_achieved "$not_achieved" \
  --argjson high_friction_sessions "$friction_sessions" \
  '{
    total_sessions: $total_sessions,
    date_range: { earliest: $earliest, latest: $latest },
    slash_command_counts: $slash_command_counts,
    skill_tool_invocations: $skill_tool_invocations,
    agent_tool_invocations: $agent_tool_invocations,
    homunculus_skill_events: $homunculus_skill_events,
    outcome_summary: {
      achieved: $achieved,
      partially_achieved: $partially,
      not_achieved: $not_achieved
    },
    high_friction_sessions: $high_friction_sessions
  }'
