---
name: writing-modern-javascript
description: Write modern JavaScript with ES6+ features, async patterns, and Node.js best practices. Use when writing JavaScript code, implementing async operations, working with promises, handling Node.js APIs, or optimizing JavaScript performance.
---

> **[DEPRECATED]** Candidate for removal (2026-03-03). If unused by 2026-03-17, delete this skill.

# Modern JavaScript

Idiomatic patterns for ES6+ JavaScript and Node.js.

## Async Patterns

### Prefer async/await

```javascript
// ❌ Avoid: Promise chains
function fetchUserData(userId) {
  return fetch(`/api/users/${userId}`)
    .then(response => response.json())
    .then(user => fetch(`/api/posts?user=${user.id}`))
    .then(response => response.json())
    .catch(error => console.error(error));
}

// ✅ Prefer: async/await
async function fetchUserData(userId) {
  try {
    const userResponse = await fetch(`/api/users/${userId}`);
    const user = await userResponse.json();

    const postsResponse = await fetch(`/api/posts?user=${user.id}`);
    return await postsResponse.json();
  } catch (error) {
    console.error('Failed to fetch user data:', error);
    throw error;
  }
}
```

### Parallel Execution

```javascript
// ❌ Avoid: Sequential when parallel is possible
const user = await fetchUser(id);
const posts = await fetchPosts(id);
const comments = await fetchComments(id);

// ✅ Prefer: Parallel execution
const [user, posts, comments] = await Promise.all([
  fetchUser(id),
  fetchPosts(id),
  fetchComments(id)
]);

// For error isolation, use Promise.allSettled
const results = await Promise.allSettled([
  fetchUser(id),
  fetchPosts(id),
  fetchComments(id)
]);
```

### Error Handling

```javascript
// ✅ Handle errors at appropriate boundaries
async function processData() {
  try {
    const data = await fetchData();
    return await transformData(data);
  } catch (error) {
    if (error.code === 'ECONNREFUSED') {
      throw new ServiceUnavailableError('Database connection failed');
    }
    throw error; // Re-throw unknown errors
  }
}
```

## Modern Syntax

### Destructuring

```javascript
// ✅ Object destructuring
const { name, email, address: { city } } = user;

// ✅ Array destructuring
const [first, second, ...rest] = items;

// ✅ Function parameters
function createUser({ name, email, role = 'user' }) {
  // defaults and destructuring in one step
}
```

### Spread and Rest

```javascript
// ✅ Object spreading
const updatedUser = { ...user, email: 'new@example.com' };

// ✅ Array spreading
const allItems = [...itemsA, ...itemsB];

// ✅ Rest parameters
function sum(...numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}
```

### Template Literals

```javascript
// ✅ Multi-line strings and interpolation
const message = `
  Hello ${user.name},

  Your order #${order.id} is ready.
  Total: $${order.total.toFixed(2)}
`;

// ✅ Tagged templates for advanced use
const query = sql`
  SELECT * FROM users
  WHERE id = ${userId}
  AND status = ${status}
`;
```

## Functional Patterns

### Array Methods

```javascript
// ✅ Declarative over imperative
const activeUsers = users
  .filter(user => user.active)
  .map(user => ({ id: user.id, name: user.name }))
  .sort((a, b) => a.name.localeCompare(b.name));

// ✅ Reduce for aggregation
const totalSpent = orders.reduce((sum, order) => sum + order.total, 0);

// ✅ Find for single results
const admin = users.find(user => user.role === 'admin');
```

### Avoid Side Effects

```javascript
// ❌ Avoid: Mutation in map
const processedUsers = users.map(user => {
  user.processed = true; // mutates original
  return user;
});

// ✅ Prefer: Return new objects
const processedUsers = users.map(user => ({
  ...user,
  processed: true
}));
```

## Node.js Patterns

### Module Exports

```javascript
// ✅ Named exports for multiple items
export const createUser = (data) => { /* ... */ };
export const deleteUser = (id) => { /* ... */ };

// ✅ Default export for single primary export
export default class UserService {
  // ...
}

// ✅ Import what you need
import { createUser, deleteUser } from './users.js';
import UserService from './user-service.js';
```

### File Operations

```javascript
// ✅ Use promises/async API
import { readFile, writeFile } from 'fs/promises';

async function processFile(path) {
  const content = await readFile(path, 'utf-8');
  const processed = transform(content);
  await writeFile(path, processed);
}
```

### Event Emitters

```javascript
import { EventEmitter } from 'events';

class TaskQueue extends EventEmitter {
  async process(task) {
    this.emit('task:start', task);

    try {
      const result = await task.execute();
      this.emit('task:complete', task, result);
      return result;
    } catch (error) {
      this.emit('task:error', task, error);
      throw error;
    }
  }
}

const queue = new TaskQueue();
queue.on('task:error', (task, error) => {
  console.error(`Task ${task.id} failed:`, error);
});
```

## Performance

### Avoid Blocking

```javascript
// ❌ Avoid: Blocking operations
const data = fs.readFileSync('large-file.json'); // blocks event loop

// ✅ Prefer: Non-blocking
const data = await fs.promises.readFile('large-file.json');
```

### Debouncing and Throttling

```javascript
// ✅ Debounce: Wait for quiet period
function debounce(fn, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn.apply(this, args), delay);
  };
}

const searchUsers = debounce(async (query) => {
  const results = await api.search(query);
  displayResults(results);
}, 300);

// ✅ Throttle: Limit execution rate
function throttle(fn, limit) {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      fn.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}
```

### Memory Management

```javascript
// ✅ Use streams for large files
import { createReadStream } from 'fs';
import { createInterface } from 'readline';

async function processLargeFile(path) {
  const fileStream = createReadStream(path);
  const rl = createInterface({ input: fileStream });

  for await (const line of rl) {
    processLine(line); // process one line at a time
  }
}
```

## Common Pitfalls

### Event Loop Understanding

```javascript
// Understanding execution order
console.log('1');

setTimeout(() => console.log('2'), 0);

Promise.resolve().then(() => console.log('3'));

console.log('4');

// Output: 1, 4, 3, 2
// Microtasks (promises) run before macrotasks (setTimeout)
```

### Closure Gotchas

```javascript
// ❌ Common mistake: Loop with var
for (var i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 100);
} // Logs: 3, 3, 3

// ✅ Solution: Use let
for (let i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 100);
} // Logs: 0, 1, 2
```

### This Binding

```javascript
class Counter {
  count = 0;

  // ❌ Traditional function loses 'this' context
  increment() {
    setTimeout(function() {
      this.count++; // 'this' is undefined
    }, 100);
  }

  // ✅ Arrow function preserves 'this'
  incrementCorrect() {
    setTimeout(() => {
      this.count++; // 'this' refers to Counter instance
    }, 100);
  }
}
```

## Testing

```javascript
import { jest } from '@jest/globals';

describe('UserService', () => {
  it('creates user with valid data', async () => {
    const service = new UserService();
    const userData = { name: 'John', email: 'john@example.com' };

    const user = await service.createUser(userData);

    expect(user).toMatchObject(userData);
    expect(user.id).toBeDefined();
  });

  it('throws error for invalid email', async () => {
    const service = new UserService();

    await expect(
      service.createUser({ name: 'John', email: 'invalid' })
    ).rejects.toThrow('Invalid email');
  });
});
```
