# git-and-pr

Git workflow automation, PR management, release processes, and worktree-based parallel development.

## Skills

| Skill | Purpose |
|---|---|
| `ship` | Pre-flight checks, commit, push, and open PR in one flow |
| `release` | Cut a release with changelog and version bump |
| `refine` | Polish a branch before opening a PR |
| `address-pr-feedback` | Work through PR review comments systematically |
| `parallel-worktree-session` | Spin up isolated git worktrees for parallel work |
| `cleanup-worktrees` | Remove stale worktrees and their branches |
| `pin-actions` | Pin GitHub Actions to commit SHAs for supply chain safety |

## Requirements

| Tool | Skills that use it | Install |
|---|---|---|
| `gh` CLI | `ship`, `release`, `address-pr-feedback` | `brew install gh` |
| `git` | All skills | pre-installed on macOS |

## Setup

**gh CLI authentication** (required for PR skills):
```bash
gh auth login
```

**Conventional commits** — `ship` and `release` expect commit messages in the format `type: description` (feat, fix, chore, docs, etc.).

**`ship` pre-flight checks** — the skill runs `lint`, `typecheck`, and `test` scripts from `package.json` if present. Make sure those scripts exist or the skill will skip them.

**Semantic versioning** — `release` expects tags in `v1.2.3` format.
