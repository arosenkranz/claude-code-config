#!/bin/bash
set -e

echo "Syncing Claude Code configuration from repository..."

# 1. Verify we're in the repo
if [[ ! -f "README.md" ]] || [[ ! -d "rules" ]]; then
  echo "Error: Run this script from the claude-code-config repository root"
  exit 1
fi

# 2. Pull latest changes
echo "Pulling latest changes from git..."
git pull

# 3. Sync shareable directories (preserving machine-specific files)
echo "Syncing configuration..."
rsync -av --delete rules/ "$HOME/.claude/rules/"
rsync -av --delete agents/ "$HOME/.claude/agents/"
rsync -av --delete commands/ "$HOME/.claude/commands/"
rsync -av --delete skills/ "$HOME/.claude/skills/"
cp CLAUDE.md "$HOME/.claude/"

# 4. Update hooks (don't overwrite if manually customized)
echo "Checking for hook updates..."
for hook_template in hooks/*.template; do
  hook_name=$(basename "$hook_template" .template)
  if [[ -f "$HOME/.claude/hooks/$hook_name" ]]; then
    # Show diff if changes exist
    if ! diff -q "$hook_template" "$HOME/.claude/hooks/$hook_name" >/dev/null 2>&1; then
      echo "⚠️  Hook updated: $hook_name (manual merge may be needed)"
      diff "$hook_template" "$HOME/.claude/hooks/$hook_name" || true
    fi
  else
    cp "$hook_template" "$HOME/.claude/hooks/$hook_name"
    chmod +x "$HOME/.claude/hooks/$hook_name"
  fi
done

echo ""
echo "✅ Sync complete!"
