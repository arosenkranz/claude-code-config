# PR Workflow (/pr)

Encode the full preferred git workflow: branch → commit → push → PR. Invoke with `/pr`.

## When to Use

Use `/pr` whenever implementation is complete and changes need to be submitted for review. This skill replaces manual git choreography.

## Steps (execute in order, no confirmation between steps)

### 1. Check current branch

```bash
git branch --show-current
```

If currently on `main` or `master`:
- Create a feature branch named after the primary change
- Branch name format: `<type>/<short-description>` (e.g., `feat/add-auth-middleware`)
- `git checkout -b <branch-name>`

If already on a feature branch, continue to step 2.

### 2. Stage relevant files

Stage only files related to the change. Exclude:
- `.env`, `.env.*` files
- Files matching `*.secret`, `*credentials*`, `*token*`
- Generated files (e.g., `dist/`, `build/`, `.next/`, `node_modules/`)
- Binary files not intentionally added

```bash
git add <specific files or patterns>
# Review what's staged:
git status
git diff --staged
```

### 3. Commit with conventional format

Determine commit type from the change:
- `feat:` — new feature
- `fix:` — bug fix
- `refactor:` — code restructure, no behavior change
- `docs:` — documentation only
- `test:` — test additions or fixes
- `chore:` — tooling, config, dependency updates
- `perf:` — performance improvement
- `ci:` — CI/CD changes

```bash
git commit -m "$(cat <<'EOF'
<type>: <concise description under 72 chars>
EOF
)"
```

Constraints:
- Never include "Claude", "AI", or agent attribution in commit messages
- Keep the subject line under 72 characters
- No body required for simple changes

### 4. Push with tracking

```bash
git push -u origin <branch-name>
```

### 5. Create PR

```bash
gh pr create --fill
```

`--fill` uses the commit message as the PR title and body. For multi-commit branches or when richer description is needed:

```bash
gh pr create --title "<type>: <description>" --body "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>

## Test plan
- [ ] <verification step>
EOF
)"
```

### 6. Output PR URL

After `gh pr create` succeeds, print the returned PR URL so it's visible in the conversation.

## Constraints (always enforced)

- **Never commit directly to `main` or `master`** — always branch first
- **Never skip `--fill` or HEREDOC** — avoids shell escaping issues with PR bodies
- **Never add `--no-verify`** — hooks must run
- Attribution is already disabled globally in `settings.json`; no extra flags needed
