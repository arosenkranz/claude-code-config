---
name: conventional-commit
description: Generate and validate conventional commit messages following the Conventional Commits specification. Analyzes staged changes to determine type, scope, and subject. Use when creating git commits or validating commit message format.
disable-model-invocation: true
---

# Conventional Commit Generator

Generate and validate conventional commit messages following the Conventional Commits specification.

## Usage

```
/conventional-commit [action] [options]
```

## Actions

* `generate` - Create commit message from changes
* `validate` - Check if message follows convention
* `amend` - Fix the last commit message
* `template` - Generate commit template
* `hook` - Install git commit-msg hook

## Commit Types

* `feat` - New feature
* `fix` - Bug fix
* `docs` - Documentation changes
* `style` - Code style changes (formatting, semicolons, etc.)
* `refactor` - Code refactoring without feature changes
* `perf` - Performance improvements
* `test` - Adding or updating tests
* `build` - Build system or dependency changes
* `ci` - CI/CD configuration changes
* `chore` - Maintenance tasks
* `revert` - Reverting previous commits

## Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

## Process

1. **Change Analysis**
   * Detect modified files
   * Identify change type
   * Determine scope
   * Extract key changes

1. **Message Generation**
   * Select appropriate type
   * Define clear scope
   * Write concise subject
   * Add detailed body if needed

1. **Validation**
   * Check format compliance
   * Verify type validity
   * Ensure subject clarity
   * Validate scope relevance

## Scope Guidelines

### By Feature Area
* `api` - REST API changes
* `ui` - User interface changes
* `db` - Database modifications
* `auth` - Authentication/authorization
* `docker` - Container-related changes
* `k8s` - Kubernetes configurations
* `instruqt` - Instruqt lab changes
* `datadog` - Datadog monitoring changes

### By Component
* `header` - Header component
* `footer` - Footer component
* `navbar` - Navigation bar
* `modal` - Modal windows
* `form` - Form components

### By File Type
* `config` - Configuration files
* `deps` - Dependencies
* `scripts` - Script files
* `tests` - Test files

## Examples

See `references/examples.md` for full commit message examples (feature, bugfix, breaking change, etc.).

## Git Hooks & Aliases

See `references/hooks-and-aliases.md` for the commit-msg hook script, gitconfig aliases, and automated generation script.

## Options

* `--type` - Specify commit type
* `--scope` - Define commit scope
* `--breaking` - Mark as breaking change
* `--issues` - Reference issue numbers
* `--no-verify` - Skip validation
* `--amend` - Amend previous commit

## Quick Examples

```
/conventional-commit generate --type feat --scope api
/conventional-commit validate "feat(ui): add dark mode toggle"
/conventional-commit amend --fix-format
/conventional-commit hook --install
/conventional-commit template --breaking
```
