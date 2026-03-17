---
name: linting-technical-writing
description: Analyze technical documentation for clarity, conciseness, and effectiveness using Google Technical Writing principles. Use when reviewing documentation, checking writing quality, improving docs, or providing writing feedback.
---

# Technical Writing Linter

Apply Google's Technical Writing principles to analyze and improve documentation.

## Analysis Process

1. **Parse Document**: Break into sections, paragraphs, sentences
2. **Categorize Issues**: Group by type and severity
3. **Generate Fixes**: Create specific suggestions
4. **Present Results**: Organized by priority

## Severity Levels

### High Severity (Must Fix)
- Undefined critical terms
- Severely ambiguous pronouns
- Missing document scope/audience
- Incorrect technical information

### Medium Severity (Should Fix)
- Passive voice in instructions
- Long, complex sentences
- Non-parallel list structures
- Inconsistent terminology

### Low Severity (Optional)
- Weak verb usage
- Minor style violations
- Slightly long paragraphs
- Stylistic preferences

## Core Linting Rules

### 1. Words and Terminology

**Check for undefined terms:**
```markdown
❌ BAD: "The REST API provides..."
✅ GOOD: "The REST (Representational State Transfer) API provides..."
```

**Verify consistent terminology:**
```markdown
❌ BAD: Mix "API endpoint", "URL", "API route", "path"
✅ GOOD: Always use "API endpoint"
```

**Acronym usage:**
```markdown
❌ BAD: "Use JWT for authentication"
✅ GOOD: "Use JWT (JSON Web Token) for authentication"
```

**Pronoun clarity:**
```markdown
❌ BAD: "When the server receives the request, it processes it."
       (Which "it"? Server or request?)
✅ GOOD: "When the server receives the request, the server processes the request."
```

### 2. Active Voice

**Identify passive voice:**
```markdown
❌ PASSIVE: "The configuration file is loaded by the system."
✅ ACTIVE: "The system loads the configuration file."

❌ PASSIVE: "Errors are handled by the middleware."
✅ ACTIVE: "The middleware handles errors."
```

### 3. Clear Sentences

**Weak verbs:**
```markdown
❌ WEAK: "There is a function that validates input."
✅ STRONG: "The validateInput function validates input."

❌ WEAK: "The error occurs when the timeout is exceeded."
✅ STRONG: "The request times out after 30 seconds."
```

**Subjective adjectives:**
```markdown
❌ VAGUE: "The API is blazingly fast."
✅ SPECIFIC: "The API responds in under 100ms for 95% of requests."

❌ VAGUE: "Simply install the package."
✅ CLEAR: "Install the package with npm install package-name."
```

### 4. Sentence Length

**Long sentences:**
```markdown
❌ TOO LONG (45 words):
"The API endpoint accepts JSON payloads that contain user data including name, email, address, phone number, and optional preferences which are then processed by the backend service and stored in the database after validation."

✅ BETTER (split into 3 sentences):
"The API endpoint accepts JSON payloads containing user data. Required fields include name, email, address, and phone number. Optional preferences can also be included."
```

### 5. Lists and Tables

**Parallel structure:**
```markdown
❌ NOT PARALLEL:
* Create a new file
* The user should configure settings
* Restart the server

✅ PARALLEL:
* Create a new file
* Configure settings
* Restart the server
```

**List introduction:**
```markdown
❌ NO INTRODUCTION:
* Item 1
* Item 2

✅ WITH INTRODUCTION:
Follow these steps:
* Item 1
* Item 2
```

**Numbered vs bulleted:**
```markdown
✅ NUMBERED (sequential):
1. Install dependencies
1. Configure the application
1. Start the server

✅ BULLETED (unordered):
* Supports JSON format
* Handles authentication
* Includes error logging
```

### 6. Paragraphs

**Opening sentences:**
```markdown
❌ WEAK OPENING:
"There are several things to consider. Authentication is important..."

✅ STRONG OPENING:
"Authentication protects your API from unauthorized access."
```

**Single focus:**
```markdown
❌ MULTIPLE TOPICS:
"The API uses JWT tokens for authentication. The database stores user data in PostgreSQL. Error messages follow RFC 7807 format."

✅ SINGLE TOPIC:
"The API uses JWT tokens for authentication. Tokens expire after 24 hours. Refresh tokens using the /auth/refresh endpoint."
```

**Paragraph length:**
- Too long: > 7 sentences
- Too short: 1 sentence
- Ideal: 3-5 sentences

### 7. Audience Awareness

**Define prerequisites:**
```markdown
❌ ASSUMES KNOWLEDGE:
"Configure your ingress controller."

✅ STATES PREREQUISITES:
"**Prerequisites**: Basic Kubernetes knowledge and kubectl installed.

Configure your ingress controller:"
```

**Avoid idioms:**
```markdown
❌ CULTURAL IDIOM: "This feature is the bee's knees."
✅ CLEAR: "This feature significantly improves performance."
```

### 8. Document Structure

**Scope definition:**
```markdown
## What This Guide Covers

This guide explains how to:
* Install the application
* Configure basic settings
* Deploy to production

This guide does NOT cover:
* Advanced customization
* Troubleshooting
* Performance tuning
```

**Audience declaration:**
```markdown
## Who This Is For

**Target audience**: Backend developers familiar with Node.js

**Prerequisites**:
* Node.js 18+ installed
* Basic understanding of REST APIs
* Command line experience
```

## Output Format

### Issue Report

```markdown
# Technical Writing Lint Report

## Summary
- Total issues: 23
- High severity: 3
- Medium severity: 15
- Low severity: 5

## High Severity Issues

### 1. Undefined Technical Term (Line 8)
**Issue**: Term "REST" used without definition
**Current**: "The REST API provides..."
**Suggested**: "The REST (Representational State Transfer) API provides..."

## Medium Severity Issues

### Category: Passive Voice (8 issues)

**Line 15:**
**Current**: "The configuration file is loaded by the system."
**Suggested**: "The system loads the configuration file."

**Line 22:**
**Current**: "Errors are handled by the middleware."
**Suggested**: "The middleware handles errors."

### Category: Long Sentences (4 issues)

**Line 45 (62 words):**
**Current**: "The API endpoint accepts JSON payloads that contain user data including name, email, address, phone number, and optional preferences which are processed by the backend service and stored in the database after validation completes successfully."

**Suggested**:
"The API endpoint accepts JSON payloads containing user data. Required fields include name, email, address, and phone number. Optional preferences can also be included. The backend validates and stores all data."
```

## Safe Auto-Fixes

These changes can be applied automatically:

1. **Passive to active voice** (when subject is clear)
2. **Remove "There is/are" constructions**
3. **Fix list punctuation consistency**
4. **Correct obvious typos**
5. **Expand acronyms on first use**

## Feedback Best Practices

1. **Be specific**: Point to exact line numbers
2. **Show examples**: Provide before/after
3. **Explain why**: Clarify the improvement
4. **Prioritize**: Focus on high-impact changes first
5. **Be constructive**: Frame as improvements, not criticism
