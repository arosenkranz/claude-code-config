#!/usr/bin/env bash
# check-console-log.sh — Warn about console.log statements in JS/TS files after edits.
# Triggered via PostToolUse hook matching Edit/Write calls.
# Advisory only — exits 0 always, just prints a warning.

set -euo pipefail

# Read tool input from stdin
input=$(cat)

# Extract file_path from the JSON tool input
file_path=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',''))" 2>/dev/null || echo "")

if [[ -z "$file_path" || ! -f "$file_path" ]]; then
  exit 0
fi

# Only check JS/TS files
case "$file_path" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs) ;;
  *) exit 0 ;;
esac

# Skip test files — console.log in tests is usually fine
case "$file_path" in
  *.test.*|*.spec.*|*__tests__*|*__mocks__*) exit 0 ;;
esac

# Count console.log occurrences
count=$(grep -c 'console\.log' "$file_path" 2>/dev/null || echo "0")

if [[ "$count" -gt 0 ]]; then
  echo "⚠️  Found $count console.log statement(s) in $(basename "$file_path"). Remove before committing."
fi

exit 0
