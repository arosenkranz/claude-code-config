# Claude Code Configuration

Personal Claude Code setup for Alex Rosenkranz - shareable across laptops.

## Features

- **5 Auto-Enforcement Rules**: Coding style, security, testing, git workflow, performance
- **10 Specialized Agents**: Planner, architect, TDD guide, code reviewer, and more
- **22 Explicit Commands**: `/plan`, `/code-review`, `/skill-create`, instinct management, etc.
- **22 Auto-Triggered Skills**: Continuous learning, backend patterns, TDD workflow, etc.
- **3 Lifecycle Hooks**: Session start, pre-compact, session logger

## Installation

### Fresh Install (New Machine)

```bash
# 1. Clone this repository
git clone <your-private-repo-url> ~/claude-code-config
cd ~/claude-code-config

# 2. Run installation script
./scripts/install.sh

# 3. Customize for your machine
vi ~/.claude/.env
# Set: CLAUDE_VAULT_PATH, CLAUDE_SESSION_LOG_DIR, etc.

# 4. Verify setup
claude --version
```

### Sync Updates (Existing Install)

```bash
cd ~/claude-code-config
./scripts/sync.sh
```

## Customization

### Environment Variables

Edit `~/.claude/.env` to customize:
- `CLAUDE_VAULT_PATH`: Obsidian vault location
- `CLAUDE_SESSION_LOG_DIR`: Session log directory
- `CLAUDE_LOG_SESSIONS`: Enable/disable session logging

### Machine-Specific Overrides

- `~/.claude/settings.json`: Hook paths, plugin configuration
- `~/.claude/mcp.json`: MCP server arguments and paths
- Hook scripts: Modify behavior for your environment

## Security

**NEVER commit:**
- API keys, tokens, or credentials
- Session history or personal data
- Absolute paths with your username

**Pre-commit checks:**

```bash
# Setup git hook for automatic checking
ln -s ../../scripts/sanitize-check.sh .git/hooks/pre-commit
```

## Directory Structure

### Shared (in repo)

```
claude-code-config/
├── CLAUDE.md                    # Personal development guidelines
├── config-templates/            # Templates for machine-specific files
│   ├── settings.json.template
│   ├── mcp.json.template
│   └── env.example
├── rules/                       # Auto-enforcement rules (5 files)
├── agents/                      # Specialized agents (10 files)
├── commands/                    # Explicit commands (22 files)
├── skills/                      # Auto-triggered patterns (22 skills)
├── hooks/                       # Lifecycle automation (3 hooks)
└── scripts/                     # Installation & sync utilities
```

### Local only (never committed)

- `projects/`, `session-env/`, `history.jsonl`
- `plugins/`, `debug/`, `cache/`
- `settings.json`, `mcp.json`, `.env`

## Maintenance

### Adding New Components

1. Add to appropriate directory (rules/, agents/, etc.)
2. Run `./scripts/sanitize-check.sh` to verify no secrets
3. Commit and push
4. Run `./scripts/sync.sh` on other machines

### Updating on Other Machines

```bash
cd ~/claude-code-config
git pull
./scripts/sync.sh
```

## Components Overview

### Rules (5)
- `coding-style.md`: Immutability, file organization, error handling
- `security.md`: No hardcoded secrets, input validation
- `testing.md`: 80% coverage minimum, TDD workflow
- `git-workflow.md`: Conventional commits, PR workflow
- `performance.md`: Model selection guidance

### Agents (10)
- `planner`: Create implementation plans
- `architect`: Architectural decisions
- `code-reviewer`: Security, quality, performance review
- `tdd-guide`: Test-driven development specialist
- Plus 6 domain-specific agents

### Commands (22)
- `/plan`: Create implementation plan
- `/tdd`: Enforce test-first development
- `/code-review`: Review uncommitted changes
- `/build-fix`: Fix TypeScript/build errors
- `/skill-create`: Extract patterns from git history
- `/instinct-status`: View learned patterns
- `/evolve`: Cluster instincts into skills
- Plus 15 more

### Skills (22)
- `continuous-learning-v2`: Instinct-based learning
- `backend-patterns`: Repository pattern, service layers
- `tdd-workflow`: Test-driven development
- `frontend-developer`: React components and UI
- Plus 18 domain-specific skills

### Hooks (3)
- `SessionStart`: Restore context, detect package manager
- `PreCompact`: Save state before context compaction
- `SessionEnd`: Log session to Obsidian vault

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

## License

Private repository - for personal use only.
