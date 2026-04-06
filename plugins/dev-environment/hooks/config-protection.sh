#!/usr/bin/env bash
# config-protection.sh — Block modifications to linter/formatter/compiler config files.
# Steers the agent to fix code instead of weakening configs.
# Triggered via PreToolUse hook matching Edit/Write calls.
# Exits non-zero to block the edit if it targets a protected config file.

set -euo pipefail

# Read tool input from stdin
input=$(cat)

# Extract file_path from the JSON tool input
file_path=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',''))" 2>/dev/null || echo "")

if [[ -z "$file_path" ]]; then
  exit 0
fi

basename=$(basename "$file_path")

# Protected config file patterns
protected_patterns=(
  ".eslintrc"
  ".eslintrc.js"
  ".eslintrc.cjs"
  ".eslintrc.json"
  ".eslintrc.yml"
  ".eslintrc.yaml"
  "eslint.config.js"
  "eslint.config.mjs"
  "eslint.config.cjs"
  ".prettierrc"
  ".prettierrc.js"
  ".prettierrc.cjs"
  ".prettierrc.json"
  ".prettierrc.yml"
  ".prettierrc.yaml"
  "prettier.config.js"
  "prettier.config.mjs"
  "prettier.config.cjs"
  "tsconfig.json"
  "tsconfig.base.json"
  "biome.json"
  "biome.jsonc"
)

for pattern in "${protected_patterns[@]}"; do
  if [[ "$basename" == "$pattern" ]]; then
    echo "🛡️ BLOCKED: Editing $basename is not allowed."
    echo "Fix the code to satisfy the config, don't weaken the config to match the code."
    echo "If you genuinely need to change this config, ask the user first."
    exit 1
  fi
done

exit 0
