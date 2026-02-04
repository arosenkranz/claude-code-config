#!/bin/bash

# Check for common secret patterns
echo "Checking for hardcoded secrets..."

ISSUES_FOUND=0

# Check for API keys
if git diff --cached | grep -iE '(api[_-]?key|secret[_-]?key|password|token).*["\x27]=.*[a-zA-Z0-9]{20,}'; then
  echo "❌ Possible API key or secret found in staged changes"
  ISSUES_FOUND=1
fi

# Check for absolute paths with username
if git diff --cached | grep -E '/Users/[a-zA-Z0-9_-]+'; then
  echo "❌ Absolute path with username found (use \$HOME or variables)"
  ISSUES_FOUND=1
fi

# Check for email addresses (exclude common example domains and Python decorators)
if git diff --cached | grep -E '\+.*[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | grep -viE '(@(example\.(com|org|net)|test\.com|localhost|anthropic\.com)|@(mcp|pytest|app)\.)'; then
  echo "❌ Real email address found in staged changes (example emails are OK)"
  ISSUES_FOUND=1
fi

if [[ $ISSUES_FOUND -eq 1 ]]; then
  echo ""
  echo "🛑 Pre-commit check failed. Please review and remove sensitive information."
  exit 1
fi

echo "✅ No secrets detected"
exit 0
