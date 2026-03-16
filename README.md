# claude-code-config

Shareable Claude Code configuration using symlink-based sync. Contains rules, agents, skills, hooks, and MCP server config that extend Claude Code's capabilities — designed to work as a personal dev environment and as a starting point for others.

## Prerequisites

Before installing, make sure you have:

| Tool | Purpose | Install |
|------|---------|---------|
| [Claude Code](https://claude.ai/code) | Required — this config extends it | See Anthropic docs |
| Node.js (v18+) | MCP servers run via `npx` | `brew install node` or [nvm](https://github.com/nvm-sh/nvm) |
| [cmux](https://github.com/nicholasgasior/cmux) | Workspace skill — 3-pane terminal layout | `brew install cmux` |
| [yazi](https://github.com/sxyazi/yazi) | Workspace skill — file navigation pane | `brew install yazi` |
| [lazygit](https://github.com/jesseduffield/lazygit) | Workspace skill — git diff pane | `brew install lazygit` |
| [bats](https://github.com/bats-core/bats-core) | Running tests in this repo | `brew install bats-core` |
| [agent-browser](https://www.npmjs.com/package/agent-browser) | Browser automation skill | `npm install -g agent-browser` |

> cmux, yazi, lazygit, and agent-browser are only required for specific skills. The core config (rules, agents, MCP servers) works without them.

## What's Included

### Rules (5)
Auto-enforced coding standards that apply to every session:
- `coding-style.md` — Immutability, file size limits, error handling
- `security.md` — No hardcoded secrets, environment variables required
- `testing.md` — 80% coverage minimum, TDD workflow
- `git-workflow.md` — Conventional commits, GH CLI for PR/issue operations
- `performance.md` — Model selection guidance (Haiku/Sonnet/Opus)

### Agents (8) — Operation Goldeneye Roster
Specialized subagents dispatched for specific tasks:
- `m` — Strategic planning + architecture decisions
- `natalya` — Implementation engineer with pragmatic testing
- `boris` — Security specialist with attacker mindset
- `trevelyan` — Adversarial code reviewer, challenges assumptions
- `xenia` — Stress and performance testing specialist
- `q` — Docker/homelab, Cloudflare Workers, CI/CD
- `wade` — Project continuity — reads session logs and git history
- `moneypenny` — Session logging + blog content writing

### Skills (~35)
Auto-triggered domain expertise and user-invocable workflows. Key ones:
- `workspace` — Set up 3-pane cmux session (lazygit + yazi)
- `continuous-learning-v2` — Instinct-based learning system
- `agent-browser` — Browser automation (requires `agent-browser` CLI)
- `backend-patterns` — Repository pattern, service layers, API design
- `skill-creator` — Guide for creating new skills
- `find-skills` — Discover installable skills from the community
- `pr`, `release` — Full git → PR → release workflows
- `patrol` — Automated health check cycle
- Language/framework skills: `typescript-pro`, `javascript-pro`, `python-pro`, `golang-pro`, `frontend-developer`, `backend-architect`, `terraform-specialist`, `mcp-builder`

### Hooks (3)
Lifecycle automation that runs without any invocation:
- `SessionStart` — Restore context, detect package manager
- `PreCompact` — Save state before context compaction
- `SessionEnd` — Log session to Obsidian vault

### MCP Servers (4)
Configured via `mcp.json` (copied from template on install):
- `memory` — Knowledge graph for cross-session entity/relation storage
- `filesystem` — File operations
- `sequential-thinking` — Step-by-step reasoning
- `task-master-ai` — Task management

## Agent Dispatch Guide

Claude will suggest these proactively, but you can invoke them explicitly too:

| Situation | Agent | Trigger phrases |
|-----------|-------|----------------|
| Multi-file feature, no plan yet | **m** | "plan", "design", "how should I build" |
| Implementing features or fixing bugs | **natalya** | "implement", "build", "fix", "add tests" |
| About to create a PR or deploy | **trevelyan** + **boris** | "review", "I think this is done" |
| Auth, secrets, or security-sensitive code | **boris** | "security review", "vulnerabilities" |
| Docker, CI/CD, Cloudflare, homelab | **q** | "docker", "deploy", "homelab", "build" |
| Load testing, edge cases, perf analysis | **xenia** | "performance", "what could break", "load test" |
| Returning to a project after time away | **wade** | "where was I", "catch me up", "brief me" |
| Session wrap-up or blog material | **moneypenny** | "log session", "blog post" |

## Installation

### Fresh Install (New Machine)

```bash
git clone <your-repo-url> ~/Code/claude-code-config
cd ~/Code/claude-code-config
./install.sh
```

This creates symlinks from `~/.claude/` pointing to this repo. Local-only items are preserved.

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
- Edits in `~/.claude/` are automatically tracked by git
- `git diff` and `git commit` just work
- No need to manually copy changes back to repo

**What gets symlinked:**
- `CLAUDE.md`, `settings.json`, `statusline.sh` (root files)
- `agents/*.md` (per-file symlinks)
- `rules/*.md` (per-file symlinks)
- `skills/*/` (per-directory symlinks)
- `hooks/*.sh` (per-file symlinks)

**What stays local:**
- `mcp.json` — Copied from template with `$HOME` substitution
- `settings.local.json` — Machine-specific permissions
- `.env` — Machine-specific environment variables

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
./sync.sh add rule my-rule
./sync.sh add hook my-hook
```

Copies item to repo and replaces local with a symlink. Skills are validated before adding — must have `SKILL.md` with `name` and `description` in frontmatter.

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

## Directory Structure

```
claude-code-config/
├── install.sh                  # Symlink installer
├── sync.sh                     # Sync manager
├── CLAUDE.md                   # Global Claude configuration
├── settings.json               # Portable settings
├── statusline.sh               # Status bar script
├── agents/                     # Subagent definitions (*.md)
├── rules/                      # Rule definitions (*.md)
├── skills/                     # Skill directories (each has SKILL.md)
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

## Keeping Items Local-Only

Any item in `~/.claude/` that isn't symlinked stays local. The install script only creates symlinks for what's in this repo — it never deletes local files.

Use this for:
- Work-specific configurations
- Experimental or in-progress skills
- Machine-specific customizations

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

If not:
```bash
chmod +x ~/.claude/hooks/*.sh
```

### Package Manager Detection

Set your preferred package manager:

```bash
echo 'export CLAUDE_PACKAGE_MANAGER=pnpm' >> ~/.zshrc
source ~/.zshrc
```

### MCP Servers Not Connecting

MCP servers run via `npx` — make sure Node.js is installed and `npx` is in your PATH:

```bash
which npx && npx --version
```

If `mcp.json` is missing, re-run the installer:

```bash
./install.sh
```

### agent-browser Skill Not Working

Install the CLI globally:

```bash
npm install -g agent-browser
agent-browser --version
```

### Workspace Skill Failing

Requires cmux, yazi, and lazygit. Install all three:

```bash
brew install cmux yazi lazygit
```

## Security

**Never commit:**
- API keys, tokens, or credentials
- Session history or personal data
- Absolute paths with your username

Run the sanitize check before pushing:

```bash
./scripts/sanitize-check.sh
```

## Tips

- Edit files in `~/.claude/` directly — they're symlinked to the repo, so changes are tracked automatically
- Use `./sync.sh` frequently to check status
- Keep `CLAUDE.md` concise — move detail into rules files
- Test skills locally before adding to repo with `./sync.sh add`
- Use meaningful conventional commit messages (`feat:`, `fix:`, `chore:`)

## License

Private repository for personal use.
