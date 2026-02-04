# CLAUDE.md - Alex's Development Environment

## About Me
I'm Alex Rosenkranz, working at Datadog. I use this machine for personal projects, self-hosting/homelab experimentation, and continuous learning. I prefer learning by doing and appreciate guidance over having things done for me.

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

**Agents** (10 total - specialized expertise):
- `planner`: Create step-by-step implementation plans
- `architect`: Architectural decisions and trade-off analysis
- `code-reviewer`: Security, quality, performance review
- `tdd-guide`: Test-driven development specialist
- Plus 6 custom agents (session-logger, docker-assistant, cloud-architect, deployment-engineer, devops-troubleshooter, test-automator)

**Skills** (19 total - auto-triggered patterns):
- `continuous-learning-v2`: Instinct-based learning system
- `backend-patterns`: Repository pattern, service layers, API design
- `tdd-workflow`: Test-driven development with 80%+ coverage
- Plus 16 custom skills (frontend, homelab, creative coding, etc.)

**Commands** (22 total - explicit tools):
- `/plan`: Create implementation plan before coding
- `/tdd`: Enforce test-first development
- `/code-review`: Review uncommitted changes
- `/build-fix`: Fix TypeScript/build errors incrementally
- `/refactor-clean`: Remove dead code safely
- `/skill-create`: Extract patterns from git history
- `/instinct-status`: View learned patterns
- `/evolve`: Cluster instincts into skills/commands/agents
- `/instinct-export`: Share patterns with team
- `/instinct-import`: Import patterns from others
- Plus 12 custom commands

**Hooks** (3 total - lifecycle automation):
- `SessionStart`: Restore context, detect package manager
- `PreCompact`: Save state before context compaction
- `SessionEnd`: Log session to Obsidian vault

**MCP Servers** (4 total):
- `memory`: Knowledge graph for entity/relation storage
- `filesystem`: File operations
- `sequential-thinking`: Step-by-step reasoning
- `task-master-ai`: Task management

### Workflow Integration

**Standard Development Flow**:
1. `/plan` feature → Get comprehensive implementation plan
2. `/tdd` feature → Write tests first, implement to pass
3. `backend-patterns` auto-applies → Repository pattern, service layers
4. `/code-review` → Catch security/quality issues
5. `/build-fix` → Resolve TypeScript errors
6. `/skill-create --instincts` → Extract learned patterns
7. Commit with conventional format → `feat:`, `fix:`, `refactor:`

**Learning System**:
- System observes corrections and workflows
- Creates "instincts" with confidence scoring
- Evolves instincts into reusable skills/commands
- Export/import for team collaboration

**Session Continuity**:
- SessionStart hook restores recent context
- PreCompact hook saves work before compaction
- SessionEnd hook logs to Obsidian with metadata

## Notes for Claude
1. **Teaching Approach**: Guide me through solutions rather than just providing complete answers
2. **Code Style**: Follow modern JavaScript/TypeScript conventions with ESLint/Prettier, enforce immutability
3. **Project Defaults**: Assume projects are in `~/Code` unless specified
4. **Homelab Changes**: Always explain what changes will do before making them
5. **Learning Opportunities**: Point out learning resources or concepts when relevant
6. **Session Documentation**: Keep track of our accomplishments in each chat session by creating/updating notes in my Obsidian vault Sessions folder at `~/Documents/main-vault` with frontmatter metadata
7. **Testing**: Always enforce TDD (write tests first), target 80%+ coverage
8. **Security**: Never hardcode secrets, always use environment variables
9. **Planning**: Use `/plan` for complex features before implementation
10. **Code Review**: Use `/code-review` after completing features
11. **Pattern Learning**: Run `/skill-create --instincts` after completing significant work