---
name: search-first
description: Research-before-coding workflow. Search for existing tools, libraries, and patterns before writing custom code. Reduces wrong-approach friction.
---

# /search-first — Research Before You Code

Systematizes the "search for existing solutions before implementing" workflow. Directly addresses the #1 friction pattern: picking the wrong tool/approach on the first attempt.

## Trigger

Use this skill when:
- Starting a new feature that likely has existing solutions
- Adding a dependency or integration
- The user asks "add X functionality" and you're about to write code
- Before creating a new utility, helper, or abstraction

## Workflow

```
1. NEED ANALYSIS
   Define what functionality is needed
   Identify language/framework constraints
   Check deployment target (Cloudflare Workers? Homelab Docker?)

2. PARALLEL SEARCH
   - Does this already exist in the repo? → rg through modules/tests
   - npm / PyPI for packages
   - MCP servers available (check settings.json)
   - Existing skills in ~/.claude/skills/
   - GitHub code search for maintained OSS

3. EVALUATE
   Score candidates: functionality, maintenance, community,
   docs, license, dependency footprint

4. DECIDE
   - Exact match, well-maintained → ADOPT as-is
   - Partial match, good foundation → EXTEND with thin wrapper
   - Multiple weak matches → COMPOSE 2-3 small packages
   - Nothing suitable → BUILD custom, informed by research

5. IMPLEMENT
   Install package / Configure MCP / Write minimal custom code
```

## Platform Constraints Check

Before recommending any package, verify compatibility:

| Target | Constraints |
|--------|------------|
| Cloudflare Workers | No Node.js APIs, ESM only, Web Platform APIs only |
| Raspberry Pi 5 / Docker | ARM64 compatible, low memory footprint |
| Browser / Client | Bundle size matters, tree-shakeable preferred |

## Quick Mode (inline)

Before writing a utility, run through:

0. Does this already exist in the repo?
1. Is this a common problem? → Search npm/PyPI
2. Is there an MCP server for it? → Check `~/.claude/settings.json`
3. Is there a skill for it? → Check `~/.claude/skills/`
4. Is there a maintained GitHub implementation?

## Full Mode (agent)

For non-trivial functionality, launch a research agent:

```
Agent(subagent_type="Explore", prompt="
  Research existing tools for: [DESCRIPTION]
  Language/framework: [LANG]
  Deploy target: [Cloudflare Workers / Docker / Local]
  Return: Top 3 candidates with pros/cons
")
```

## Anti-Patterns

- **Jumping to code**: Writing a utility without checking if one exists
- **Ignoring MCP**: Not checking if an MCP server already provides the capability
- **Over-customizing**: Wrapping a library so heavily it loses its benefits
- **Dependency bloat**: Installing a massive package for one small feature
- **Wrong platform**: Installing a Node.js-only package for a Cloudflare Workers project
