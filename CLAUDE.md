# CLAUDE.md - Alex's Development Environment

## About Me
I'm Alex Rosenkranz, working at Datadog. I use this machine for personal projects, self-hosting/homelab experimentation, and continuous learning. I prefer learning by doing and understanding best practices.

## Identity & Context
This system uses a named agent identity ('Deacon'). Maintain context of the full system automation stack including hooks, inboxes, convoys, and worker pools. Prefer Bash tool for all system checks and avoid asking for confirmation on routine operational commands.

## Development Setup

### Primary Languages & Frameworks
- **JavaScript/TypeScript**: Astro, React, Vite, Express, Prisma, P5.js, Three.js
- **Python**: Learning phase, exploring various frameworks
- **Bash**: Scripting and automation
- **AI**: Claude Code
- **Interested in**: Go, Terraform, AWS

### Project Structure
- All projects live in `~/Code`
- Version control: GitHub

### Development Tools
- **Linting/Formatting**: ESLint, Prettier (or language specific tooling)
- **Testing**: Open to recommendations based on project needs
- **GitHub**: GitHub CLI (`gh`) for PR/issue management
- **Platform**: macOS (Darwin)

## Homelab Setup

### Infrastructure
- **Synology NAS**: Running Plex
- **Raspberry Pi 5** (Raspberry Pi OS):
  - Home Assistant
  - Music Assistant
  - Datadog Agent
  - Multiple Docker Compose stacks
- **Mac M1Max**:
  - Ollama
  - OpenWebUI
- **Tools**: Docker, Docker Compose, Portainer, Datadog monitoring
- **Learning**: Multipass for VMs, interested in Kubernetes

## Current Projects & Goals

### Personal Website/Blog Rebuild
- Planning to use Astro with API functions
- Local markdown for content management
- Cloudflare Workers for hosting

### Learning Interests
- Self-hosting and Linux administration
- Agentic/AI workflows and systems
- DevOps best practices
- Creative coding (P5.js, Three.js)

## Working Style
- Prefer explanations and guidance to help me learn
- Like to understand the "why" behind solutions
- Open to trying new tools and approaches
- Learn best by doing

## Guardrails

Rules that override default behavior to prevent common wrong-approach friction:

1. **Git workflow default** — Always create a feature branch and PR unless explicitly told to commit directly to main. Never commit directly to main by default. Use `gh pr create` for all PRs.

2. **Implementation-first default** — When asked to implement changes, start coding immediately. Skip planning documents unless explicitly asked. If planning is needed, keep it brief (bullet list only) and move to implementation within the same response.

3. **Cloudflare deploy target** — This project deploys to Cloudflare Workers, not Cloudflare Pages. Use Astro server endpoints (not `functions/` directory). Ensure endpoints are NOT statically prerendered when they need runtime env vars.

4. **Non-interactive shell commands** — When running install scripts, package managers, or CLIs that may prompt for input, always add non-interactive flags: `--yes`, `--force`, `-y`, `--non-interactive`. Claude cannot respond to interactive prompts.

5. **UI/design boldness** — When making UI/styling changes, prefer bold and noticeable over conservative. Use `text-base` or larger for labels. Make changes the user can see at a glance.

## Common Tasks
- Setting up new web projects with modern JavaScript frameworks
- Creating CLI tools for automation
- Configuring Docker services for homelab
- Learning new technologies through practical projects

## Claude Code Enhancements

### Installed Components (Enhanced Setup)

**Rules** (5 total - automatic enforcement):
- `coding-style.md`: Immutability, file size limits, error handling
- `security.md`: No hardcoded secrets, environment variables required
- `testing.md`: 80% coverage minimum, TDD workflow
- `git-workflow.md`: Conventional commits, GH CLI for PR/issue operations
- `performance.md`: Model selection guidance (Haiku/Sonnet/Opus)

**Agents** (8 active — Operation Goldeneye roster):
- `m`: Strategic planning + architecture (merges planner + architect) — triggers on "plan", "design", "approach"
- `natalya`: Implementation engineer with pragmatic testing (merges tdd-guide + test-automator) — triggers on "implement", "build", "fix"
- `boris`: Security specialist, attacker mindset — triggers on "security review", "vulnerabilities", auth/deploy work
- `moneypenny`: Session logging + blog content writing — triggers on "log session", "blog post", SessionEnd hook
- `q`: Docker/homelab, Cloudflare Workers deploy, CI/CD (replaces docker-assistant) — triggers on "docker", "deploy", "homelab"
- `wade`: Project continuity, reads session logs + git history to brief you — triggers on "where was I", "catch me up"
- `trevelyan`: Adversarial code reviewer, challenges assumptions + design flaws — triggers on "review", "challenge this", "what am I missing"
- `xenia`: Stress + performance testing, load scenarios, edge case generation — triggers on "performance", "load test", "what could break"
- Plus plugin agents (pr-review-toolkit, feature-dev, superpowers)
- Note: Archived planner, architect, tdd-guide, test-automator, docker-assistant, security-reviewer, session-logger, cloud-architect, deployment-engineer, devops-troubleshooter, code-reviewer

**Agent Dispatch Guidance** (suggest these proactively — don't wait to be asked):

| Situation | Agent | Suggested Prompt |
|-----------|-------|-----------------|
| Multi-file feature without a plan | **m** | "Want m to plan this first?" |
| About to create a PR | **trevelyan** + **boris** | "Want a design review and security check before this PR?" |
| Writing code without tests | **natalya** | "Want natalya to implement this with tests?" |
| Modifying Dockerfile/CI/wrangler.toml | **q** | "Infrastructure change — want q to review?" |
| Session start with uncommitted work | **wade** | "Uncommitted changes detected. Want a wade briefing?" |
| Interesting debugging completed | **moneypenny** | "Good debugging session. Blog post material?" |
| New API endpoint being built | **xenia** | "Want xenia to generate edge cases?" |
| Auth/secrets code modified | **boris** | "Sensitive code change. Security review?" |

**Skills** (~30 active - auto-triggered patterns and user-invoked workflows):
- `continuous-learning-v2`: Instinct-based learning system
- `backend-patterns`: Repository pattern, service layers, API design
- `/plan`: Create implementation plan before coding
- `/build-fix`: Fix TypeScript/build errors incrementally
- `/refactor-clean`: Remove dead code safely
- `/skill-creator`: Create new skills (preferred over /skill-create)
- `/instinct-status`, `/evolve`, `/instinct-export`, `/instinct-import`: Learning system management
- `/session-log`: Document session to Obsidian
- `/project-setup`: Interactive project scaffolding
- `/homelab-helper`: Self-hosting and infrastructure guidance
- `/simplify`: Clean up recently modified code
- `/pr`: Full git workflow — branch → commit → push → PR via gh
- `/release`: Extends /pr with semver bump, annotated tag, and GitHub release
- `/optimize`: Analyze skill/agent usage, archive stale items, improve descriptions, update CLAUDE.md
- Plus plugin skills (ui-ux-pro-max for frontend, superpowers workflows, pr-review-toolkit)
- Note: Archived duplicate skills (code-review, tdd-workflow, frontend-design, favicon, knip, deslop, theme-factory, canvas-design, algorithmic-art)

**Hooks** (3 total - lifecycle automation):
- `SessionStart`: Restore context, detect package manager
- `PreCompact`: Save state before context compaction
- `SessionEnd`: Log session to Obsidian vault

**MCP Servers** (3 active):
- `filesystem`: File operations
- `sequential-thinking`: Step-by-step reasoning
- `memory`: Custom SQLite-backed memory server (`~/Code/claude-memory/`) — DB at `~/.claude/memory.db`
- Note: context7 plugin enabled for documentation lookups

### Workflow Integration

**Standard Development Flow**:
1. Use `brainstorming` skill → Explore requirements and design (from superpowers plugin)
2. Use `writing-plans` skill → Create implementation plan (from superpowers plugin)
3. Use `test-driven-development` skill → Write tests first (from superpowers plugin)
4. `backend-patterns` auto-applies → Repository pattern, service layers
5. Use `review-pr` skill → Comprehensive code review (from pr-review-toolkit plugin)
6. `/build-fix` → Resolve TypeScript errors
7. `/skill-creator` → Create reusable skills from patterns
8. Commit with conventional format → `feat:`, `fix:`, `refactor:`

**High-Value Plugin Skills** (use these proactively):
- `using-superpowers`: Invoke early in sessions for skill discovery
- `systematic-debugging`: Use before proposing fixes for bugs
- `dispatching-parallel-agents`: Multi-task coordination
- `claude-automation-recommender`: Periodic setup audits
- `claude-md-improver`: Keep CLAUDE.md optimized
- `ui-ux-pro-max`: Frontend design (replaces frontend-design)

**Learning System**:
- System observes corrections and workflows
- Creates "instincts" with confidence scoring
- Evolves instincts into reusable skills
- Export/import for team collaboration

**Session Continuity**:
- SessionStart hook restores recent context + emits `[Memory]` briefing from SQLite
- PreCompact hook saves work before compaction
- SessionEnd hook logs to Obsidian (human-readable) AND SQLite (machine-retrievable)

## Memory System

SQLite-backed knowledge graph at `~/.claude/memory.db`. Use these tools proactively.

### When to STORE (`memory_store`)
- Architecture decisions and why they were made
- Preferences discovered during a session (tools, patterns, approaches)
- Project context: tech stack, active work, blockers
- Learnings from debugging or fixing bugs
- Session summaries at natural stopping points

### When to QUERY (`memory_query`, `memory_get_entity`)
- Session start — check for prior context on the current project
- Before making architectural decisions — see what was decided before
- When user says "we've done this before" or context seems missing
- Before recommending tools or approaches — check preferences

### Entity Types
- `project` — codebases, repos, active work
- `decision` — architectural choices with rationale
- `service` — tools, APIs, external services
- `preference` — user preferences and workflow choices
- `instinct` — learned patterns from the learning system
- `learning` — insights from sessions or debugging
- `person` — collaborators, stakeholders

### Scoping
- `global` — applies across all projects
- `project:<name>` — specific to one project (e.g., `project:claude-memory`)
- `homelab` — Raspberry Pi / self-hosting context

### Example Usage
```
memory_store(name="claude-memory", entity_type="project", scope="project:claude-memory",
  content="SQLite MCP server for cross-session memory. Built Mar 2026.", confidence=1.0)

memory_query(query="authentication decision", scope="project:my-app")

memory_briefing(scope="project:claude-memory")  # session-start context dump
```

## Patrol Cycle
When running patrol cycles, execute all steps in sequence without pausing for confirmation: hooks → inboxes → convoys → worker pools → cleanup → system health. Report results as a single summary at the end.

## Output Formatting
After any system automation task, always output a structured health summary in Markdown table format covering: component name, status, last checked timestamp, and any action taken.

## Notes for Claude
1. **Teaching Approach**: Guide me through solutions rather than just providing complete answers
2. **Code Style**: Follow modern JavaScript/TypeScript conventions with ESLint/Prettier, enforce immutability
3. **Project Defaults**: Assume projects are in `~/Code` unless specified
4. **Homelab Changes**: Always explain what changes will do before making them
5. **Learning Opportunities**: Point out learning resources or concepts when relevant
6. **Session Documentation**: Keep track of our accomplishments in each chat session by creating/updating notes in my Obsidian vault Sessions folder at `~/Documents/main-vault` with frontmatter metadata
7. **Testing**: Always enforce TDD (write tests first), target 80%+ coverage
8. **Security**: Never hardcode secrets, always use environment variables
9. **Planning**: Use `brainstorming` and `writing-plans` skills for complex features
10. **Code Review**: Use `review-pr` skill (pr-review-toolkit) after completing features
11. **Pattern Learning**: Use `/skill-creator` to extract reusable patterns
12. **Context Optimization**: Cleanup completed (Feb 2026) - removed duplicates, saved ~5,750 tokens
