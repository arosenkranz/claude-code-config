---
name: find-skills
description: Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill.
---

# Find Skills

Discover and install specialized agent skills through the Skills CLI ecosystem.

## When to Use

Use this skill when users:
- Request solutions for specific tasks ("how do I do X")
- Explicitly search for specialized tools
- Ask about capability extensions
- Seek domain-specific assistance (design, testing, deployment)

## Core Commands

### Search for Skills
```bash
npx skills find [query]     # Interactive or keyword-based search
```

Browse skills at: https://skills.sh/

### Install Skills
```bash
npx skills add <package>            # Install from repository
npx skills add <owner/repo@skill>   # Install specific skill
npx skills add <owner/repo@skill> -g -y  # Install globally without prompts
```

### Manage Skills
```bash
npx skills check     # Check for updates
npx skills update    # Update installed skills
```

## Search Strategy

Use specific terminology rather than broad terms for better results.

**Common categories:**
- Web development
- Testing frameworks
- Deployment tools
- Documentation utilities
- Code quality improvement
- Design systems
- Productivity automation

**Example searches:**
```bash
npx skills find react performance
npx skills find pdf processing
npx skills find database migration
```

## Workflow

1. **Identify Requirements** - Understand the user's domain and specific task
2. **Execute Search** - Run find command with relevant keywords
3. **Present Findings** - Share discovered skills with descriptions and installation instructions
4. **Facilitate Installation** - Execute add command when user wants to proceed

## No Results?

If searches yield no results:
- Offer direct assistance for the task
- Note that users can create custom skills via `npx skills init`
