#!/usr/bin/env bash
# pre-commit-lint.sh — Runs lint (and optionally typecheck) before git commit.
# Triggered via PreToolUse hook with "if": "Bash(git commit*)" filter.
# Exits non-zero to block the commit if lint fails.

set -euo pipefail

# Walk up to find project root (where package.json lives)
dir="$PWD"
while [[ "$dir" != "/" ]]; do
  [[ -f "$dir/package.json" ]] && break
  dir=$(dirname "$dir")
done
if [[ ! -f "$dir/package.json" ]]; then
  exit 0
fi
cd "$dir"

has_script() {
  node -e "const p=require('./package.json'); process.exit(p.scripts?.['$1'] ? 0 : 1)" 2>/dev/null
}

# Detect package manager
if [[ -f "bun.lockb" ]]; then
  PM="bun"
elif [[ -f "pnpm-lock.yaml" ]]; then
  PM="pnpm"
elif [[ -f "yarn.lock" ]]; then
  PM="yarn"
else
  PM="npm"
fi

failed=0

# Run lint if available
if has_script "lint"; then
  echo "🔍 Running $PM run lint..."
  if ! $PM run lint --silent 2>&1; then
    echo "❌ Lint failed — fix errors before committing."
    failed=1
  fi
fi

# Run typecheck if available (tsc --noEmit or a "typecheck" script)
if has_script "typecheck"; then
  echo "🔍 Running $PM run typecheck..."
  if ! $PM run typecheck --silent 2>&1; then
    echo "❌ Typecheck failed — fix type errors before committing."
    failed=1
  fi
fi

if [[ $failed -ne 0 ]]; then
  exit 1
fi

exit 0
