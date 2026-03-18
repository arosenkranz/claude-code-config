# Migration from Command to Skill

## What Changed

### Old Structure (Command)
```
~/.claude/commands/update-actions.md
```

* Simple markdown file with basic instructions
* Limited GitHub API handling (releases only)
* No edge case handling
* Manual invocation only: `/update-actions`

### New Structure (Skill)
```
~/.claude/skills/github-actions-security/
└── SKILL.md
```

* YAML frontmatter for auto-discovery
* Comprehensive GitHub API handling (releases + tags + annotated tags)
* Edge case coverage (local paths, Docker, subdirectories, already-pinned)
* Manual invocation: `/github-actions-security` (or auto-triggered when Claude detects unpinned actions)
* Can be extended with scripts/assets later

## Testing Checklist

### Phase 1: Basic Functionality
- [ ] Invoke skill manually
- [ ] Test with workflow containing simple tagged actions (e.g., `actions/checkout@v4`)
- [ ] Verify 40-character SHA output
- [ ] Verify comment format: `@<SHA> # <TAG>`

### Phase 2: Edge Cases
- [ ] Test with already-pinned action (40-char SHA) - should skip
- [ ] Test with local action (`uses: ./path`) - should skip
- [ ] Test with Docker image (`uses: docker://...`) - should skip
- [ ] Test with subdirectory action (`uses: owner/repo/path@v1`) - should preserve path
- [ ] Test with repo that has no releases (only tags)
- [ ] Test with repo using annotated tags

### Phase 3: Authentication & Rate Limits
- [ ] Test without `GITHUB_TOKEN` - should warn about rate limits
- [ ] Test with `GITHUB_TOKEN` - should use authentication
- [ ] Verify rate limit handling (try multiple repos)

### Phase 4: Security Validation
- [ ] Verify all SHAs are exactly 40 characters
- [ ] Verify SHA format matches `^[a-f0-9]{40}$`
- [ ] Test that proposed changes are shown before applying

## Example Test Workflow

Create a test file at `~/.claude/test-workflow.yml`:

```yaml
name: Test Workflow
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      # Should be updated
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4

      # Should be skipped (already pinned)
      - uses: actions/cache@13aacd865c20de90d75de3b17ebe84f7a17d57d2 # v3.3.2

      # Should be skipped (local)
      - uses: ./.github/actions/custom

      # Should be skipped (Docker)
      - uses: docker://alpine:3.18

      # Should preserve path
      - uses: aws-actions/configure-aws-credentials/v4
```

Then invoke:
```
/github-actions-security ~/.claude/test-workflow.yml
```

Expected behavior:
1. Skip already-pinned `actions/cache`
1. Skip local action
1. Skip Docker image
1. Update `actions/checkout@v4` to latest v4.x.x with SHA
1. Update `actions/setup-node@v4` to latest v4.x.x with SHA
1. Update `aws-actions/configure-aws-credentials/v4` with path preserved
1. Show all changes for review before applying

## When to Remove Old Command

You can safely remove `/Users/alex.rosenkranz/.claude/commands/update-actions.md` after:

1. Testing the new skill with real workflow files
1. Confirming all edge cases work correctly
1. Verifying auto-triggering works as expected
1. You're comfortable with the new invocation pattern

## Rollback Plan

If issues arise with the new skill:

1. The old command is still present at `~/.claude/commands/update-actions.md`
1. Can continue using `/update-actions` while debugging the skill
1. Or temporarily disable the skill by renaming the directory

## Future Enhancements

The skill structure allows for easy extension:

```
github-actions-security/
├── SKILL.md (current)
├── scripts/
│   ├── pin-actions.py (future: full automation)
│   └── verify-shas.py (future: validate existing pins)
├── references/
│   └── security-incidents.md (future: known compromises)
└── assets/ (future: any supporting files)
```

Current recommendation: Keep it simple until usage patterns emerge.
