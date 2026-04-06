---
name: improve-skills
description: Reflects on recent session work and systematically improves existing skills and agents in ~/.claude/. Audits for token efficiency, accuracy, and robustness, then makes edits autonomously. Invoke after sessions where you used skills or identified friction points.
---

# Improve Skills

You are performing a meta-improvement pass on the Claude skills and agents in this setup. Your goal is to make skills sharper, more accurate, and more efficient based on what you observed in this session.

## Phase 1: Inventory

List all skills and agents:

```bash
ls ~/.claude/skills/
ls ~/.claude/agents/
```

For each, note:
* Name and description
* Whether it was used in this session
* Whether it produced good results or showed friction

## Phase 2: Session Reflection

**If there is a prior session to reflect on**, review what happened:
* Which skills were invoked (by trigger or name)?
* Where did skills produce unexpected, incorrect, or verbose output?
* Were there tasks that should have triggered a skill but didn't?
* Were there tasks that were done manually that a skill should handle?

**If invoked on a fresh/empty session (cold audit)**: skip reflection. Proceed directly to Phase 3 and audit the most frequently used skills based on MEMORY.md and CLAUDE.md context. In Phase 4, you MAY improve skills based on quality criteria alone — not just observed friction. Remove the "didn't observe" restriction for cold audits.

## Phase 3: Audit Criteria

For each skill that warrants review, evaluate:

**Token efficiency:**
* Is the skill prompt longer than necessary?
* Are there redundant instructions or examples that could be trimmed?
* Does the skill front-load the most important instruction?

**Accuracy:**
* Does the description accurately reflect what the skill does?
* Are the trigger keywords correct and distinct from other skills?
* Are tool names, paths, or commands still correct?

**Robustness:**
* Does the skill handle edge cases (empty results, missing files, ambiguous input)?
* Does it specify what to do when it fails or when context is missing?
* Is it clear about what it will NOT do?

**Self-documentation:**
* Can a new agent read the skill and execute it correctly with no prior context?
* Are there assumptions baked in that should be made explicit?

## Phase 4: Make Improvements

For skills that have clear, specific improvements:

1. Read the current SKILL.md with the `Read` tool.
2. Make targeted edits with the `Edit` tool.
3. Do not rewrite skills wholesale unless they are fundamentally broken.
4. Prefer removing over adding — shorter, tighter prompts usually perform better.

**Do not change:**
* The skill's core intent or behavior unless it was demonstrably wrong.
* Skills you didn't observe being used (unless there's an obvious bug).
* Formatting conventions that appear intentional.

## Phase 5: Report

After making changes, produce a concise report:

```
## Skills Improvement Report

### Modified
- `<skill-name>`: [what changed and why]
- `<skill-name>`: [what changed and why]

### Reviewed but unchanged
- `<skill-name>`: [why no change was needed]

### Flagged for future review
- `<skill-name>`: [what to investigate next time]

### New skills suggested
- `<skill-name>`: [what it would do and why it's needed]
```

## Scope

* Only modify files under `~/.claude/skills/` and `~/.claude/agents/`.
* Do not modify `CLAUDE.md` or `settings.json` unless the user explicitly asks.
* Do not create new skills unless you have a clear, specific use case from this session.
