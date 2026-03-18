---
name: astro-content-collections
description: Configure content collections with Zod schemas, query patterns, and type-safe access. Use when setting up blog systems, documentation sites, managing structured content, or building content-driven applications.
allowed-tools: Read, Write, Edit, Bash
---

# Astro Content Collections

Complete guide for configuring and using Astro's Content Collections with type-safe schemas and optimized query patterns.

## Collection Configuration

### Basic Setup

```typescript
// src/content/config.ts
import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  type: 'content', // Markdown/MDX files
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    author: z.string(),
  }),
});

export const collections = { blog };
```

### Advanced Schema Patterns

```typescript
// src/content/config.ts
import { defineCollection, z, reference } from 'astro:content';

// ✅ Blog collection with validation
const blog = defineCollection({
  type: 'content',
  schema: ({ image }) => z.object({
    // Required fields
    title: z.string().min(1).max(100),
    description: z.string().min(50).max(160), // SEO: meta description

    // Dates with coercion
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),

    // Author reference (cross-collection)
    author: reference('authors'),

    // Enums for controlled values
    status: z.enum(['draft', 'published', 'archived']).default('published'),
    category: z.enum(['technology', 'design', 'business']),

    // Arrays
    tags: z.array(z.string()).default([]),
    relatedPosts: z.array(reference('blog')).optional(),

    // Nested objects
    coverImage: z.object({
      src: image(), // Optimized image type
      alt: z.string().min(1), // Accessibility: required alt text
      credit: z.string().optional(),
    }).optional(),

    // SEO fields
    seo: z.object({
      metaTitle: z.string().max(60).optional(),
      metaDescription: z.string().max(160).optional(),
      ogImage: z.string().optional(),
      noindex: z.boolean().default(false),
    }).optional(),

    // Feature flags
    featured: z.boolean().default(false),
    draft: z.boolean().default(false),

    // Conditional fields
    videoUrl: z.string().url().optional(),
    estimatedReadTime: z.number().int().positive().optional(),
  }),
});

// ✅ Data collection (JSON/YAML)
const authors = defineCollection({
  type: 'data',
  schema: z.object({
    name: z.string(),
    bio: z.string(),
    avatar: z.string(),
    email: z.string().email(),
    social: z.object({
      twitter: z.string().optional(),
      github: z.string().optional(),
      linkedin: z.string().optional(),
    }).optional(),
    active: z.boolean().default(true),
  }),
});

// ✅ Documentation collection
const docs = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    order: z.number().int().default(0), // For sorting
    section: z.string(), // Group docs by section
    version: z.string().default('1.0'),
    lastReviewed: z.coerce.date().optional(),
  }),
});

export const collections = { blog, authors, docs };
```

### Collection Types: Data vs Content

```typescript
// ✅ Content collection - Markdown/MDX with frontmatter
const blog = defineCollection({
  type: 'content', // Has .md or .mdx files
  schema: z.object({
    title: z.string(),
    // ... frontmatter fields
  }),
});

// ✅ Data collection - JSON or YAML files
const products = defineCollection({
  type: 'data', // .json or .yaml files
  schema: z.object({
    name: z.string(),
    price: z.number(),
    inStock: z.boolean(),
  }),
});
```

**When to use each:**

- **Content** (`type: 'content'`): Blog posts, docs, articles (needs rendering)
- **Data** (`type: 'data'`): Configuration, structured data, API responses (no rendering)

## Query Patterns

### Basic Queries

```typescript
import { getCollection, getEntry } from 'astro:content';

// ✅ Get all entries
const allPosts = await getCollection('blog');

// ✅ Get single entry by slug
const post = await getEntry('blog', 'my-first-post');

// ✅ Filter entries
const publishedPosts = await getCollection('blog', ({ data }) => {
  return data.draft !== true;
});

// ✅ Production-only filtering
const posts = await getCollection('blog', ({ data }) => {
  return import.meta.env.PROD ? data.status === 'published' : true;
});
```

### Sorting Patterns

```typescript
// ✅ Sort by date (newest first)
const sortedByDate = posts.sort((a, b) =>
  b.data.pubDate.valueOf() - a.data.pubDate.valueOf()
);

// ✅ Sort by multiple fields
const sortedPosts = posts.sort((a, b) => {
  // Featured posts first
  if (a.data.featured !== b.data.featured) {
    return a.data.featured ? -1 : 1;
  }
  // Then by date
  return b.data.pubDate.valueOf() - a.data.pubDate.valueOf();
});

// ✅ Sort by order field (for docs)
const sortedDocs = docs.sort((a, b) => a.data.order - b.data.order);
```

### Advanced Filtering

```typescript
// ✅ Filter by tag
const taggedPosts = await getCollection('blog', ({ data }) => {
  return data.tags.includes('typescript');
});

// ✅ Filter by author
const authorPosts = await getCollection('blog', ({ data }) => {
  return data.author.id === 'john-doe';
});

// ✅ Filter by date range
const recentPosts = await getCollection('blog', ({ data }) => {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  return data.pubDate >= thirtyDaysAgo;
});

// ✅ Complex filters
const filteredPosts = await getCollection('blog', ({ data }) => {
  return (
    data.status === 'published' &&
    !data.draft &&
    data.category === 'technology' &&
    data.tags.some(tag => ['typescript', 'astro'].includes(tag))
  );
});
```

### Performance-Optimized Queries

```typescript
// ✅ Limit results early
const recentPosts = (await getCollection('blog'))
  .sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf())
  .slice(0, 10); // Only take top 10

// ✅ Use filter callback (more efficient than .filter())
const published = await getCollection('blog', ({ data }) => {
  return data.status === 'published'; // Filter during query
});

// ❌ Less efficient
const allPosts = await getCollection('blog');
const published = allPosts.filter(p => p.data.status === 'published');
```

## Page Generation

### Static Path Generation

```astro
---
// src/pages/blog/[...slug].astro
import { type CollectionEntry, getCollection } from 'astro:content';
import BlogLayout from '../../layouts/BlogLayout.astro';

export async function getStaticPaths() {
  const posts = await getCollection('blog', ({ data }) => {
    return import.meta.env.PROD ? data.draft !== true : true;
  });

  // ⚠️ Performance check
  if (posts.length > 1000) {
    console.warn(`Large collection (${posts.length} posts). Consider pagination.`);
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
const { Content, headings } = await post.render();
---

<BlogLayout post={post}>
  <Content />
</BlogLayout>
```

### Pagination Implementation

```astro
---
// src/pages/blog/[page].astro
import type { GetStaticPaths, Page } from 'astro';
import type { CollectionEntry } from 'astro:content';
import { getCollection } from 'astro:content';

export const getStaticPaths = (async ({ paginate }) => {
  const posts = await getCollection('blog', ({ data }) => {
    return data.status === 'published';
  });

  const sortedPosts = posts.sort((a, b) =>
    b.data.pubDate.valueOf() - a.data.pubDate.valueOf()
  );

  // ✅ Paginate with 10 posts per page
  return paginate(sortedPosts, {
    pageSize: 10,
  });
}) satisfies GetStaticPaths;

interface Props {
  page: Page<CollectionEntry<'blog'>>;
}

const { page } = Astro.props;
---

<div class="container mx-auto px-4 py-8">
  <h1 class="text-4xl font-bold mb-8">Blog</h1>

  <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
    {page.data.map((post) => (
      <article class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-bold mb-2">
          <a href={`/blog/${post.slug}`} class="hover:text-blue-600">
            {post.data.title}
          </a>
        </h2>
        <p class="text-gray-600 dark:text-gray-300 mb-4">
          {post.data.description}
        </p>
        <time datetime={post.data.pubDate.toISOString()} class="text-sm text-gray-500">
          {post.data.pubDate.toLocaleDateString()}
        </time>
      </article>
    ))}
  </div>

  <!-- Pagination controls -->
  <nav class="flex justify-center gap-2 mt-8" aria-label="Pagination">
    {page.url.prev && (
      <a
        href={page.url.prev}
        class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
      >
        Previous
      </a>
    )}
    <span class="px-4 py-2 text-gray-700 dark:text-gray-300">
      Page {page.currentPage} of {page.lastPage}
    </span>
    {page.url.next && (
      <a
        href={page.url.next}
        class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
      >
        Next
      </a>
    )}
  </nav>
</div>
```

### Tag Pages Pattern

```astro
---
// src/pages/blog/tags/[tag].astro
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('blog');

  // ✅ Get unique tags
  const allTags = new Set<string>();
  posts.forEach((post) => {
    post.data.tags?.forEach((tag) => allTags.add(tag));
  });

  // ✅ Generate page for each tag
  return Array.from(allTags).map((tag) => ({
    params: { tag },
    props: {
      tag,
      posts: posts.filter((post) => post.data.tags?.includes(tag)),
    },
  }));
}

const { tag, posts } = Astro.props;
const sortedPosts = posts.sort((a, b) =>
  b.data.pubDate.valueOf() - a.data.pubDate.valueOf()
);
---

<div class="container mx-auto px-4 py-8">
  <h1 class="text-4xl font-bold mb-8">
    Posts tagged with "{tag}"
    <span class="text-gray-500 text-2xl ml-2">({sortedPosts.length})</span>
  </h1>

  <!-- Post list -->
</div>
```

## Relationships Between Collections

### Cross-Collection References

```typescript
// src/content/config.ts
import { defineCollection, z, reference } from 'astro:content';

const authors = defineCollection({
  type: 'data',
  schema: z.object({
    name: z.string(),
    bio: z.string(),
    avatar: z.string(),
  }),
});

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    author: reference('authors'), // ✅ Type-safe reference
    relatedPosts: z.array(reference('blog')).optional(), // Self-reference
  }),
});

export const collections = { authors, blog };
```

### Using Referenced Data

```astro
---
// src/pages/blog/[...slug].astro
import { getEntry } from 'astro:content';

const { post } = Astro.props;

// ✅ Resolve author reference
const author = await getEntry(post.data.author);

// ✅ Resolve related posts
const relatedPosts = post.data.relatedPosts
  ? await Promise.all(post.data.relatedPosts.map((ref) => getEntry(ref)))
  : [];
---

<article>
  <h1>{post.data.title}</h1>

  <!-- Author info -->
  <div class="flex items-center gap-4 mt-4">
    <img
      src={author.data.avatar}
      alt={author.data.name}
      class="w-12 h-12 rounded-full"
    />
    <div>
      <p class="font-semibold">{author.data.name}</p>
      <p class="text-sm text-gray-600">{author.data.bio}</p>
    </div>
  </div>

  <!-- Related posts -->
  {relatedPosts.length > 0 && (
    <aside class="mt-8">
      <h2 class="text-2xl font-bold mb-4">Related Posts</h2>
      <ul class="space-y-2">
        {relatedPosts.map((related) => (
          <li>
            <a href={`/blog/${related.slug}`} class="text-blue-600 hover:underline">
              {related.data.title}
            </a>
          </li>
        ))}
      </ul>
    </aside>
  )}
</article>
```

## RSS Feed Generation

```typescript
// src/pages/rss.xml.ts
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const posts = await getCollection('blog', ({ data }) => {
    return data.status === 'published';
  });

  const sortedPosts = posts.sort((a, b) =>
    b.data.pubDate.valueOf() - a.data.pubDate.valueOf()
  );

  return rss({
    title: 'My Blog',
    description: 'A blog about web development',
    site: context.site,
    items: sortedPosts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.pubDate,
      link: `/blog/${post.slug}/`,
      categories: post.data.tags,
      author: post.data.author,
    })),
    customData: '<language>en-us</language>',
  });
}
```

## Common Patterns

### Search Implementation

```astro
---
// src/pages/search.astro
import { getCollection } from 'astro:content';

const query = Astro.url.searchParams.get('q') || '';
const posts = await getCollection('blog');

// ✅ Simple client-side search
const results = query
  ? posts.filter((post) => {
      const searchContent = `${post.data.title} ${post.data.description} ${post.data.tags?.join(' ')}`.toLowerCase();
      return searchContent.includes(query.toLowerCase());
    })
  : [];
---

<div class="container mx-auto px-4 py-8">
  <h1 class="text-4xl font-bold mb-8">Search</h1>

  <form method="get" class="mb-8">
    <input
      type="search"
      name="q"
      value={query}
      placeholder="Search posts..."
      class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
    />
  </form>

  {query && (
    <p class="text-gray-600 mb-4">
      Found {results.length} result(s) for "{query}"
    </p>
  )}

  <div class="space-y-4">
    {results.map((post) => (
      <article class="border-b pb-4">
        <h2 class="text-2xl font-bold">
          <a href={`/blog/${post.slug}`} class="hover:text-blue-600">
            {post.data.title}
          </a>
        </h2>
        <p class="text-gray-600">{post.data.description}</p>
      </article>
    ))}
  </div>
</div>
```

### Archive Pages by Year/Month

```astro
---
// src/pages/blog/archive/[year]/[month].astro
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('blog');

  // ✅ Group by year and month
  const archives = new Map<string, typeof posts>();

  posts.forEach((post) => {
    const year = post.data.pubDate.getFullYear();
    const month = post.data.pubDate.getMonth() + 1;
    const key = `${year}/${month.toString().padStart(2, '0')}`;

    if (!archives.has(key)) {
      archives.set(key, []);
    }
    archives.get(key)!.push(post);
  });

  return Array.from(archives.entries()).map(([key, posts]) => {
    const [year, month] = key.split('/');
    return {
      params: { year, month },
      props: { posts, year, month },
    };
  });
}

const { posts, year, month } = Astro.props;
const monthName = new Date(parseInt(year), parseInt(month) - 1).toLocaleString('default', {
  month: 'long',
});
---

<div class="container mx-auto px-4 py-8">
  <h1 class="text-4xl font-bold mb-8">
    Archive: {monthName} {year}
  </h1>

  <!-- Post list -->
</div>
```

## Migration Patterns

### Moving from File-Based to Collections

**Before (file-based):**

```typescript
// src/pages/blog/[slug].astro
const posts = await Astro.glob('../content/blog/*.md');
```

**After (content collections):**

```typescript
// src/pages/blog/[...slug].astro
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('blog');
  return posts.map(post => ({
    params: { slug: post.slug },
    props: { post },
  }));
}
```

**Benefits:**

- ✅ Type-safe frontmatter with Zod validation
- ✅ Better IDE autocomplete
- ✅ Validation errors at build time
- ✅ Centralized schema definition
- ✅ Cross-collection references

## Best Practices

1. **✅ Validate frontmatter**: Use Zod schemas to catch errors early
2. **✅ Filter in queries**: Use callback parameter in `getCollection()` for performance
3. **✅ Sort efficiently**: Sort once after filtering, not multiple times
4. **✅ Require alt text**: Make `alt` required in image schemas for accessibility
5. **✅ Use references**: Leverage `reference()` for type-safe relationships
6. **✅ Monitor collection size**: Warn when collections exceed 1000 items (pagination needed)
7. **✅ Pagination**: Use `paginate()` for large collections
8. **✅ Cache queries**: Store `getCollection()` results in variables to avoid re-fetching

## Usage

Ask Claude to help with content collections:

- "Set up a blog content collection with Zod schema"
- "Create pagination for my blog posts"
- "Generate tag pages from content collection"
- "Add author references to blog posts"
- "Implement RSS feed from content collection"

Claude will generate optimized, type-safe collection configurations.
