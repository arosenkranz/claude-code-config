---
name: creating-reference-docs
description: Create exhaustive, searchable reference documentation for APIs, libraries, and configuration systems. Use when documenting API references, configuration options, library methods, schema definitions, or creating comprehensive technical references.
---

> **[DEPRECATED]** Candidate for removal (2026-03-03). If unused by 2026-03-17, delete this skill.

# Reference Documentation

Create complete, searchable reference materials with every parameter, option, and method documented.

## Reference Entry Structure

Each entry must be exhaustive and follow this format:

```markdown
## `methodName(param1, param2, options)`

### Description
Clear explanation of what this method does and when to use it.

### Syntax
\`\`\`javascript
object.methodName(param1, param2[, options])
\`\`\`

### Parameters

#### `param1` (required)
- **Type**: `string`
- **Description**: Detailed parameter description
- **Constraints**: Min length: 1, Max length: 255
- **Example**: `"user-123"`

#### `param2` (required)
- **Type**: `number`
- **Description**: Detailed parameter description
- **Range**: 0-100
- **Default**: None (required)

#### `options` (optional)
- **Type**: `object`
- **Description**: Configuration options

##### `options.timeout`
- **Type**: `number`
- **Description**: Request timeout in milliseconds
- **Default**: `5000`
- **Range**: 100-30000

### Returns
- **Type**: `Promise<Result>`
- **Description**: Returns a promise that resolves with the result object

### Errors

| Error Code | Description | When It Occurs |
|------------|-------------|----------------|
| `INVALID_PARAM` | Parameter validation failed | When param1 is empty |
| `TIMEOUT` | Operation timed out | When execution exceeds timeout |
| `NOT_FOUND` | Resource not found | When the specified resource doesn't exist |

### Examples

#### Basic Usage
\`\`\`javascript
const result = await object.methodName("user-123", 42);
console.log(result);
// Output: { success: true, data: {...} }
\`\`\`

#### With Options
\`\`\`javascript
const result = await object.methodName("user-123", 42, {
  timeout: 10000,
  retries: 3
});
\`\`\`

#### Error Handling
\`\`\`javascript
try {
  const result = await object.methodName("", 42);
} catch (error) {
  if (error.code === 'INVALID_PARAM') {
    console.error('Parameter validation failed:', error.message);
  }
}
\`\`\`

### Notes
- This method is rate-limited to 100 requests per minute
- Large responses may be paginated
- Requires authentication scope: `read:users`

### See Also
- [`relatedMethod()`](#relatedmethod) - Alternative approach
- [Authentication Guide](#authentication) - Setup required permissions
- [Rate Limiting](#rate-limiting) - Understand limits

### Changelog
- `v2.0.0`: Added `options.retries` parameter
- `v1.5.0`: Increased timeout range maximum
- `v1.0.0`: Initial release
```

## Configuration Reference

Document every configuration option:

```markdown
## Configuration Options

### `database.host`
- **Type**: `string`
- **Required**: Yes
- **Description**: Database server hostname or IP address
- **Example**: `"localhost"` or `"192.168.1.100"`
- **Environment Variable**: `DB_HOST`

### `database.port`
- **Type**: `number`
- **Required**: No
- **Default**: `5432`
- **Description**: Database server port
- **Range**: 1-65535
- **Example**: `5432`
- **Environment Variable**: `DB_PORT`

### `database.pool.min`
- **Type**: `number`
- **Required**: No
- **Default**: `2`
- **Description**: Minimum number of connections in the pool
- **Range**: 0-100
- **Recommendation**: Set to 2-5 for typical applications
- **Environment Variable**: `DB_POOL_MIN`

### `database.pool.max`
- **Type**: `number`
- **Required**: No
- **Default**: `10`
- **Description**: Maximum number of connections in the pool
- **Range**: 1-1000
- **Recommendation**: Set based on expected concurrent load
- **Performance Note**: Too many connections can degrade performance
- **Environment Variable**: `DB_POOL_MAX`
```

## Organization Patterns

### Multiple Access Paths

Organize content for different lookup patterns:

1. **Alphabetical Index** - Quick A-Z lookup
2. **By Category** - Group related items
3. **By Use Case** - Organize by common tasks
4. **Quick Reference Card** - Most common operations

Example:

```markdown
# Quick Reference

## Most Common Operations

| Task | Method | Example |
|------|--------|---------|
| Create user | `createUser(data)` | `api.createUser({name: "John"})` |
| Get user | `getUser(id)` | `api.getUser("123")` |
| Update user | `updateUser(id, data)` | `api.updateUser("123", {name: "Jane"})` |
| Delete user | `deleteUser(id)` | `api.deleteUser("123")` |

## By Category

### User Management
- [`createUser(data)`](#createuser)
- [`getUser(id)`](#getuser)
- [`updateUser(id, data)`](#updateuser)
- [`deleteUser(id)`](#deleteuser)

### Authentication
- [`login(credentials)`](#login)
- [`logout()`](#logout)
- [`refreshToken(token)`](#refreshtoken)

## Alphabetical Index

### A
- [`authenticate()`](#authenticate)
- [`authorize()`](#authorize)

### B
- [`batchCreate(items)`](#batchcreate)
- [`batchDelete(ids)`](#batchdelete)
```

## Schema Documentation

```markdown
## User Schema

\`\`\`typescript
interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  metadata?: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}
\`\`\`

### Fields

#### `id`
- **Type**: `string` (UUID v4)
- **Required**: Yes
- **Immutable**: Yes
- **Description**: Unique identifier for the user
- **Example**: `"123e4567-e89b-12d3-a456-426614174000"`
- **Validation**: Must be valid UUID v4 format

#### `email`
- **Type**: `string`
- **Required**: Yes
- **Unique**: Yes
- **Description**: User's email address
- **Format**: Valid email address per RFC 5322
- **Max Length**: 255 characters
- **Example**: `"user@example.com"`
- **Validation**: Must contain @ and valid domain
- **Index**: Indexed for quick lookup

#### `role`
- **Type**: `UserRole` enum
- **Required**: Yes
- **Default**: `"user"`
- **Description**: User's role in the system
- **Possible Values**:
  - `"admin"` - Full system access
  - `"moderator"` - Content moderation access
  - `"user"` - Standard user access
  - `"guest"` - Limited read-only access

#### `metadata`
- **Type**: `Record<string, any>`
- **Required**: No
- **Default**: `{}`
- **Description**: Flexible key-value storage for custom user data
- **Max Size**: 10KB serialized JSON
- **Example**: `{"preferences": {"theme": "dark"}, "lastLogin": "2024-01-15"}`
```

## Error Code Reference

Complete error documentation:

```markdown
## Error Codes

### Authentication Errors (1xxx)

#### `1001` - INVALID_CREDENTIALS
- **HTTP Status**: 401
- **Description**: Username or password is incorrect
- **Resolution**: Verify credentials and try again
- **Example Response**:
\`\`\`json
{
  "error": "INVALID_CREDENTIALS",
  "message": "Invalid username or password",
  "code": 1001
}
\`\`\`

#### `1002` - TOKEN_EXPIRED
- **HTTP Status**: 401
- **Description**: Authentication token has expired
- **Resolution**: Refresh the token using `/auth/refresh` endpoint
- **Example Response**:
\`\`\`json
{
  "error": "TOKEN_EXPIRED",
  "message": "Your session has expired",
  "code": 1002,
  "expiredAt": "2024-01-15T10:30:00Z"
}
\`\`\`

### Validation Errors (2xxx)

#### `2001` - MISSING_REQUIRED_FIELD
- **HTTP Status**: 400
- **Description**: A required field is missing from the request
- **Resolution**: Include all required fields
- **Example Response**:
\`\`\`json
{
  "error": "MISSING_REQUIRED_FIELD",
  "message": "Field 'email' is required",
  "code": 2001,
  "field": "email"
}
\`\`\`
```

## Migration Guides

Document version changes:

```markdown
## Migrating from v1 to v2

### Breaking Changes

#### Authentication Method Changed

**v1 (deprecated):**
\`\`\`javascript
api.authenticate(username, password);
\`\`\`

**v2:**
\`\`\`javascript
api.login({ email: username, password });
\`\`\`

**Rationale**: New method supports multiple authentication providers and follows REST conventions.

**Migration Steps**:
1. Replace `authenticate()` calls with `login()`
2. Change username parameter to email object property
3. Update error handling (see Error Codes section)

#### User Creation Response Structure

**v1:**
\`\`\`json
{
  "userId": "123",
  "status": "created"
}
\`\`\`

**v2:**
\`\`\`json
{
  "data": {
    "id": "123",
    "email": "user@example.com",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
\`\`\`

**Migration**: Access `response.data.id` instead of `response.userId`
```

## Quality Checklist

Reference documentation must have:

- [ ] Every public method documented
- [ ] All parameters explained with types
- [ ] Default values specified
- [ ] Constraints and ranges documented
- [ ] Working examples for each feature
- [ ] All error codes documented
- [ ] Response formats shown
- [ ] Migration guides for breaking changes
- [ ] Cross-references between related items
- [ ] Search-friendly keywords
