---
name: favicon
description: Generate complete favicon set from a source image using ImageMagick. Use when the user needs to create favicons for a website or web app.
---

# Favicon Generation

Generate complete favicon sets from source images and update project HTML.

## Prerequisites

Requires ImageMagick v7+. Check with:
```bash
magick -version
```

## Workflow

1. **Validate source file** - Confirm file exists and is a supported format (PNG, JPG, JPEG, SVG, WEBP, GIF)
2. **Detect framework** - Identify project type (Rails, Next.js, Gatsby, SvelteKit, static HTML, etc.)
3. **Locate assets directory** - Find where static files should be placed
4. **Generate favicon files** - Create multiple sizes: 16x16, 32x32, 48x48, 96x96, 180x180, 192x192, 512x512
5. **Create/update web manifest** - Generate `site.webmanifest` with PWA configuration
6. **Update HTML** - Add appropriate favicon link tags to layout files

## Supported Sizes

- **16x16** - Browser tab icon
- **32x32** - Taskbar icon
- **48x48** - Windows site icon
- **96x96** - Google TV icon
- **180x180** - Apple touch icon
- **192x192** - Android home screen
- **512x512** - High-res Android/PWA

## Framework-Specific Integration

### Rails
Updates `app/views/layouts/application.html.erb`

### Next.js
Modifies `metadata` export in layout files

### Static HTML
Updates root `index.html`

### Unknown Projects
Prompts user to confirm target directory

## Important Notes

- SVG sources are included in output only when source file is SVG format
- Existing favicon configurations are preserved while updating core elements
- Path references adjust based on static directory location relative to web root
- App name derives from manifest files, package configuration, or directory naming
