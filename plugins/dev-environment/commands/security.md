# Security Guidelines

## Secrets

Never hardcode secrets (API keys, passwords, tokens). Read them from environment variables and fail fast with a clear error when one is missing. Before any commit, scan the diff for accidentally included secrets.

## Security Response Protocol

If a security issue is found:
1. STOP immediately
2. Use the **boris** agent to assess scope and severity
3. Fix CRITICAL issues before continuing other work
4. Rotate any exposed secrets
5. Review the codebase for similar issues
