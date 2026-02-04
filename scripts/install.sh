#!/bin/bash
set -e

echo "Installing Claude Code configuration..."

# 1. Verify we're in the repo
if [[ ! -f "README.md" ]] || [[ ! -d "rules" ]]; then
  echo "Error: Run this script from the claude-code-config repository root"
  exit 1
fi

# 2. Backup existing ~/.claude directory
if [[ -d "$HOME/.claude" ]]; then
  BACKUP_DIR="$HOME/.claude.backup.$(date +%Y%m%d_%H%M%S)"
  echo "Backing up existing ~/.claude to $BACKUP_DIR"
  mv "$HOME/.claude" "$BACKUP_DIR"
fi

# 3. Create directory structure
mkdir -p "$HOME/.claude"

# 4. Copy shareable configuration
echo "Copying configuration files..."
cp -r rules/ "$HOME/.claude/"
cp -r agents/ "$HOME/.claude/"
cp -r commands/ "$HOME/.claude/"
cp -r skills/ "$HOME/.claude/"
cp CLAUDE.md "$HOME/.claude/"

# 5. Install hooks (make executable)
echo "Installing hooks..."
mkdir -p "$HOME/.claude/hooks"
for hook_template in hooks/*.template; do
  hook_name=$(basename "$hook_template" .template)
  cp "$hook_template" "$HOME/.claude/hooks/$hook_name"
  chmod +x "$HOME/.claude/hooks/$hook_name"
done

# 6. Setup configuration from templates
echo "Setting up configuration files..."
if [[ ! -f "$HOME/.claude/settings.json" ]]; then
  cp config-templates/settings.json.template "$HOME/.claude/settings.json"
  # Replace ${CLAUDE_CONFIG_DIR} with actual path
  sed -i.bak "s|\${CLAUDE_CONFIG_DIR}|$HOME/.claude|g" "$HOME/.claude/settings.json"
  rm "$HOME/.claude/settings.json.bak"
fi

if [[ ! -f "$HOME/.claude/mcp.json" ]]; then
  cp config-templates/mcp.json.template "$HOME/.claude/mcp.json"
  # Replace ${HOME} with actual home directory
  sed -i.bak "s|\${HOME}|$HOME|g" "$HOME/.claude/mcp.json"
  rm "$HOME/.claude/mcp.json.bak"
fi

# 7. Setup environment variables
if [[ ! -f "$HOME/.claude/.env" ]]; then
  cp config-templates/env.example "$HOME/.claude/.env"
  echo ""
  echo "⚠️  IMPORTANT: Edit $HOME/.claude/.env to customize paths for this machine"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Edit $HOME/.claude/.env to set machine-specific paths"
echo "2. Verify hooks in $HOME/.claude/hooks/ work for your setup"
echo "3. Run 'claude' to start using your configuration"
