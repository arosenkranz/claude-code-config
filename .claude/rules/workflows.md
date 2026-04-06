# Workflows

## Architecture

This repo is a Claude Code marketplace with 3 plugins:
- `workflow-skills` — 92 skills invocable via `/name`
- `goldeneye-agents` — 9 specialized subagents
- `dev-environment` — lifecycle hooks, commands (coding standards), Claude Island

Plugins auto-discover their content via `${CLAUDE_PLUGIN_ROOT}`. No symlinks needed.

## Setting up on a new machine

```bash
git clone git@github.com:arosenkranz/claude-code-config.git ~/workspace/claude-code-config
```

Add to `~/.claude/settings.json`:
```json
{
  "extraKnownMarketplaces": {
    "arosenkranz-claude-plugins": {
      "source": { "source": "github", "repo": "arosenkranz/claude-code-config" }
    }
  },
  "enabledPlugins": {
    "workflow-skills@arosenkranz-claude-plugins": true,
    "goldeneye-agents@arosenkranz-claude-plugins": true,
    "dev-environment@arosenkranz-claude-plugins": true
  }
}
```

Copy and customize CLAUDE.md:
```bash
cp config-templates/CLAUDE.md.template ~/.claude/CLAUDE.md
```

## Migrating from old symlink setup

```bash
./scripts/migrate-to-marketplace.sh --dry-run   # Preview
./scripts/migrate-to-marketplace.sh             # Run
./scripts/migrate-to-marketplace.sh --restore   # Rollback if needed
```

## Adding a new skill

1. Create `plugins/workflow-skills/skills/<name>/SKILL.md` with `name` and `description` frontmatter
2. Add any references, templates, or scripts in the same directory
3. The skill is immediately discoverable via `/name` — no registration needed

## Adding a new agent

1. Create `plugins/goldeneye-agents/agents/<name>.md`
2. Include the agent's system prompt and trigger conditions
3. Auto-discovered — no registration needed

## Adding or modifying hooks

Edit `plugins/dev-environment/hooks/hooks.json` directly. The `${CLAUDE_PLUGIN_ROOT}` variable resolves to the plugin directory at runtime.

## Coding standards

Standards live in `plugins/dev-environment/commands/` and are:
- Invocable on-demand: `/dev-environment:coding-style`
- Symlinked to `~/.claude/rules/` by the migration script for always-active enforcement

## Local-only files (never tracked by git)

- `~/.claude/settings.json` — managed locally, runtime mutations never dirty the repo
- `~/.claude/CLAUDE.md` — machine-specific identity and context

## Running tests

```bash
bats tests/                             # All tests
bats tests/migrate-to-marketplace.bats  # Migration script tests
```
