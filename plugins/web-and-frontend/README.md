# web-and-frontend

Frontend development, browser automation, UI testing, Astro components, and creative canvas work.

## Skills

| Skill | Purpose |
|---|---|
| `frontend-developer` | React, Astro, and general frontend patterns |
| `web-artifacts-builder` | Generate self-contained HTML/JS artifacts |
| `agent-browser` | Automated browser control via Playwright |
| `webapp-testing` | UI and integration testing strategies |
| `verify-ui` | Visual verification of UI changes |
| `astro-component-scaffold` | Scaffold Astro components with TypeScript props |
| `astro-content-collections` | Set up and manage Astro content collections |
| `astro-performance-audit` | Audit Astro site performance (Core Web Vitals) |
| `theme-factory` | Generate design tokens and Tailwind themes |
| `canvas-design` | Creative canvas work with P5.js and Three.js |
| `algorithmic-art` | Generative art patterns |
| `rams` | Dieter Rams-inspired minimalist UI design principles |

## Requirements

| Tool | Skills that use it | Install |
|---|---|---|
| Node.js 18+ | All frontend skills | `brew install node` |
| `agent-browser` CLI | `agent-browser`, `verify-ui` | `npm install -g agent-browser` |
| Playwright browsers | `agent-browser` | `npx playwright install` |
| Chrome/Chromium | `agent-browser` | installed by Playwright |

**iOS simulator support** (optional, macOS only):
- Xcode + Simulator app
- Appium + xcuitest driver (`npm install -g appium`)

## Setup

**Install agent-browser and Playwright:**
```bash
npm install -g agent-browser
npx playwright install chromium
```

**Verify:**
```bash
agent-browser --version
```

## Notes

- Astro skills (`astro-*`) assume an existing Astro project; they won't scaffold a project from scratch
- `canvas-design` and `algorithmic-art` generate P5.js or Three.js sketches — Node.js is not required to view them (they run in browser)
- `verify-ui` works best when a dev server is already running; start it before invoking the skill
