# Disabled skills

Skills in this directory are **kept but not loaded**. Claude Code only auto-discovers
skills under `skills/`, so moving a skill here removes it from the active set without
deleting it.

To re-enable a skill, move it back:

```bash
git mv plugins/workflow-skills/_disabled-skills/<name> plugins/workflow-skills/skills/<name>
```

## Currently disabled

- **start-task** — Jira/TRAIN-board task starter. Disabled during the 2026-06-28 config
  audit: work-specific (Datadog Jira) and not used on personal projects. Re-enable if
  you start driving personal work from Jira tickets.
