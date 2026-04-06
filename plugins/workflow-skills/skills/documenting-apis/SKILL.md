---
name: documenting-apis
description: Create OpenAPI/Swagger specifications, generate SDK documentation, and write developer-focused API guides. Use when creating API documentation, writing endpoint specs, documenting REST APIs, or generating client library documentation.
---

# API Documentation

Create comprehensive, developer-focused API documentation following OpenAPI standards.

## Quick Start

### OpenAPI 3.0 Specification

```yaml
openapi: 3.0.0
info:
  title: Your API
  version: 1.0.0
  description: Brief API description

servers:
  - url: https://api.example.com/v1

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 10
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'

components:
  schemas:
    User:
      type: object
      required:
        - id
        - email
      properties:
        id:
          type: string
        email:
          type: string
          format: email
```

## Documentation Structure

### 1. Overview Section
- API purpose and capabilities
- Authentication methods
- Base URLs for environments
- Rate limiting policies

### 2. Authentication Guide

```markdown
## Authentication

All requests require an API key in the Authorization header:

\`\`\`bash
curl -H "Authorization: Bearer YOUR_API_KEY" \\
  https://api.example.com/v1/users
\`\`\`

Get your API key from the [dashboard](https://example.com/dashboard).
```

### 3. Endpoint Documentation

For each endpoint, include:

```markdown
## GET /users/{id}

Retrieve a specific user by ID.

**Parameters:**
- `id` (path, required): User UUID

**Response 200:**
\`\`\`json
{
  "id": "123e4567-e89b-12d3",
  "email": "user@example.com",
  "created_at": "2024-01-15T10:30:00Z"
}
\`\`\`

**Response 404:**
\`\`\`json
{
  "error": "user_not_found",
  "message": "User with id '...' does not exist"
}
\`\`\`
```

### 4. Error Reference

| Status | Code | Meaning |
|--------|------|---------|
| 400 | `invalid_request` | Missing required parameters |
| 401 | `unauthorized` | Invalid or missing API key |
| 404 | `not_found` | Resource doesn't exist |
| 429 | `rate_limit_exceeded` | Too many requests |
| 500 | `internal_error` | Server error, contact support |

## Code Examples

Provide examples in multiple languages:

````markdown
### Create User

**cURL:**
\`\`\`bash
curl -X POST https://api.example.com/v1/users \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{"email": "user@example.com", "name": "John Doe"}'
\`\`\`

**JavaScript:**
\`\`\`javascript
const response = await fetch('https://api.example.com/v1/users', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ email: 'user@example.com', name: 'John Doe' })
});
const user = await response.json();
\`\`\`

**Python:**
\`\`\`python
import requests

response = requests.post(
    'https://api.example.com/v1/users',
    headers={'Authorization': 'Bearer YOUR_API_KEY'},
    json={'email': 'user@example.com', 'name': 'John Doe'}
)
user = response.json()
\`\`\`
````

## SDK Documentation

When documenting client libraries:

### Installation
```markdown
## Installation

\`\`\`bash
npm install @example/sdk
\`\`\`
```

### Quick Start
```javascript
import { ExampleClient } from '@example/sdk';

const client = new ExampleClient({ apiKey: 'YOUR_API_KEY' });

// Create a user
const user = await client.users.create({
  email: 'user@example.com',
  name: 'John Doe'
});
```

### Method Reference
```markdown
### `client.users.create(data)`

Create a new user.

**Parameters:**
- `data.email` (string, required): User email address
- `data.name` (string, required): User full name

**Returns:** Promise<User>

**Throws:**
- `ValidationError`: Invalid email format
- `ApiError`: Server-side error

**Example:**
\`\`\`javascript
const user = await client.users.create({
  email: 'user@example.com',
  name: 'John Doe'
});
\`\`\`
```

## Best Practices

1. **Show real examples**: Use actual request/response data
2. **Include error cases**: Document failure scenarios
3. **Test all code**: Verify examples work
4. **Version everything**: Document breaking changes
5. **Keep it current**: Update with API changes

## Postman Collection

Include exportable collection for testing:

```json
{
  "info": {
    "name": "Example API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/"
  },
  "auth": {
    "type": "bearer",
    "bearer": [{"key": "token", "value": "{{api_key}}"}]
  },
  "item": [
    {
      "name": "Get Users",
      "request": {
        "method": "GET",
        "url": "{{base_url}}/users"
      }
    }
  ]
}
```
