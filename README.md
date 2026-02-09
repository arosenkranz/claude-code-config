# claude-code-config

Shareable Claude Code configuration using symlink-based sync. This repo contains rules, agents, commands, skills, and hooks that extend Claude Code's capabilities.

## What's Included

### Rules (5)
Auto-enforced coding standards:
- `coding-style.md` - Immutability, file organization, error handling
- `security.md` - Secret management, input validation
- `testing.md` - 80% coverage minimum, TDD workflow
- `git-workflow.md` - Conventional commits, PR workflow
- `performance.md` - Model selection guidance

### Agents (11)
Specialized expertise:
- `planner` - Implementation planning
- `architect` - Architectural decisions
- `code-reviewer` - Security, quality, performance review
- `tdd-guide` - Test-driven development
- `security-reviewer` - Security vulnerability review
- Plus 6 domain-specific agents (cloud, deployment, devops, docker, session-logger, test-automator)

### Commands (22)
Explicit workflows:
- `/plan` - Create implementation plan
- `/tdd` - Enforce test-first development
- `/code-review` - Review uncommitted changes
- Plus 19 specialized commands

### Skills (28)
Auto-triggered domain expertise:
- `continuous-learning-v2` - Instinct-based learning
- `backend-patterns` - Repository pattern, API design
- `tdd-workflow` - Test-driven development
- `agent-browser` - Browser automation
- `deslop` - Remove AI code slop
- `favicon` - Generate favicon sets
- `find-skills` - Discover installable skills
- `knip` - Dead code detection
- `rams` - Accessibility & design review
- `reclaude` - Refactor CLAUDE.md files
- `simplify` - Code simplification
- `skill-creator` - Skill creation guide (with package/validate scripts)
- Plus 16 language/framework skills

### Hooks (3)
Lifecycle automation:
- `SessionStart` - Restore context, detect package manager
- `PreCompact` - Save state before compaction
- `SessionEnd` - Log session to Obsidian vault

## Installation

### Fresh Install (New Machine)

```bash
git clone <your-repo-url> ~/Code/claude-code-config
cd ~/Code/claude-code-config
./install.sh
```

This creates symlinks from `~/.claude/` to this repo. Local-only items are preserved.

### Dry-Run First (Recommended)

```bash
./install.sh --dry-run
```

Preview what would be changed without making any modifications.

### Handling Conflicts

If a local file differs from the repo version, you'll be prompted:
- `[r]` Use repo version (backs up local first)
- `[l]` Keep local version (skip this item)
- `[d]` Show diff between versions
- `[q]` Quit

Use `--force` to automatically use repo versions (still creates backups).

## How It Works

### Symlink-Based Sync

Unlike copy-based approaches, this repo uses **symlinks**. The actual files live in the git repo, and `~/.claude/` contains symlinks pointing to them.

**Benefits:**
- Edits in `~/.claude/` automatically tracked by git
- `git diff` and `git commit` just work
- No need to manually copy changes back to repo

**What gets symlinked:**
- `CLAUDE.md`, `settings.json`, `statusline.sh` (root files)
- `agents/*.md` (per-file symlinks)
- `commands/*.md` (per-file symlinks)
- `rules/*.md` (per-file symlinks)
- `skills/*/` (per-directory symlinks)
- `hooks/*.sh` (per-file symlinks)

**What stays local:**
- `mcp.json` - Copied from template with `$HOME` substitution
- `settings.local.json` - Machine-specific permissions
- `.env` - Machine-specific environment variables

## Managing Your Config

### Check Sync Status

```bash
./sync.sh
```

Shows status of all items:
- `✓` synced (symlinked to repo)
- `○` local only (not in repo)
- `⚠` conflict (exists in both)
- `→` external (symlinked elsewhere)

### Add Local Item to Repo

```bash
./sync.sh add skill my-skill
./sync.sh add agent my-agent
./sync.sh add command my-command
./sync.sh add rule my-rule
./sync.sh add hook my-hook
```

Copies item to repo, replaces local with symlink.

Skills are validated before adding - must have SKILL.md with `name` and `description` in frontmatter.

### Remove Item from Repo

```bash
./sync.sh remove skill my-skill
```

Removes from repo but keeps local copy.

### Pull Latest Changes

```bash
./sync.sh pull
```

Pulls from git and reinstalls symlinks.

### Push Changes

```bash
./sync.sh push
```

Commits and pushes your changes to the repo.

### Validate Skills

```bash
./sync.sh validate
```

Checks all skills for valid frontmatter.

### Backups

All destructive operations create timestamped backups in `.backup/`.

```bash
./sync.sh backups            # List available backups
./sync.sh undo               # Restore from last backup
```

### Dry-Run Mode

Preview any command without making changes:

```bash
./sync.sh --dry-run add skill my-skill
./install.sh --dry-run
```

## Keeping Items Local-Only

Any item in `~/.claude/` that isn't symlinked stays local. The install script only creates symlinks for what's in this repo—it never deletes local files.

Use this for:
- Work-specific configurations
- Experimental features
- Machine-specific customizations

## Directory Structure

```
claude-code-config/
├── install.sh                  # Symlink installer
├── sync.sh                     # Sync manager
├── CLAUDE.md                   # Global Claude configuration
├── settings.json               # Portable settings (~ paths)
├── statusline.sh               # Status bar script
├── agents/                     # Subagent definitions (*.md)
├── commands/                   # Command definitions (*.md)
├── rules/                      # Rule definitions (*.md)
├── skills/                     # Skill directories
├── hooks/                      # Hook scripts (*.sh)
├── .claude/rules/              # Project-level rules (for this repo)
│   ├── testing.md              # Bats testing conventions
│   └── workflows.md            # Symlink workflow docs
├── config-templates/           # Machine-specific templates
│   ├── mcp.json.template
│   └── env.example
├── scripts/
│   └── sanitize-check.sh       # Pre-commit secret checker
├── .backup/                    # Gitignored backups
└── README.md
```

## MCP Servers

The repo includes a template for 4 MCP servers:
- `memory` - Knowledge graph for entity/relation storage
- `filesystem` - File operations
- `sequential-thinking` - Step-by-step reasoning
- `task-master-ai` - Task management

Configured via `mcp.json` (copied from template on install).

## Contributing to This Repo

When adding new components:

1. Add the files to the appropriate directory
2. Test locally first
3. Run `./scripts/sanitize-check.sh` to verify no secrets
4. Commit and push
5. Run `./sync.sh pull` on other machines

## Security

**NEVER commit:**
- API keys, tokens, or credentials
- Session history or personal data
- Absolute paths with your username

The `sanitize-check.sh` script helps prevent these issues.

## Troubleshooting

### Session Logger Not Working

Check that your Obsidian vault path is correct:

```bash
cat ~/.claude/.env
# Verify CLAUDE_VAULT_PATH is set correctly
```

### Hooks Not Executing

Verify hooks are executable:

```bash
ls -la ~/.claude/hooks/
# Should show -rwxr-xr-x permissions
```

### Package Manager Detection

Set your preferred package manager:

```bash
echo 'export CLAUDE_PACKAGE_MANAGER=pnpm' >> ~/.zshrc
source ~/.zshrc
```

## Tips

- Edit files in `~/.claude/` (they're symlinked to the repo)
- Use `./sync.sh` frequently to check status
- Keep CLAUDE.md concise (<100 lines) - move details to rules files
- Test skills locally before adding to repo
- Use meaningful git commit messages
- Backup before major changes (install script does this automatically)

## License

Private repository for personal use.
