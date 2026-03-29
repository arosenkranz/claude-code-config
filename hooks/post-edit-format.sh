#!/usr/bin/env bash
# post-edit-format.sh — Auto-format JS/TS files after edits.
# Triggered via PostToolUse hook matching Edit calls (async).
# Detects Biome or Prettier and formats the edited file.

set -euo pipefail

# Read tool input from stdin
input=$(cat)

# Extract file_path from the JSON tool input
file_path=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',''))" 2>/dev/null || echo "")

if [[ -z "$file_path" || ! -f "$file_path" ]]; then
  exit 0
fi

# Only format JS/TS files
case "$file_path" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs) ;;
  *) exit 0 ;;
esac

# Find project root (walk up to find package.json)
dir=$(dirname "$file_path")
project_root=""
while [[ "$dir" != "/" ]]; do
  if [[ -f "$dir/package.json" ]]; then
    project_root="$dir"
    break
  fi
  dir=$(dirname "$dir")
done

if [[ -z "$project_root" ]]; then
  exit 0
fi

cd "$project_root"

# Detect formatter: prefer Biome, then Prettier
if [[ -f "biome.json" || -f "biome.jsonc" ]]; then
  if command -v npx &>/dev/null; then
    npx biome format --write "$file_path" 2>/dev/null || true
  fi
elif command -v npx &>/dev/null; then
  # Check if prettier is available (as dependency or globally)
  if npx prettier --version &>/dev/null 2>&1; then
    npx prettier --write "$file_path" 2>/dev/null || true
  fi
fi

exit 0
