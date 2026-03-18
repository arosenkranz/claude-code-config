---
name: astro-component-scaffold
description: Scaffold Astro components, layouts, and pages with TypeScript props, Tailwind CSS styling, proper hydration patterns, and best practice defaults. Use when creating new Astro files, building component libraries, or setting up project structure.
allowed-tools: Read, Write, Edit, Bash
---

# Astro Component Scaffolding

Generate production-ready Astro components, layouts, and pages following framework best practices.

## Component Types

### 1. Static Component (Default Pattern)

**Use for**: Non-interactive UI components, presentational elements

```astro
---
// src/components/Card.astro
interface Props {
  title: string;
  description: string;
  imageUrl?: string;
  variant?: 'default' | 'featured' | 'compact';
  class?: string;
}

const {
  title,
  description,
  imageUrl,
  variant = 'default',
  class: className,
} = Astro.props;

import { Image } from 'astro:assets';
import { twMerge } from 'tailwind-merge';

const cardStyles = {
  default: 'bg-white dark:bg-gray-800 rounded-lg shadow-md p-6',
  featured: 'bg-gradient-to-br from-blue-500 to-purple-600 text-white rounded-lg shadow-lg p-8',
  compact: 'bg-white dark:bg-gray-800 rounded-md shadow-sm p-4',
};
---

<article class={twMerge(cardStyles[variant], className)}>
  {imageUrl && (
    <div class="mb-4">
      <Image
        src={imageUrl}
        alt=""
        width={400}
        height={250}
        class="rounded-md w-full object-cover"
        loading="lazy"
      />
    </div>
  )}
  <h3 class="text-2xl font-bold mb-2">{title}</h3>
  <p class="text-gray-600 dark:text-gray-300">{description}</p>

  {Astro.slots.has('default') && (
    <div class="mt-4">
      <slot />
    </div>
  )}
</article>
```

**Key features:**
- ✅ TypeScript interface for props
- ✅ Tailwind CSS with dark mode support
- ✅ Variant system for reusability
- ✅ Optional image with optimization
- ✅ Class merging for extensibility
- ✅ Semantic HTML (`<article>`)
- ✅ Slot support for composition

### 2. Layout Component

**Use for**: Page layouts, wrapping content with common structure

```astro
---
// src/layouts/BaseLayout.astro
interface Props {
  title: string;
  description: string;
  ogImage?: string;
  class?: string;
}

const { title, description, ogImage, class: className } = Astro.props;

const canonicalUrl = new URL(Astro.url.pathname, Astro.site);
const socialImage = ogImage || `${Astro.site}og-default.jpg`;
---

<!doctype html>
<html lang="en" class="scroll-smooth">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{title}</title>
    <meta name="description" content={description} />
    <link rel="canonical" href={canonicalUrl} />

    <!-- Open Graph -->
    <meta property="og:title" content={title} />
    <meta property="og:description" content={description} />
    <meta property="og:image" content={socialImage} />
    <meta property="og:url" content={canonicalUrl} />
    <meta property="og:type" content="website" />

    <!-- Twitter Card -->
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content={title} />
    <meta name="twitter:description" content={description} />
    <meta name="twitter:image" content={socialImage} />

    <slot name="head" />
  </head>
  <body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 min-h-screen flex flex-col">
    <!-- Skip link for accessibility -->
    <a
      href="#main-content"
      class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-blue-500 text-white px-4 py-2 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
    >
      Skip to main content
    </a>

    <slot name="header" />

    <main id="main-content" class={className}>
      <slot />
    </main>

    <slot name="footer" />

    <script is:inline>
      // Dark mode initialization (runs before hydration)
      const theme = localStorage.getItem('theme') ||
        (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
      document.documentElement.classList.toggle('dark', theme === 'dark');
    </script>
  </body>
</html>
```

**Key features:**
- ✅ Complete HTML structure with head/body
- ✅ SEO meta tags (Open Graph, Twitter Card)
- ✅ Accessibility skip link
- ✅ Dark mode support with system preference
- ✅ Named slots for header/footer
- ✅ Flexible main content area
- ✅ Canonical URL handling

### 3. Interactive Component Wrapper

**Use for**: Wrapping React/Vue/Svelte components with proper hydration

```astro
---
// src/components/SearchBar.astro
import SearchBarReact from './SearchBarReact.tsx';

interface Props {
  placeholder?: string;
  onSearch?: string; // Callback function name (client-side)
  variant?: 'default' | 'header' | 'fullwidth';
  class?: string;
}

const {
  placeholder = 'Search...',
  onSearch,
  variant = 'default',
  class: className,
} = Astro.props;

// Determine hydration strategy based on variant
const hydrationDirective = {
  default: 'client:visible',
  header: 'client:load', // Critical for navigation
  fullwidth: 'client:idle',
}[variant];
---

<!-- ✅ Astro wrapper provides styling context -->
<div class={className}>
  {hydrationDirective === 'client:load' && (
    <SearchBarReact
      client:load
      placeholder={placeholder}
      onSearch={onSearch}
      className="w-full"
    />
  )}
  {hydrationDirective === 'client:idle' && (
    <SearchBarReact
      client:idle
      placeholder={placeholder}
      onSearch={onSearch}
      className="w-full"
    />
  )}
  {hydrationDirective === 'client:visible' && (
    <SearchBarReact
      client:visible
      placeholder={placeholder}
      onSearch={onSearch}
      className="w-full"
    />
  )}
</div>
```

**Companion React component:**

```tsx
// src/components/SearchBarReact.tsx
import { useState } from 'react';
import { twMerge } from 'tailwind-merge';

interface SearchBarProps {
  placeholder?: string;
  onSearch?: (query: string) => void;
  className?: string;
}

export default function SearchBar({
  placeholder = 'Search...',
  onSearch,
  className,
}: SearchBarProps) {
  const [query, setQuery] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSearch?.(query);
  };

  return (
    <form onSubmit={handleSubmit} className={twMerge('flex gap-2', className)}>
      <input
        type="search"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder={placeholder}
        className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
        aria-label="Search"
      />
      <button
        type="submit"
        className="px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      >
        Search
      </button>
    </form>
  );
}
```

**Key features:**
- ✅ Variant-based hydration strategy
- ✅ TypeScript props for both .astro and .tsx
- ✅ Tailwind with dark mode
- ✅ Accessibility labels
- ✅ Proper form semantics

### 4. Content Collection Page

**Use for**: Dynamic pages generated from content collections

```astro
---
// src/pages/blog/[...slug].astro
import { type CollectionEntry, getCollection } from 'astro:content';
import BaseLayout from '../../layouts/BaseLayout.astro';
import { Image } from 'astro:assets';

export async function getStaticPaths() {
  const posts = await getCollection('blog', ({ data }) => {
    // Filter out drafts in production
    return import.meta.env.PROD ? data.draft !== true : true;
  });

  // Build-time performance check
  if (posts.length > 1000) {
    console.warn(`⚠️ Large collection: ${posts.length} posts. Consider pagination.`);
  }

  return posts.map((post) => ({
    params: { slug: post.slug },
    props: { post },
  }));
}

interface Props {
  post: CollectionEntry<'blog'>;
}

const { post } = Astro.props;
const { Content } = await post.render();

// Format date
const formattedDate = post.data.pubDate.toLocaleDateString('en-US', {
  year: 'numeric',
  month: 'long',
  day: 'numeric',
});
---

<BaseLayout
  title={post.data.title}
  description={post.data.description}
  ogImage={post.data.coverImage?.src}
>
  <article class="container mx-auto px-4 py-8 max-w-4xl">
    <header class="mb-8">
      {post.data.coverImage && (
        <Image
          src={post.data.coverImage.src}
          alt={post.data.coverImage.alt}
          width={1200}
          height={630}
          class="rounded-lg shadow-lg mb-6 w-full"
        />
      )}

      <h1 class="text-4xl md:text-5xl font-bold mb-4 text-gray-900 dark:text-white">
        {post.data.title}
      </h1>

      <div class="flex items-center gap-4 text-gray-600 dark:text-gray-400">
        <time datetime={post.data.pubDate.toISOString()} class="text-sm">
          {formattedDate}
        </time>
        {post.data.author && (
          <>
            <span aria-hidden="true">•</span>
            <span class="text-sm">By {post.data.author}</span>
          </>
        )}
      </div>

      {post.data.tags && post.data.tags.length > 0 && (
        <div class="flex flex-wrap gap-2 mt-4">
          {post.data.tags.map((tag) => (
            <a
              href={`/blog/tags/${tag}`}
              class="px-3 py-1 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-full text-sm hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
            >
              {tag}
            </a>
          ))}
        </div>
      )}
    </header>

    <div class="prose prose-lg dark:prose-invert max-w-none
      prose-headings:font-bold prose-headings:text-gray-900 dark:prose-headings:text-white
      prose-p:text-gray-700 dark:prose-p:text-gray-300
      prose-a:text-blue-600 dark:prose-a:text-blue-400 prose-a:no-underline hover:prose-a:underline
      prose-code:text-pink-600 dark:prose-code:text-pink-400
      prose-pre:bg-gray-900 prose-pre:text-gray-100">
      <Content />
    </div>
  </article>
</BaseLayout>
```

**Key features:**
- ✅ Type-safe collection entry
- ✅ Draft filtering in production
- ✅ Build-time performance warning
- ✅ Semantic article structure
- ✅ Tailwind Typography (@tailwindcss/typography)
- ✅ Dark mode prose styling
- ✅ Responsive design (md: breakpoints)
- ✅ SEO-friendly time element

## File Structure Templates

### Component Directory Pattern

```
src/
├── components/
│   ├── ui/                    # Reusable UI components
│   │   ├── Button.astro
│   │   ├── Card.astro
│   │   ├── Badge.astro
│   │   └── Alert.astro
│   ├── layout/                # Layout components
│   │   ├── Header.astro
│   │   ├── Footer.astro
│   │   └── Navigation.astro
│   ├── sections/              # Page sections
│   │   ├── Hero.astro
│   │   ├── Features.astro
│   │   └── CTA.astro
│   └── react/                 # Framework components (if needed)
│       ├── SearchBar.tsx
│       └── CommentForm.tsx
├── layouts/
│   ├── BaseLayout.astro       # Base HTML structure
│   ├── BlogLayout.astro       # Blog-specific layout
│   └── DocsLayout.astro       # Documentation layout
└── pages/
    ├── index.astro
    ├── blog/
    │   ├── index.astro        # Blog listing
    │   └── [...slug].astro    # Blog post pages
    └── [...404].astro
```

### Page with Dynamic Route Pattern

```astro
---
// src/pages/products/[category]/[...product].astro
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const products = await getCollection('products');

  // Group by category
  const paths = products.map((product) => ({
    params: {
      category: product.data.category,
      product: product.slug,
    },
    props: { product },
  }));

  // Check for pagination needs
  const categoryCounts = products.reduce((acc, p) => {
    acc[p.data.category] = (acc[p.data.category] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  Object.entries(categoryCounts).forEach(([cat, count]) => {
    if (count > 50) {
      console.warn(`⚠️ Category "${cat}" has ${count} products. Consider pagination.`);
    }
  });

  return paths;
}

const { product } = Astro.props;
---

<!-- Product page template -->
```

### Content Collection Setup

```typescript
// src/content/config.ts
import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string().max(160),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    author: z.string().default('Anonymous'),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
    featured: z.boolean().default(false),
    coverImage: z.object({
      src: z.string(),
      alt: z.string(), // Accessibility: required alt text
    }).optional(),
  }),
});

export const collections = { blog };
```

## TypeScript Patterns

### Shared Props Types

```typescript
// src/types/component-props.ts
import type { HTMLAttributes } from 'astro/types';

/** Base props for all components */
export interface BaseProps {
  class?: string;
  id?: string;
}

/** Props for components with variants */
export interface VariantProps<T extends string> extends BaseProps {
  variant?: T;
}

/** Button variant types */
export type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'destructive';

/** Card variant types */
export type CardVariant = 'default' | 'featured' | 'compact';

/** Props with HTML attributes */
export interface ComponentProps extends BaseProps, Omit<HTMLAttributes<'div'>, 'class'> {}
```

### Content Collection Types

```typescript
// src/types/content.ts
import type { CollectionEntry } from 'astro:content';

/** Type-safe blog post */
export type BlogPost = CollectionEntry<'blog'>;

/** Published blog posts only */
export type PublishedBlogPost = BlogPost & {
  data: BlogPost['data'] & { draft: false };
};

/** Helper to get post data */
export function getPostData(post: BlogPost) {
  return {
    ...post.data,
    url: `/blog/${post.slug}`,
    readingTime: Math.ceil(post.body.split(' ').length / 200), // ~200 WPM
  };
}
```

## Integration Examples

### With Shadcn-ui React Components

```astro
---
// src/components/ContactForm.astro
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
---

<!-- ✅ Wrap Shadcn React components for Astro -->
<form class="space-y-4 max-w-md">
  <div>
    <Label htmlFor="email" client:load>Email</Label>
    <Input
      client:load
      type="email"
      id="email"
      name="email"
      required
      className="mt-1"
    />
  </div>

  <div>
    <Label htmlFor="message" client:load>Message</Label>
    <textarea
      id="message"
      name="message"
      rows={4}
      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
      required
    />
  </div>

  <Button type="submit" client:load>
    Send Message
  </Button>
</form>
```

### With API Routes

```astro
---
// src/pages/newsletter.astro
import BaseLayout from '../layouts/BaseLayout.astro';
---

<BaseLayout title="Newsletter" description="Subscribe to our newsletter">
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-4xl font-bold mb-8">Subscribe</h1>

    <form id="newsletter-form" class="max-w-md">
      <div class="mb-4">
        <label for="email" class="block text-sm font-medium mb-2">
          Email address
        </label>
        <input
          type="email"
          id="email"
          name="email"
          required
          class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <button
        type="submit"
        class="w-full px-6 py-3 bg-blue-500 text-white rounded-md hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        Subscribe
      </button>
    </form>

    <div id="message" role="status" aria-live="polite" class="mt-4"></div>
  </div>

  <script>
    const form = document.getElementById('newsletter-form') as HTMLFormElement;
    const message = document.getElementById('message') as HTMLDivElement;

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const formData = new FormData(form);

      try {
        const response = await fetch('/api/newsletter', {
          method: 'POST',
          body: formData,
        });

        const result = await response.json();

        if (response.ok) {
          message.textContent = 'Successfully subscribed!';
          message.className = 'mt-4 text-green-600';
          form.reset();
        } else {
          message.textContent = result.error || 'Subscription failed';
          message.className = 'mt-4 text-red-600';
        }
      } catch (error) {
        message.textContent = 'Network error. Please try again.';
        message.className = 'mt-4 text-red-600';
      }
    });
  </script>
</BaseLayout>
```

```typescript
// src/pages/api/newsletter.ts
import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request }) => {
  try {
    const formData = await request.formData();
    const email = formData.get('email')?.toString();

    if (!email) {
      return new Response(
        JSON.stringify({ error: 'Email is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Add to newsletter (external API call)
    await fetch('https://api.newsletter-service.com/subscribe', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email }),
    });

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
};
```

## Generation Options

When scaffolding components, consider these options:

1. **Component Type**: Static, Layout, Interactive Wrapper, Content Collection Page
2. **Styling**: Tailwind utilities, Shadcn-ui integration, custom scoped styles
3. **TypeScript**: Full interfaces, prop validation, type exports
4. **Accessibility**: Skip links, ARIA labels, semantic HTML
5. **Dark Mode**: System preference, manual toggle, class-based
6. **Hydration**: Static (default), client:load, client:idle, client:visible
7. **Framework**: Pure Astro, React wrapper, Vue/Svelte wrapper

## Best Practices Applied

All scaffolded components follow these standards:

- ✅ **TypeScript-first** with explicit interfaces
- ✅ **Tailwind CSS** with dark mode support
- ✅ **Semantic HTML** (article, nav, main, section)
- ✅ **Accessibility** (ARIA labels, alt text, skip links, focus indicators)
- ✅ **Performance** (lazy loading, proper hydration, optimized images)
- ✅ **Type safety** (CollectionEntry, Astro.props validation)
- ✅ **Minimal JavaScript** (static by default, hydrate only when needed)
- ✅ **Responsive design** (mobile-first Tailwind breakpoints)
- ✅ **SEO-friendly** (meta tags, semantic structure, canonical URLs)
- ✅ **Class merging** (twMerge for Tailwind conflicts)

## Usage

Ask Claude to scaffold components using this skill:

- "Scaffold an Astro card component with Tailwind"
- "Create a blog layout with dark mode"
- "Generate a content collection page for products"
- "Build an interactive search component with React"

Claude will generate production-ready code following all best practices.
