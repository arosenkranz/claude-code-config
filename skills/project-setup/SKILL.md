---
name: project-setup
description: Interactive project scaffolding with modern tooling for Astro, Vite+React, Express API, Python CLI/Web, Monorepo, and Library projects.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Project Setup

Smart project initialization with modern tooling and best practices for your development workflow.

## Usage

```
/project-setup              # Interactive project setup
/project-setup astro-blog   # Astro blog project
/project-setup python-cli   # Python CLI tool
/project-setup react-app    # Vite + React SPA
```

## Interactive Questionnaire

First, gather these details:

1. **Project name**: What would you like to call this project?
2. **Project type**: What kind of project is this?
   - Static site (Astro, Vite)
   - React app (Vite, Next.js)
   - Full-stack app (Express + React, etc.)
   - CLI tool (Node.js or Python)
   - Python web (FastAPI, Flask)
   - Monorepo (multiple packages)
   - Library (NPM package or Python module)
3. **Features needed**:
   - TypeScript?
   - Testing framework?
   - Linting/Formatting (ESLint + Prettier)?
   - Git repository?
   - Docker setup?
   - CI/CD (GitHub Actions)?
4. **Any specific libraries or tools** you know you'll need?

## What It Does

1. Detect project type from context or ask for clarification
2. Initialize git repository with .gitignore
3. Set up package manager (npm/pnpm/yarn for JS, poetry/pip for Python)
4. Configure ESLint and Prettier for JS/TS projects
5. Set up TypeScript with proper configs
6. Create basic project structure
7. Add VS Code settings
8. Configure pre-commit hooks with husky
9. Set up basic CI/CD with GitHub Actions
10. Add README with project information

## Project Types

### Astro
Blog, portfolio, documentation site. Includes content collections, API routes, and markdown support.

### Vite + React
SPA and interactive applications. Includes React Router, state management setup, and component structure.

### Express API
REST API and microservices. Includes routing, middleware, error handling, and validation with Zod.

### Python CLI
Automation tools and scripts. Uses Click/Typer for CLI, Rich for output, and pytest for testing.

### Python Web
FastAPI or Flask applications. Includes async support, Pydantic models, and structured project layout.

### Monorepo
Multiple related projects. Uses pnpm workspaces or Turborepo for package management.

### Library
NPM package or Python module. Includes build configuration, type declarations, and publishing setup.

## Auto-Configuration

- Detects existing tools in ~/Code
- Uses your ESLint/Prettier preferences
- Integrates with your GitHub account
- Adds Datadog monitoring boilerplate

## Learning Mode

All projects are created in `~/Code` with explanations for each configuration choice, alternative options, and next steps documentation to help you learn.
