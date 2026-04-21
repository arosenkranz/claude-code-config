---
name: astro-performance-audit
description: Audit Astro applications for performance issues including bundle size, hydration patterns, image optimization, build-time performance, accessibility, and Core Web Vitals. Use when optimizing performance, debugging slow pages, or preparing for production deployment.
allowed-tools: Read, Grep, Glob, Bash
---

# Astro Performance Audit

Comprehensive performance analysis for Astro applications covering JavaScript bundles, hydration strategies, images, CSS, build-time performance, accessibility, and Core Web Vitals.

## Audit Checklist

### 1. JavaScript Bundle Analysis

**Detect over-hydration:**

```bash
# Find all client directives in .astro files
grep -r "client:" src/ --include="*.astro"

# Count by directive type
grep -r "client:load" src/ --include="*.astro" | wc -l
grep -r "client:idle" src/ --include="*.astro" | wc -l
grep -r "client:visible" src/ --include="*.astro" | wc -l
```

**Check for:**

- ❌ `client:load` on non-critical components (header, footer, static content)
- ❌ Large framework components hydrated unnecessarily
- ❌ Multiple instances of same framework component (bundle duplication)
- ✅ Most components are static (no client directive)
- ✅ `client:visible` used for below-the-fold content
- ✅ `client:idle` for non-critical interactive elements

**Bundle size targets:**

- Total JS (first load): < 100KB (compressed)
- Per-page JS: < 50KB (compressed)
- Framework overhead: Minimize or use Preact (4KB vs React 45KB)

### 2. Image Optimization

**Find unoptimized images:**

```bash
# Find <img> tags (not using astro:assets)
grep -r "<img" src/ --include="*.astro" | grep -v "astro:assets"

# Find images without width/height (CLS risk)
grep -r "<img" src/ --include="*.astro" | grep -v "width=" | grep -v "height="

# Find images without alt text (accessibility)
grep -r "<img" src/ --include="*.astro" | grep -v "alt="
```

**Check for:**

- ❌ Using `<img>` instead of `<Image>` from `astro:assets`
- ❌ Missing `width` and `height` attributes (causes CLS)
- ❌ Missing `alt` text (accessibility violation)
- ❌ Not using `loading="lazy"` for below-the-fold images
- ❌ Large images (> 500KB) without optimization
- ✅ Using `<Image>` component with `format="webp"`
- ✅ Explicit dimensions to prevent layout shift
- ✅ Descriptive alt text for all images

**Remote image handling:**

```astro
---
import { Image } from 'astro:assets';

// ✅ Use inferSize for remote images
<Image
  src="https://example.com/image.jpg"
  alt="Description"
  inferSize
  loading="lazy"
/>
---
```

**Image performance targets:**

- LCP image: < 2.5s
- Cumulative Layout Shift: < 0.1
- Format: WebP or AVIF
- Compression: 80-90% quality

### 3. CSS Analysis

**Detect CSS issues:**

```bash
# Find scoped styles (check for duplication)
grep -r "<style>" src/ --include="*.astro" -A 5

# Find @apply usage (can bloat CSS)
grep -r "@apply" src/ --include="*.astro" --include="*.css"

# Check for unused Tailwind classes (run in project root)
npx tailwindcss --minify --output dist/check.css
```

**Check for:**

- ❌ Over-use of `@apply` (defeats utility-first benefits)
- ❌ Duplicate scoped styles across components
- ❌ Unused CSS in final bundle
- ❌ Missing Tailwind purge configuration
- ✅ Scoped styles only for unique component styles
- ✅ Tailwind utilities used directly in markup
- ✅ Proper `content` paths in `tailwind.config.mjs`

**CSS optimization:**

```javascript
// tailwind.config.mjs
export default {
  content: [
    './src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}',
  ],
  // ✅ JIT mode enabled by default in Tailwind 3+
};
```

**CSS performance targets:**

- Total CSS (first load): < 50KB (compressed)
- Per-page CSS: < 20KB (compressed)
- Unused CSS: < 10%

### 4. Hydration Strategy Review

**Audit client directives:**

```bash
# Get directive usage stats
echo "client:load: $(grep -r 'client:load' src/ --include='*.astro' | wc -l)"
echo "client:idle: $(grep -r 'client:idle' src/ --include='*.astro' | wc -l)"
echo "client:visible: $(grep -r 'client:visible' src/ --include='*.astro' | wc -l)"
echo "client:media: $(grep -r 'client:media' src/ --include='*.astro' | wc -l)"
echo "client:only: $(grep -r 'client:only' src/ --include='*.astro' | wc -l)"
```

**Review patterns:**

- ❌ More than 3 `client:load` components per page
- ❌ `client:load` on components > 50KB
- ❌ `client:load` on components below the fold
- ✅ Majority of page is static
- ✅ Interactive widgets use `client:visible` or `client:idle`
- ✅ Critical interactivity (< 20KB) uses `client:load`

### 5. Build-Time Performance

**Check for build-time issues:**

```bash
# Monitor build time
time npm run build

# Check static path generation
grep -r "getStaticPaths" src/pages --include="*.astro"

# Count generated pages
ls -1 dist/**/*.html | wc -l
```

**Build performance checks:**

- ❌ Build time > 5 minutes (pagination needed)
- ❌ Collections with > 1000 items without pagination
- ❌ `getStaticPaths` returning > 1000 routes
- ❌ Large data props (> 100KB per page)
- ❌ Fetching external data in `getStaticPaths` without caching
- ✅ Build time < 2 minutes
- ✅ Pagination for large collections (20-50 items per page)
- ✅ Static data cached during build
- ✅ Reasonable page count (< 500 pages)

**Pagination strategy:**

```astro
---
// ✅ Paginate large collections
export async function getStaticPaths({ paginate }) {
  const posts = await getCollection('blog');

  // Warn for large collections
  if (posts.length > 1000) {
    console.warn(`⚠️ Large collection: ${posts.length} posts. Pagination recommended.`);
  }

  return paginate(posts, {
    pageSize: 20, // 20-50 items per page
  });
}
---
```

**Build-time targets:**

- Build time: < 5 minutes
- Pages per collection: < 1000 (or paginate)
- Data size per page: < 100KB
- External API calls: Cached or batched

### 6. Core Web Vitals

**Performance targets:**

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | 2.5s - 4.0s | > 4.0s |
| **FID** (First Input Delay) | ≤ 100ms | 100ms - 300ms | > 300ms |
| **CLS** (Cumulative Layout Shift) | ≤ 0.1 | 0.1 - 0.25 | > 0.25 |
| **TTFB** (Time to First Byte) | ≤ 800ms | 800ms - 1800ms | > 1800ms |
| **FCP** (First Contentful Paint) | ≤ 1.8s | 1.8s - 3.0s | > 3.0s |

**LCP optimization:**

```astro
---
import { Image } from 'astro:assets';
import heroImage from '../assets/hero.jpg';
---

<!-- ✅ Optimize LCP image -->
<Image
  src={heroImage}
  alt="Hero"
  width={1200}
  height={600}
  format="webp"
  loading="eager" // Don't lazy load LCP image
  fetchpriority="high"
  class="w-full"
/>
```

**FID/INP optimization:**

- ✅ Defer non-critical JavaScript (`client:idle`, `client:visible`)
- ✅ Use `is:inline` sparingly (increases bundle size)
- ✅ Minimize main thread work (< 50ms tasks)
- ❌ Avoid large synchronous scripts

**CLS optimization:**

- ✅ Always set `width` and `height` on images
- ✅ Reserve space for ads/embeds with `min-height`
- ✅ Use `font-display: swap` for web fonts
- ❌ Avoid injecting content above existing content

### 7. Network Optimization

**Resource loading:**

```astro
---
// ✅ Preload critical assets
<link rel="preload" href="/fonts/inter.woff2" as="font" type="font/woff2" crossorigin />

// ✅ Preconnect to external domains
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="dns-prefetch" href="https://api.example.com" />

// ✅ Prefetch next page
<link rel="prefetch" href="/blog/next-article" />
---
```

**Check for:**

- ❌ Too many third-party scripts (< 3 recommended)
- ❌ Render-blocking resources (CSS, fonts)
- ❌ Large font files (> 100KB per font)
- ✅ Critical CSS inlined
- ✅ Fonts self-hosted (faster than Google Fonts)
- ✅ Resource hints for external domains

### 8. Route Prefetching

**Enable View Transitions:**

```astro
---
// src/layouts/BaseLayout.astro
import { ViewTransitions } from 'astro:transitions';
---

<head>
  <ViewTransitions />
</head>
```

**Prefetching configuration:**

```javascript
// astro.config.mjs
export default defineConfig({
  prefetch: {
    defaultStrategy: 'viewport', // Prefetch links in viewport
    prefetchAll: false, // Only prefetch visible links
  },
});
```

**Benefits:**

- ✅ Instant navigation between pages
- ✅ Reduced perceived load time
- ⚠️ Monitor network usage (can prefetch too much)

### 9. Accessibility Audit

**Automated checks:**

```bash
# Find images without alt text
grep -r "<img" src/ --include="*.astro" | grep -v 'alt='

# Find inputs without labels
grep -r '<input' src/ --include="*.astro" | grep -v 'aria-label' | grep -v 'aria-labelledby'

# Check heading hierarchy
grep -r '<h[1-6]' src/ --include="*.astro"

# Find buttons without accessible names
grep -r '<button' src/ --include="*.astro" | grep -v 'aria-label' | grep -v '>'
```

**Accessibility checks:**

- ❌ Images without alt text
- ❌ Form inputs without labels or aria-label
- ❌ Buttons without text or aria-label (icon-only buttons)
- ❌ Skipped heading levels (h1 → h3)
- ❌ Low color contrast (< 4.5:1 for text)
- ❌ Missing skip link for keyboard navigation
- ❌ Interactive elements not keyboard accessible
- ✅ All images have descriptive alt text
- ✅ All forms have proper labels
- ✅ Logical heading hierarchy (h1 → h2 → h3)
- ✅ Focus indicators visible (`:focus-visible`)
- ✅ Skip link at top of page
- ✅ ARIA attributes used correctly

**Accessibility targets:**

- WCAG Level: AA (minimum)
- Color contrast: 4.5:1 (normal text), 3:1 (large text)
- Keyboard navigation: All interactive elements accessible
- Screen reader: Proper semantic HTML and ARIA

**Lighthouse accessibility score:**

- Good: ≥ 90
- Needs improvement: 50-89
- Poor: < 50

## Performance Testing Tools

### Lighthouse Audit

```bash
# Install Lighthouse CLI
npm install -g @lhci/cli

# Run audit (including accessibility)
lhci autorun --collect.url=http://localhost:4321 --collect.numberOfRuns=3

# Or use Chrome DevTools:
# 1. Open DevTools (F12)
# 2. Go to Lighthouse tab
# 3. Select Performance + Accessibility + Best Practices
# 4. Click "Analyze page load"
```

**Lighthouse targets:**

- Performance: ≥ 90
- Accessibility: ≥ 90
- Best Practices: ≥ 90
- SEO: ≥ 90

### Bundle Analysis

```bash
# Install visualizer
npm install --save-dev rollup-plugin-visualizer

# Add to astro.config.mjs
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  vite: {
    plugins: [
      visualizer({
        open: true,
        filename: 'dist/stats.html',
        gzipSize: true,
        brotliSize: true,
      }),
    ],
  },
});

# Build and view bundle
npm run build
# Opens stats.html in browser
```

**Analyze:**

- Large dependencies (> 50KB)
- Duplicate code
- Framework overhead
- Unused exports

### WebPageTest

```bash
# Run WebPageTest via CLI
npx webpagetest test https://example.com \
  --key YOUR_API_KEY \
  --location Dulles:Chrome \
  --runs 3 \
  --first-view-only
```

**Metrics to track:**

- Speed Index: < 3.0s
- Time to Interactive: < 5.0s
- Total Blocking Time: < 300ms

### Build Time Profiling

```bash
# Profile Astro build
DEBUG=vite:* npm run build 2>&1 | grep "transform"

# Measure build time
time npm run build

# Check output size
du -sh dist/
```

**Build time analysis:**

- Identify slow transforms
- Check for excessive file processing
- Monitor collection query times

## Common Performance Issues

### Issue 1: Over-Hydration

**Problem:** Too much JavaScript shipped to client

**Detection:**

```bash
# Count client directives
grep -r "client:" src/ --include="*.astro" | wc -l

# Find client:load usage
grep -r "client:load" src/ --include="*.astro"
```

**Solutions:**

- Replace `client:load` with `client:idle` or `client:visible`
- Move interactive components below the fold
- Use static Astro components instead of framework components
- Consider Astro-native alternatives to heavy React components

**Impact:** 40-80KB JS reduction per component

### Issue 2: Unoptimized Images

**Problem:** Large images causing slow LCP and high CLS

**Detection:**

```bash
# Find <img> tags not using Image component
grep -r "<img" src/ --include="*.astro" | grep -v "Image"

# Find images without dimensions
grep -r "<img" src/ --include="*.astro" | grep -v "width="
```

**Solutions:**

- Use `<Image>` from `astro:assets`
- Set explicit `width` and `height`
- Use `format="webp"` or `format="avif"`
- Add `loading="lazy"` for below-the-fold images
- Use `fetchpriority="high"` for LCP image

**Impact:** 50-80% file size reduction, 1-2s LCP improvement

### Issue 3: CSS Bloat

**Problem:** Large CSS bundle from unused Tailwind utilities

**Detection:**

```bash
# Check CSS bundle size
ls -lh dist/_astro/*.css

# Find @apply usage
grep -r "@apply" src/ --include="*.astro" --include="*.css"
```

**Solutions:**

- Verify `content` paths in `tailwind.config.mjs`
- Replace `@apply` with direct utilities
- Remove unused Tailwind plugins
- Use scoped styles sparingly

**Impact:** 20-40KB CSS reduction

### Issue 4: Render-Blocking Resources

**Problem:** Fonts and CSS blocking initial render

**Detection:**

- Check Lighthouse "Eliminate render-blocking resources"
- Network waterfall shows CSS/fonts blocking FCP

**Solutions:**

```astro
<!-- ✅ Preload critical fonts -->
<link
  rel="preload"
  href="/fonts/inter.woff2"
  as="font"
  type="font/woff2"
  crossorigin
/>

<!-- ✅ Use font-display: swap -->
<style>
  @font-face {
    font-family: 'Inter';
    src: url('/fonts/inter.woff2') format('woff2');
    font-display: swap; /* Show fallback while loading */
  }
</style>
```

**Impact:** 0.5-1.5s FCP improvement

### Issue 5: Build Explosion

**Problem:** Too many pages generated, long build times

**Detection:**

```bash
# Count HTML files
ls -1 dist/**/*.html | wc -l

# Measure build time
time npm run build
```

**Solutions:**

- Implement pagination for large collections
- Limit `getStaticPaths` output (< 1000 pages)
- Use hybrid rendering for dynamic routes
- Cache external data fetches

**Impact:** 50-80% build time reduction

### Issue 6: Accessibility Violations

**Problem:** Missing alt text, poor semantics, low contrast

**Detection:**

```bash
# Find accessibility issues
grep -r "<img" src/ | grep -v 'alt='
grep -r '<input' src/ | grep -v 'label'
```

**Solutions:**

- Add descriptive alt text to all images
- Use semantic HTML (nav, main, article)
- Ensure 4.5:1 color contrast
- Add skip links for keyboard users
- Test with screen reader

**Impact:** Improved usability for 15%+ of users

## Optimization Recommendations

### Quick Wins (< 1 hour)

1. **Replace `client:load` with `client:idle`** on non-critical components
2. **Add `loading="lazy"`** to below-the-fold images
3. **Set image dimensions** (width/height) to prevent CLS
4. **Add alt text** to images for accessibility
5. **Enable View Transitions** for faster navigation
6. **Preload LCP image** with `fetchpriority="high"`

### Medium Effort (1-4 hours)

1. **Convert `<img>` to `<Image>`** for optimization
2. **Implement pagination** for large collections
3. **Refactor Tailwind `@apply`** to direct utilities
4. **Add skip link** for keyboard accessibility
5. **Optimize fonts** (self-host, subset, preload)
6. **Lazy load framework components** with `client:visible`

### Long-term (> 4 hours)

1. **Replace React with Preact** (45KB → 4KB)
2. **Extract Shadcn styles** to Astro components (remove React)
3. **Implement advanced caching** for API routes
4. **Server-side rendering** for dynamic content
5. **Image CDN integration** for remote images
6. **Progressive Web App** (service worker, offline support)

## Performance Budget

Example configuration:

```javascript
// performance-budget.json
{
  "budgets": [
    {
      "resourceType": "script",
      "budget": 100 // KB
    },
    {
      "resourceType": "stylesheet",
      "budget": 50 // KB
    },
    {
      "resourceType": "image",
      "budget": 300 // KB per page
    },
    {
      "resourceType": "total",
      "budget": 500 // KB total
    }
  ],
  "build": {
    "maxBuildTime": 300, // 5 minutes
    "maxPages": 1000
  }
}
```

**Monitor in CI:**

```yaml
# .github/workflows/performance.yml
- name: Performance Budget
  run: |
    npx bundlesize
    npm run build
    BUILD_TIME=$(expr $(date +%s) - $START_TIME)
    if [ $BUILD_TIME -gt 300 ]; then
      echo "Build time exceeded 5 minutes"
      exit 1
    fi
```

## Monitoring Setup

**Web Vitals reporting:**

```astro
---
// src/layouts/BaseLayout.astro
---

<script>
  import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

  function sendToAnalytics(metric) {
    // Send to analytics service
    fetch('/api/analytics', {
      method: 'POST',
      body: JSON.stringify(metric),
      headers: { 'Content-Type': 'application/json' },
    });
  }

  getCLS(sendToAnalytics);
  getFID(sendToAnalytics);
  getFCP(sendToAnalytics);
  getLCP(sendToAnalytics);
  getTTFB(sendToAnalytics);
</script>
```

**Build time tracking:**

```javascript
// Track build metrics over time
const buildMetrics = {
  timestamp: new Date().toISOString(),
  buildTime: process.env.BUILD_TIME,
  pageCount: /* count HTML files */,
  bundleSize: /* measure dist/ size */,
};
```

## Pre-Deployment Checklist

Before deploying to production:

- [ ] **Lighthouse score** ≥ 90 (performance)
- [ ] **Lighthouse accessibility** ≥ 90
- [ ] **LCP** < 2.5s
- [ ] **CLS** < 0.1
- [ ] **FID/INP** < 100ms
- [ ] **Bundle size** < 100KB (JS), < 50KB (CSS)
- [ ] **Build time** < 5 minutes
- [ ] **All images optimized** (WebP, lazy loading, dimensions)
- [ ] **Alt text** on all images
- [ ] **Semantic HTML** (nav, main, article)
- [ ] **Color contrast** ≥ 4.5:1
- [ ] **Keyboard navigation** works
- [ ] **No console errors** in production

## Usage

Ask Claude to audit your Astro app:

- "Audit performance for my Astro site"
- "Check bundle size and hydration patterns"
- "Find accessibility issues in components"
- "Analyze Core Web Vitals"
- "Check build-time performance"
- "Review image optimization"

Claude will analyze your project and provide actionable recommendations.
