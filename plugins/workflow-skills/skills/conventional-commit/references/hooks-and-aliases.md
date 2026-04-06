# Git Hooks & Aliases

## Git Hook Installation

```bash
#!/bin/bash
# .gitmessage template
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>

# Install commit-msg hook
cat << 'EOF' > .git/hooks/commit-msg
#!/bin/bash
commit_regex='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9\-]+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: <type>(<scope>): <subject>"
    echo "Types: feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"
    exit 1
fi
EOF

chmod +x .git/hooks/commit-msg
```

## Automated Generation Script

```bash
# Analyze changes and suggest commit
git diff --cached --name-only | while read file; do
  # Detect type based on file
  case "$file" in
    *.test.* | *spec.* | test/* | tests/*)
      type="test"
      ;;
    *.md | docs/* | README*)
      type="docs"
      ;;
    .github/* | .gitlab-ci.yml | Jenkinsfile)
      type="ci"
      ;;
    package*.json | requirements.txt | go.mod | Cargo.toml)
      type="build"
      ;;
    *)
      type="feat"
      ;;
  esac
done

# Generate scope from directory
scope=$(git diff --cached --name-only | head -1 | cut -d'/' -f1)

# Create subject from changes
subject=$(git diff --cached --stat | tail -1)
```

## Git Aliases

```bash
# ~/.gitconfig
[alias]
  # Conventional commit shortcuts
  cf = "!f() { git commit -m \"feat($1): $2\"; }; f"
  cfix = "!f() { git commit -m \"fix($1): $2\"; }; f"
  cdocs = "!f() { git commit -m \"docs($1): $2\"; }; f"
  cstyle = "!f() { git commit -m \"style($1): $2\"; }; f"
  crefactor = "!f() { git commit -m \"refactor($1): $2\"; }; f"
  ctest = "!f() { git commit -m \"test($1): $2\"; }; f"
  cchore = "!f() { git commit -m \"chore($1): $2\"; }; f"

  # Commit with automatic type detection
  cc = "!f() { /conventional-commit generate; }; f"
```
