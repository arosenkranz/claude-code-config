# goldeneye-agents

Operation Goldeneye agent roster — 8 specialized subagents for Claude Code.

## Agents

| Agent | Role | Trigger keywords |
|---|---|---|
| `boris` | Security specialist, attacker mindset | "security review", "vulnerabilities", before deploys |
| `m` | Strategic planning, architecture, docs | "plan", "architect", "design", "how should I build" |
| `moneypenny` | Session logging, blog content, brag docs | "log session", "blog post", "brag doc" |
| `natalya` | TDD implementation engineer | "implement", "build", "add tests", "fix" |
| `q` | Infrastructure, Docker, CI/CD, incidents | "docker", "deploy", "incident", "rollback" |
| `trevelyan` | Adversarial code reviewer | "review", "challenge this", "tear this apart" |
| `wade` | Project continuity, session catch-up | "where was I", "catch me up", "brief me" |
| `xenia` | Performance and stress testing | "performance", "load test", "what could break" |

## Usage

Agents are dispatched via the `Agent` tool. The system prompt for each agent defines its specialty and when to invoke it proactively.
