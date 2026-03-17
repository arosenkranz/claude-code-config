# Conventional Commit Examples

## Feature Addition

```
feat(api): add user authentication endpoint

- Implement JWT-based authentication
- Add login and logout endpoints
- Include refresh token mechanism
- Add rate limiting for auth endpoints

Closes #123
```

## Bug Fix

```
fix(docker): resolve container networking issue

Fixed issue where containers couldn't communicate on custom bridge network
by properly configuring docker-compose network settings.

Fixes #456
```

## Breaking Change

```
feat(api)!: update authentication to OAuth 2.0

BREAKING CHANGE: JWT authentication removed in favor of OAuth 2.0.
Existing tokens will no longer work. Users must re-authenticate.

Migration guide available in docs/migration/oauth.md
```

## Multiple Changes (Scope)

```
refactor(instruqt): reorganize lab structure

- Move common scripts to shared directory
- Standardize challenge naming convention
- Extract reusable setup functions
- Update all lab references
```
