# Performance Optimization

## Model Selection Strategy

Default to the latest, most capable Claude models. Current lineup: **Opus 4.8** (my default), **Sonnet 4.6**, **Haiku 4.5**, **Fable 5**.

**Haiku 4.5** (fast, cheap):
- Lightweight agents with frequent invocation
- Mechanical edits, worker agents in multi-agent systems

**Sonnet 4.6** (strong coding, lower cost than Opus):
- Routine development work where Opus is overkill
- High-volume subagent fan-out

**Opus 4.8** (deepest reasoning — my session default):
- Main development work, orchestration, architecture
- Complex debugging and research/analysis
- Fast mode (`/fast`) keeps Opus quality with faster output

## Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

## Ultrathink + Plan Mode

For complex tasks requiring deep reasoning:
1. Use `ultrathink` for enhanced thinking
2. Enable **Plan Mode** for structured approach
3. "Rev the engine" with multiple critique rounds
4. Use split role sub-agents for diverse analysis

## Build Troubleshooting

If build fails:
1. Analyze error messages carefully
2. Fix incrementally, one error at a time
3. Verify after each fix
4. Use `/build-fix` skill for TypeScript build errors
