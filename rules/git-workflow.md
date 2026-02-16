# Git Workflow

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Note: Attribution disabled globally via ~/.claude/settings.json.

## GitHub CLI (gh) Integration

**Use GH CLI for GitHub operations** instead of web UI or git commands where applicable:

### Viewing GitHub Resources
- `gh pr view [number]` - View PR details, checks, and comments
- `gh pr list` - List open PRs
- `gh pr status` - Show PRs relevant to current user
- `gh issue view [number]` - View issue details
- `gh issue list` - List open issues
- `gh repo view` - View repository info

### Pull Request Operations
- `gh pr create` - Create PR from current branch (use HEREDOC for body)
- `gh pr checkout [number]` - Check out a PR locally
- `gh pr review [number]` - Add review comments
- `gh pr merge [number]` - Merge a PR
- `gh pr diff [number]` - View PR diff

### Issue Management
- `gh issue create` - Create new issue
- `gh issue close [number]` - Close an issue
- `gh issue comment [number]` - Add comment to issue

### API Access
- `gh api repos/{owner}/{repo}/pulls/{pr}/comments` - Access GitHub API directly
- Use for advanced operations not covered by standard commands

### Best Practices
- Always use HEREDOC format for multi-line PR/issue bodies
- Prefer `gh` over navigating to GitHub web UI
- Use `gh pr view` to check PR status before manual checks
- Use `gh api` for operations not available in standard commands

## Pull Request Workflow

When creating PRs:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft concise PR summary with:
   - Short title (under 70 characters)
   - Brief description (1-3 bullet points)
4. Create PR using `gh pr create` with HEREDOC body format:
   ```bash
   gh pr create --title "feat: add user authentication" --body "$(cat <<'EOF'
   - Implement JWT-based authentication
   - Add login/logout endpoints
   - Add auth middleware
   EOF
   )"
   ```
5. Push with `-u` flag if new branch
6. Use `gh pr view` to verify PR creation and check status

## Feature Implementation Workflow

1. **Plan First**
   - Use **planner** agent to create implementation plan
   - Identify dependencies and risks
   - Break down into phases

2. **TDD Approach**
   - Use **tdd-guide** agent
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review**
   - Use **code-reviewer** agent immediately after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

4. **Commit & Push**
   - Don't use extended commit messages when possible
   - Don't ever include Claude or any other agent's name in commit messages
   - Follow conventional commits format
