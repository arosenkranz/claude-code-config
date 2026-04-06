# workflow-skills

92 productivity skills for Claude Code, invocable via `/skill-name`.

## Usage

Skills are auto-discovered by Claude Code when this plugin is enabled. Invoke any skill with:

```
/morning-plan
/course-review
/doc-generate
```

## Notable Skills

- `morning-plan` — Daily standup and task planning
- `course-review` — Learning content review
- `doc-generate` — Documentation generation
- `agent-browser` — Browser automation via Playwright
- `api-scaffold` — REST API scaffolding
- `continuous-learning-v2` — Tool use pattern observation

## Hooks

`observe.sh` fires on every `PreToolUse` and `PostToolUse` to capture tool patterns for the continuous-learning skill.
