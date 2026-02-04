# Project Initializer

Smart project initialization with modern tooling and best practices for your development workflow.

## Usage
Quickly scaffold new projects with your preferred stack and configurations.

## Details
This command will:
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
- **Astro**: Blog, portfolio, documentation site
- **Vite + React**: SPA, interactive applications  
- **Express API**: REST API, microservices
- **Python CLI**: Automation tools, scripts
- **Python Web**: FastAPI/Flask applications
- **Monorepo**: Multiple related projects
- **Library**: NPM package or Python module

## Auto-Configuration
- Detects existing tools in ~/Code
- Uses your ESLint/Prettier preferences
- Integrates with your GitHub account
- Adds Datadog monitoring boilerplate

## Learning Mode
- Explains each configuration choice
- Shows alternative options
- Provides next steps documentation

## Example
`/project-init` - Interactive project setup
`/project-init astro-blog` - Astro blog project
`/project-init python-cli` - Python CLI tool