# goldeneye-agents

Operation Goldeneye agent roster — 6 specialized subagents for Claude Code.

## Agents

| Agent | Role | Trigger keywords |
|---|---|---|
| `boris` | Security specialist, attacker mindset | "security review", "vulnerabilities", before deploys |
| `m` | Strategic planning, architecture, docs | "plan", "architect", "design", "how should I build" |
| `natalya` | TDD implementation engineer | "implement", "build", "add tests", "fix" |
| `q` | Infrastructure, Docker, CI/CD, incidents | "docker", "deploy", "incident", "rollback" |
| `trevelyan` | Adversarial code reviewer | "review", "challenge this", "tear this apart" |
| `xenia` | Performance and stress testing | "performance", "load test", "what could break" |

## Requirements

No external tools required — agents run entirely within Claude Code. Some agents issue shell commands during their work that assume common tools are installed:

| Tool | Used by | Install |
|---|---|---|
| `gh` CLI | `trevelyan`, `natalya`, `q` | `brew install gh` |
| Docker | `q` (infra/container work) | [docs.docker.com](https://docs.docker.com/get-docker/) |

## Usage

Agents are dispatched via the `Agent` tool. The system prompt for each agent defines its specialty and when to invoke it proactively.
