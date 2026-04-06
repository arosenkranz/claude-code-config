---
name: release
description: release
---

# Release Workflow (/release)

Extends /pr with semantic versioning, git tags, and optional GitHub release creation. Invoke with `/release`.

## When to Use

Use `/release` when a feature branch is ready to merge AND the resulting main branch state should be tagged as a versioned release. Typically used after `fix:` or `feat:` work is complete.

## Steps (execute in order, no confirmation between steps unless noted)

### Phase 1: PR (run all /pr steps first)

1. Create feature branch if on main/master
2. Stage relevant files (exclude .env, credentials, generated files)
3. Commit with conventional format (`feat:`, `fix:`, etc.)
4. `git push -u origin <branch-name>`
5. `gh pr create --fill`

### Phase 2: Merge (after PR is approved)

Wait for PR approval, or if running in autonomous mode, check status:

```bash
gh pr status
gh pr merge --squash --auto
```

Then pull latest main:

```bash
git checkout main
git pull origin main
```

### Phase 3: Determine version bump

Inspect commits since last tag to determine bump type:

```bash
# Get last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# List commits since last tag
git log ${LAST_TAG}..HEAD --oneline --pretty=format:"%s"
```

Apply bump rules (highest priority wins):

| Commit pattern | Bump type | Example: 1.2.3 → |
|----------------|-----------|-------------------|
| `BREAKING CHANGE:` in body | **major** | 2.0.0 |
| Subject starts with `feat:` | **minor** | 1.3.0 |
| Subject starts with `fix:`, `perf:`, `refactor:` | **patch** | 1.2.4 |
| `docs:`, `chore:`, `test:`, `ci:` only | **patch** | 1.2.4 |

Parse current version from `LAST_TAG`, increment the appropriate component, reset lower components to 0.

### Phase 4: Update package.json (if present)

```bash
if [ -f package.json ]; then
  # Use npm version to bump (also creates a local commit if run in repo)
  npm version <major|minor|patch> --no-git-tag-version
  git add package.json
  git commit -m "chore: bump version to vX.Y.Z"
  git push origin main
fi
```

### Phase 5: Create annotated tag

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

### Phase 6: Create GitHub release (optional, default: yes)

```bash
gh release create vX.Y.Z \
  --generate-notes \
  --title "Release vX.Y.Z"
```

`--generate-notes` auto-populates the release body from commit messages since the last tag.

To skip GitHub release creation, run `/release --no-gh-release`.

## Output

After completion, print a summary:

```
Release vX.Y.Z complete
- Tag: vX.Y.Z (pushed to origin)
- package.json: updated (or "not present")
- GitHub release: <URL> (or "skipped")
```

## Constraints

- Never tag on a dirty working tree — verify `git status` is clean before tagging
- Never force-push tags — if a tag already exists, stop and ask the user
- Never skip the PR phase — releases always go through PR review first
- Tag format is always `vMAJOR.MINOR.PATCH` (semver with `v` prefix)