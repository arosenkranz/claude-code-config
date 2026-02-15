# CLAUDE.md - Alex's Development Environment

## About Me
I'm Alex Rosenkranz, working at Datadog. I use this machine for personal projects, self-hosting/homelab experimentation, and continuous learning. I prefer learning by doing and appreciate guidance over having things done for me.

## Identity & Context
This system uses a named agent identity ('Deacon'). Maintain context of the full system automation stack including hooks, inboxes, convoys, and worker pools. Prefer Bash tool for all system checks and avoid asking for confirmation on routine operational commands.

## Development Setup

### Primary Languages & Frameworks
- **JavaScript/TypeScript**: Astro, React, Vite, Express, Prisma, P5.js, Three.js
- **Python**: Learning phase, exploring various frameworks
- **Bash**: Scripting and automation
- **Interested in**: Go, Terraform, AWS

### Project Structure
- All projects live in `~/Code`
- Version control: GitHub

### Development Tools
- **Linting/Formatting**: ESLint, Prettier
- **Testing**: Open to recommendations based on project needs
- **Platform**: macOS (Darwin)

## Homelab Setup

### Infrastructure
- **Synology NAS**: Running Plex
- **Raspberry Pi 5** (Raspberry Pi OS):
  - Home Assistant
  - Music Assistant
  - Datadog Agent
  - Multiple Docker Compose stacks
- **Tools**: Docker, Docker Compose, Portainer, Datadog monitoring
- **Learning**: Multipass for VMs, interested in Kubernetes

## Current Projects & Goals

### Personal Website/Blog Rebuild
- Planning to use Astro with API functions
- Local markdown for content management
- Self-hosted deployment

### Learning Interests
- Self-hosting and Linux administration
- AWS and cloud infrastructure
- Terraform for infrastructure as code
- DevOps best practices
- Creative coding (P5.js, Three.js)

## Working Style
- Prefer explanations and guidance to help me learn
- Like to understand the "why" behind solutions
- Open to trying new tools and approaches
- Learn best by doing

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
- `git-workflow.md`: Conventional commits, PR workflow
- `performance.md`: Model selection guidance (Haiku/Sonnet/Opus)

**Agents** (6 active - specialized expertise):
- `planner`: Create step-by-step implementation plans
- `architect`: Architectural decisions and trade-off analysis
- `tdd-guide`: Test-driven development specialist
- `docker-assistant`: Container and Docker Compose expertise
- `test-automator`: Test suite creation and CI setup
- `security-reviewer`: Security vulnerability scanning
- Plus plugin agents (pr-review-toolkit, feature-dev, superpowers)
- Note: Archived cloud-architect, deployment-engineer, devops-troubleshooter, code-reviewer (use pr-review-toolkit instead)

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
- Plus plugin skills (ui-ux-pro-max for frontend, superpowers workflows, pr-review-toolkit)
- Note: Archived duplicate skills (code-review, tdd-workflow, frontend-design, favicon, knip, deslop, theme-factory, canvas-design, algorithmic-art)

**Hooks** (3 total - lifecycle automation):
- `SessionStart`: Restore context, detect package manager
- `PreCompact`: Save state before context compaction
- `SessionEnd`: Log session to Obsidian vault

**MCP Servers** (2 active):
- `filesystem`: File operations
- `sequential-thinking`: Step-by-step reasoning
- Note: Disabled memory (connection issues), task-master-ai (stale), greptile (unused)
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
- SessionStart hook restores recent context
- PreCompact hook saves work before compaction
- SessionEnd hook logs to Obsidian with metadata

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