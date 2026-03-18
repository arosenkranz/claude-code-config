---
name: documenting-architectures
description: Create comprehensive technical documentation with clear structure, visual aids, and progressive disclosure patterns. Use when documenting systems, writing technical guides, creating architecture docs, or explaining complex codebases.
---

# Architecture Documentation

Create clear, comprehensive technical documentation that explains complex systems.

## Documentation Structure

```markdown
# [System Name] Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Getting Started](#getting-started)
4. [Core Concepts](#core-concepts)
5. [API Reference](#api-reference)
6. [Deployment](#deployment)
7. [Troubleshooting](#troubleshooting)

## Overview

### Purpose
[System description and business value]

### Key Features
* Feature 1: [Description and value]
* Feature 2: [Description and value]
* Feature 3: [Description and value]

### Technology Stack
* **Language**: Node.js 18
* **Framework**: Express 4.x
* **Database**: PostgreSQL 15
* **Cache**: Redis 7
* **Queue**: RabbitMQ 3.x

## Architecture

### High-Level Architecture

\`\`\`
┌─────────┐      ┌──────────┐      ┌──────────┐
│ Client  │─────▶│ API      │─────▶│ Database │
│         │◀─────│ Gateway  │◀─────│          │
└─────────┘      └──────────┘      └──────────┘
                      │
                      ▼
                 ┌──────────┐
                 │  Cache   │
                 └──────────┘
\`\`\`

### Component Overview

#### API Gateway
* **Responsibility**: Route requests, authenticate users, rate limit
* **Technology**: Express + custom middleware
* **Scaling**: Horizontal (3-10 instances)
* **Dependencies**: Auth service, rate limiter

#### Business Logic Layer
* **Responsibility**: Core business rules and workflows
* **Technology**: TypeScript classes with dependency injection
* **Patterns**: Service layer, repository pattern
* **Testing**: 90% unit test coverage

#### Data Layer
* **Responsibility**: Persist and retrieve data
* **Technology**: PostgreSQL with TypeORM
* **Patterns**: Repository pattern, migrations
* **Backup**: Daily snapshots, 30-day retention
```

## Document Types

### 1. System Overview

Purpose: High-level understanding for new team members

```markdown
# System Overview

## What This System Does

[Product name] is a [type of system] that [primary purpose].
It helps [target users] to [main benefit].

## Key Capabilities

1. **User Management**: Create, update, and authenticate users
2. **Data Processing**: Transform and validate incoming data
3. **Reporting**: Generate analytics and export reports

## System Boundaries

### What's Included
* User authentication and authorization
* Data validation and transformation
* Report generation

### What's NOT Included
* Payment processing (handled by Stripe)
* Email delivery (handled by SendGrid)
* File storage (handled by S3)

## Target Audience

* **Primary**: Backend developers maintaining the system
* **Secondary**: DevOps engineers deploying the system
* **Prerequisites**:
  * Familiarity with Node.js and TypeScript
  * Understanding of REST APIs
  * Basic Docker knowledge
```

### 2. Architecture Decision Records (ADR)

```markdown
# ADR-001: Use PostgreSQL for Primary Database

## Status
Accepted

## Context
Need a database solution for storing user data and transactional records. Requirements:
* ACID compliance
* Complex queries with joins
* JSON support for flexible schemas
* Strong ecosystem and tooling

## Decision
Use PostgreSQL 15 as the primary database.

## Consequences

### Positive
* Strong ACID guarantees
* Excellent performance for our query patterns
* Rich JSON support for flexible data
* Great tooling and community support

### Negative
* Requires careful connection pool management
* More complex to horizontally scale than NoSQL
* Need expertise in query optimization

### Neutral
* Must set up replication for HA
* Regular maintenance windows for updates

## Alternatives Considered

**MongoDB**: Rejected - our data is highly relational
**MySQL**: Rejected - less robust JSON support
**DynamoDB**: Rejected - query patterns don't fit key-value model
```

### 3. Data Flow Documentation

```markdown
## User Registration Flow

1. **Client** sends POST to `/api/users/register`
   ```json
   {
     "email": "user@example.com",
     "password": "SecurePass123",
     "name": "John Doe"
   }
   ```

2. **API Gateway** validates request format
   * Checks required fields present
   * Validates email format
   * Checks password strength

3. **Auth Service** verifies email not already registered
   ```sql
   SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)
   ```

4. **User Service** creates user record
   * Hashes password with bcrypt (10 rounds)
   * Generates UUID for user ID
   * Stores in database

5. **Email Service** sends verification email
   * Generates verification token (JWT, 24h expiry)
   * Queues email via RabbitMQ
   * Email worker sends via SendGrid

6. **Response** returned to client
   ```json
   {
     "id": "123e4567-e89b-12d3",
     "email": "user@example.com",
     "name": "John Doe",
     "status": "pending_verification"
   }
   ```
```

### 4. Component Documentation

```markdown
## User Service

### Responsibility
Manage user lifecycle: creation, updates, deletion, and profile management.

### Public Interface

\`\`\`typescript
interface UserService {
  createUser(data: CreateUserDto): Promise<User>;
  getUser(id: string): Promise<User | null>;
  updateUser(id: string, data: UpdateUserDto): Promise<User>;
  deleteUser(id: string): Promise<void>;
}
\`\`\`

### Dependencies
* **Database**: PostgreSQL via TypeORM repository
* **Cache**: Redis for user session data
* **Queue**: RabbitMQ for async operations

### Configuration
\`\`\`typescript
{
  maxLoginAttempts: 5,
  lockoutDuration: 900, // 15 minutes
  sessionTimeout: 3600, // 1 hour
  passwordMinLength: 12
}
\`\`\`

### Error Handling
* **ValidationError**: Invalid input data
* **NotFoundError**: User doesn't exist
* **ConflictError**: Email already registered
* **RateLimitError**: Too many requests

### Example Usage
\`\`\`typescript
const userService = new UserService(database, cache, queue);

try {
  const user = await userService.createUser({
    email: 'user@example.com',
    password: 'SecurePass123',
    name: 'John Doe'
  });
  console.log(`Created user: ${user.id}`);
} catch (error) {
  if (error instanceof ConflictError) {
    console.error('Email already registered');
  }
}
\`\`\`
```

## Visual Documentation

### Architecture Diagrams

Use ASCII art for simple diagrams:

```
Request Flow:
┌────────┐    ┌─────────┐    ┌──────────┐    ┌──────────┐
│ Client │───▶│   API   │───▶│ Business │───▶│ Database │
│        │◀───│ Gateway │◀───│  Logic   │◀───│          │
└────────┘    └─────────┘    └──────────┘    └──────────┘
```

For complex diagrams, reference external tools:

```markdown
## System Architecture

See [architecture.png](./diagrams/architecture.png) for detailed component diagram.

**Key components:**
* API Gateway handles all incoming requests
* Business Logic layer contains core services
* Data Layer manages persistence
* Cache Layer improves performance
```

### Sequence Diagrams

```markdown
## Authentication Sequence

\`\`\`
User          API          AuthService      Database
 │             │               │               │
 ├─Login──────▶│               │               │
 │             ├──Verify──────▶│               │
 │             │               ├──Query────────▶│
 │             │               │◀──User Data───┤
 │             │◀──Token───────┤               │
 │◀──200 OK───┤               │               │
\`\`\`
```

## Code Examples

### Provide Context

```javascript
// ❌ BAD: No context
app.use(middleware);

// ✅ GOOD: Explain what and why
// Authentication middleware validates JWT tokens
// and attaches user object to request
app.use(authMiddleware);

// Rate limiting prevents abuse (100 req/min per IP)
app.use(rateLimitMiddleware);
```

### Show Complete Examples

```javascript
// ✅ Complete, runnable example
import express from 'express';
import { createUserHandler } from './handlers/users.js';
import { authenticate } from './middleware/auth.js';

const app = express();
app.use(express.json());

// Create user endpoint with authentication
app.post('/api/users',
  authenticate,      // Verify JWT token
  createUserHandler  // Handle user creation
);

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

## Progressive Disclosure

### Main Documentation

Keep main files focused:

```markdown
# User Management

## Quick Start

Create a new user:
\`\`\`typescript
const user = await userService.createUser(data);
\`\`\`

## Common Operations

* [Create User](#create-user)
* [Update Profile](#update-profile)
* [Reset Password](#reset-password)

## Advanced Topics

For detailed information, see:
* [Password Policies](./docs/password-policies.md)
* [Email Verification](./docs/email-verification.md)
* [Account Recovery](./docs/account-recovery.md)
```

### Detail Pages

Provide depth in separate files:

```markdown
# Password Policies

## Requirements

Passwords must meet these criteria:
* Minimum 12 characters
* At least one uppercase letter
* At least one lowercase letter
* At least one number
* At least one special character

## Implementation

\`\`\`typescript
function validatePassword(password: string): boolean {
  const minLength = 12;
  const hasUpperCase = /[A-Z]/.test(password);
  const hasLowerCase = /[a-z]/.test(password);
  const hasNumber = /\d/.test(password);
  const hasSpecial = /[!@#$%^&*]/.test(password);

  return password.length >= minLength &&
         hasUpperCase &&
         hasLowerCase &&
         hasNumber &&
         hasSpecial;
}
\`\`\`

## Security Considerations

* Passwords are hashed with bcrypt (10 rounds)
* Failed attempts trigger rate limiting
* No password hints or recovery questions
```

## Quality Checklist

- [ ] Can a new developer understand the system?
- [ ] Are all design decisions explained?
- [ ] Do examples actually work?
- [ ] Is the deployment process clear?
- [ ] Are common issues addressed?
- [ ] Is the documentation maintainable?
- [ ] Are diagrams clear and up-to-date?
- [ ] Are external dependencies documented?
- [ ] Is the versioning strategy clear?
- [ ] Are breaking changes highlighted?
