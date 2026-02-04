---
name: typescript-pro
description: Write type-safe TypeScript with advanced types, generics, and strict configuration. Use when writing TypeScript code, designing type systems, creating utility types, fixing type errors, or setting up TypeScript projects.
---

# TypeScript Pro

Guidelines for advanced TypeScript typing and enterprise-grade development.

## Core Principles

1. **Strict mode always** - Enable all strict checks
2. **Infer when clear** - Let TypeScript infer obvious types
3. **Generic constraints** - Use `extends` to constrain generics
4. **Discriminated unions** - For type-safe state machines
5. **Utility types** - Leverage built-in and custom utilities

## Strict TSConfig

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "moduleResolution": "bundler",
    "module": "ESNext",
    "target": "ES2022",
    "lib": ["ES2022", "DOM"],
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}
```

## Advanced Generics

### Constrained Generics

```typescript
// Constrain to objects with specific shape
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Multiple constraints
function merge<T extends object, U extends object>(a: T, b: U): T & U {
  return { ...a, ...b };
}

// Default type parameters
function createState<T = unknown>(initial: T): State<T> {
  return { value: initial, set: (v: T) => { } };
}
```

### Conditional Types

```typescript
// Extract return type of async functions
type Awaited<T> = T extends Promise<infer U> ? U : T;

// Make specific properties optional
type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

// Extract function parameters
type FirstArg<F> = F extends (arg: infer A, ...args: any[]) => any ? A : never;

// Deep readonly
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};
```

### Template Literal Types

```typescript
type HTTPMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type Endpoint = `/api/${string}`;
type Route = `${HTTPMethod} ${Endpoint}`;

// Event handlers
type EventName = 'click' | 'focus' | 'blur';
type Handler = `on${Capitalize<EventName>}`;
// Result: 'onClick' | 'onFocus' | 'onBlur'

// Path parameters
type ExtractParams<T extends string> =
  T extends `${string}:${infer Param}/${infer Rest}`
    ? Param | ExtractParams<Rest>
    : T extends `${string}:${infer Param}`
      ? Param
      : never;

type Params = ExtractParams<'/users/:id/posts/:postId'>;
// Result: 'id' | 'postId'
```

## Discriminated Unions

### State Machines

```typescript
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function handleState<T>(state: RequestState<T>) {
  switch (state.status) {
    case 'idle':
      return 'Ready';
    case 'loading':
      return 'Loading...';
    case 'success':
      return state.data; // TypeScript knows data exists
    case 'error':
      return state.error.message; // TypeScript knows error exists
  }
}
```

### Exhaustive Checks

```typescript
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`);
}

type Shape = { kind: 'circle'; radius: number }
           | { kind: 'square'; side: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case 'circle':
      return Math.PI * shape.radius ** 2;
    case 'square':
      return shape.side ** 2;
    default:
      return assertNever(shape); // Compile error if cases missed
  }
}
```

## Utility Types

### Built-in Utilities

```typescript
// Partial<T> - all properties optional
// Required<T> - all properties required
// Readonly<T> - all properties readonly
// Record<K, V> - object with keys K and values V
// Pick<T, K> - subset of properties
// Omit<T, K> - exclude properties
// Exclude<T, U> - exclude types from union
// Extract<T, U> - extract types from union
// NonNullable<T> - remove null and undefined
// ReturnType<F> - return type of function
// Parameters<F> - parameter types as tuple
// Awaited<T> - unwrap Promise type
```

### Custom Utility Types

```typescript
// Make all properties mutable
type Mutable<T> = {
  -readonly [K in keyof T]: T[K];
};

// Require at least one of the specified keys
type RequireAtLeastOne<T, Keys extends keyof T = keyof T> =
  Pick<T, Exclude<keyof T, Keys>> &
  { [K in Keys]: Required<Pick<T, K>> }[Keys];

// Exact type (no extra properties)
type Exact<T, U extends T> = T & Record<Exclude<keyof U, keyof T>, never>;

// Deep partial
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K];
};
```

## Type Guards

```typescript
// Type predicates
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

// Assertion functions
function assertDefined<T>(value: T | null | undefined): asserts value is T {
  if (value === null || value === undefined) {
    throw new Error('Value is not defined');
  }
}

// Usage
const data: string | null = getData();
assertDefined(data);
// data is now string (not string | null)
```

## Branded Types

```typescript
// Nominal typing via branding
type Brand<T, B> = T & { __brand: B };

type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;

function getUser(id: UserId): User { }

const userId = 'abc' as UserId;
const orderId = 'xyz' as OrderId;

getUser(userId);  // OK
getUser(orderId); // Error: OrderId not assignable to UserId
```

## Function Overloads

```typescript
// Overloads for different return types based on input
function parse(input: string): object;
function parse(input: string, asArray: true): unknown[];
function parse(input: string, asArray?: boolean): object | unknown[] {
  const result = JSON.parse(input);
  return asArray ? (Array.isArray(result) ? result : [result]) : result;
}
```

## Module Augmentation

```typescript
// Extend existing module types
declare module 'express' {
  interface Request {
    user?: { id: string; role: string };
  }
}

// Global augmentation
declare global {
  interface Window {
    analytics: Analytics;
  }
}
```

## Common Patterns

### Builder Pattern

```typescript
class QueryBuilder<T extends object> {
  private query: Partial<T> = {};

  where<K extends keyof T>(key: K, value: T[K]): this {
    this.query[key] = value;
    return this;
  }

  build(): Partial<T> {
    return { ...this.query };
  }
}
```

### Result Type

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}
```
