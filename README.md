# claude-code-config

A personal Claude Code marketplace with 3 plugins: 92 skills, 9 agents, and a full dev environment automation stack (hooks, coding standards, Claude Island integration).

## Setup on a new machine

### 1. Clone the repo

```bash
git clone git@github.com:arosenkranz/claude-code-config.git ~/workspace/claude-code-config
```

### 2. Register the marketplace in `~/.claude/settings.json`

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

See `config-templates/settings.json.template` for a complete starting point.

### 3. Create your CLAUDE.md

```bash
cp config-templates/CLAUDE.md.template ~/.claude/CLAUDE.md
# Edit it — add your machine-specific paths, identity, infrastructure context
```

---

## Plugins

### workflow-skills

92 skills invocable via `/skill-name`:

```
/morning-plan       /course-review      /doc-generate
/api-scaffold       /agent-browser      /patrol
```

See `plugins/workflow-skills/README.md` for the full list.

### goldeneye-agents

9 specialized subagents (Operation Goldeneye roster):

| Agent | Role |
|---|---|
| `boris` | Security specialist, attacker mindset |
| `m` | Strategic planning, architecture, docs |
| `moneypenny` | Session logging, blog content, brag docs |
| `natalya` | TDD implementation engineer |
| `q` | Infrastructure, Docker, CI/CD, incidents |
| `trevelyan` | Adversarial code reviewer |
| `wade` | Project continuity, session catch-up |
| `xenia` | Performance and stress testing |
| `jira-manager` | Jira ticket automation |

### dev-environment

Lifecycle hooks, coding standards, and Claude Island integration:

- **Hooks**: `session-start.sh`, `session-logger.sh`, `pre-compact.sh`, `post-edit-format.sh`, `check-console-log.sh`, `claude-island-state.py`
- **Commands** (coding standards): `/dev-environment:coding-style`, `/dev-environment:git-workflow`, `/dev-environment:security`, `/dev-environment:testing`, `/dev-environment:performance`, `/dev-environment:memory-system`

---

## Prerequisites

| Tool | Purpose | Install |
|---|---|---|
| [Claude Code](https://claude.ai/code) | Required | See Anthropic docs |
| Node.js (v18+) | MCP servers via `npx` | `brew install node` |
| [cmux](https://github.com/nicholasgasior/cmux) | workspace skill | `brew install cmux` |
| [yazi](https://github.com/sxyazi/yazi) | workspace skill | `brew install yazi` |
| [lazygit](https://github.com/jesseduffield/lazygit) | workspace skill | `brew install lazygit` |
| [agent-browser](https://www.npmjs.com/package/agent-browser) | browser automation | `npm install -g agent-browser` |

cmux, yazi, lazygit, and agent-browser are only required for specific skills.

---

## Local-only files

These are never tracked by git — each machine maintains its own:

- `~/.claude/settings.json` — model, permissions, plugins, MCP config
- `~/.claude/CLAUDE.md` — identity, machine paths, infrastructure context

Start from the templates in `config-templates/`.

