---
name: javascript-pro
description: Write modern JavaScript with ES6+ features, async patterns, and Node.js APIs. Use when writing JavaScript code, debugging async issues, handling promises, optimizing JS performance, or working with the event loop.
---

# JavaScript Pro

Guidelines for modern JavaScript and async programming patterns.

## Core Principles

1. **Async/await over promise chains** - Cleaner, more readable code
2. **Functional patterns** - Map, filter, reduce over imperative loops
3. **Error boundaries** - Handle errors at appropriate levels
4. **Module-first** - ES modules with clean exports
5. **Defensive coding** - Nullish coalescing and optional chaining

## Modern Syntax (ES2020+)

### Nullish Coalescing and Optional Chaining

```javascript
// Nullish coalescing (??) - only null/undefined
const port = config.port ?? 3000;

// Optional chaining (?.)
const city = user?.address?.city;
const result = obj.method?.();

// Combined pattern
const name = data?.user?.name ?? 'Anonymous';
```

### Destructuring and Spread

```javascript
// Nested destructuring with defaults
const { user: { name = 'Guest', role = 'viewer' } = {} } = response;

// Rest in destructuring
const { id, ...rest } = obj;

// Spread for immutable updates
const updated = { ...original, status: 'active' };
const combined = [...arr1, ...arr2];
```

### Modern Array Methods

```javascript
// Array.at() for negative indexing
const last = arr.at(-1);

// Object.fromEntries() for object creation
const obj = Object.fromEntries([['a', 1], ['b', 2]]);

// Array.prototype.flatMap()
const words = sentences.flatMap(s => s.split(' '));

// Object.hasOwn() (safer than hasOwnProperty)
if (Object.hasOwn(obj, 'key')) { }
```

## Async Patterns

### Promise Combinators

```javascript
// Promise.all - fail fast, all must succeed
const [users, posts] = await Promise.all([
  fetchUsers(),
  fetchPosts()
]);

// Promise.allSettled - get all results regardless of failures
const results = await Promise.allSettled([
  riskyOperation1(),
  riskyOperation2()
]);
const successes = results.filter(r => r.status === 'fulfilled');

// Promise.race - first to complete wins
const result = await Promise.race([
  fetchData(),
  timeout(5000)
]);

// Promise.any - first success wins (ignores rejections)
const fastest = await Promise.any([
  fetchFromCDN1(),
  fetchFromCDN2()
]);
```

### Async Error Handling

```javascript
// Wrapper for clean try/catch
async function safeAsync(promise) {
  try {
    const data = await promise;
    return [data, null];
  } catch (error) {
    return [null, error];
  }
}

// Usage
const [user, error] = await safeAsync(fetchUser(id));
if (error) {
  console.error('Failed to fetch user:', error.message);
  return;
}
```

### Async Iteration

```javascript
// for-await-of for async iterables
async function* paginate(url) {
  let nextUrl = url;
  while (nextUrl) {
    const response = await fetch(nextUrl);
    const data = await response.json();
    yield data.items;
    nextUrl = data.nextPage;
  }
}

for await (const page of paginate('/api/items')) {
  processItems(page);
}
```

### Controlled Concurrency

```javascript
async function processWithLimit(items, fn, limit = 5) {
  const results = [];
  const executing = new Set();

  for (const item of items) {
    const promise = fn(item).then(result => {
      executing.delete(promise);
      return result;
    });
    executing.add(promise);
    results.push(promise);

    if (executing.size >= limit) {
      await Promise.race(executing);
    }
  }

  return Promise.all(results);
}
```

## Module Patterns

### Clean Exports

```javascript
// Named exports for utilities
export function formatDate(date) { }
export function parseDate(str) { }

// Default export for main class/function
export default class ApiClient { }

// Re-exports for barrel files
export { formatDate, parseDate } from './dates.js';
export { default as ApiClient } from './client.js';
```

### Dynamic Imports

```javascript
// Code splitting with dynamic imports
const module = await import('./heavy-module.js');

// Conditional loading
if (featureEnabled) {
  const { Feature } = await import('./feature.js');
  new Feature().init();
}
```

## Node.js Patterns

### File System (fs/promises)

```javascript
import { readFile, writeFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';

async function ensureDir(path) {
  if (!existsSync(path)) {
    await mkdir(path, { recursive: true });
  }
}

const content = await readFile('config.json', 'utf-8');
const config = JSON.parse(content);
```

### Streams

```javascript
import { createReadStream, createWriteStream } from 'fs';
import { pipeline } from 'stream/promises';
import { createGzip } from 'zlib';

await pipeline(
  createReadStream('input.txt'),
  createGzip(),
  createWriteStream('output.txt.gz')
);
```

## Testing Patterns

```javascript
import { describe, it, expect, vi } from 'vitest';

describe('UserService', () => {
  it('fetches user by id', async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      json: () => Promise.resolve({ id: 1, name: 'Test' })
    });

    const user = await fetchUser(1, { fetch: mockFetch });

    expect(user.name).toBe('Test');
    expect(mockFetch).toHaveBeenCalledWith('/api/users/1');
  });
});
```

## Performance Tips

- Use `Map`/`Set` for frequent lookups (O(1) vs O(n))
- Avoid creating functions in loops
- Use `requestAnimationFrame` for DOM updates
- Debounce/throttle event handlers
- Prefer `for...of` over `forEach` for break/continue support

## Common Anti-Patterns

- Using `==` instead of `===`
- Not handling promise rejections
- Modifying objects during iteration
- Using `var` instead of `const`/`let`
- Callback hell instead of async/await
- Not using optional chaining for nested access
