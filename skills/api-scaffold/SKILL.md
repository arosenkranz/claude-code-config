---
name: api-scaffold
description: Generate production-ready API scaffolds with Datadog instrumentation. Supports FastAPI, Express/TypeScript, Flask, and Spring Boot. Use when creating new API projects for curriculum, training demos, or lab environments.
disable-model-invocation: true
---

# API Scaffold Generator

Generate production-ready API scaffolds for Instruqt labs and training demos with proper instrumentation.

## Usage

```
/api-scaffold [api-name] [framework] [options]
```

## Frameworks

* `fastapi` - Python FastAPI with async support (see `references/fastapi.md` for template)
* `express` - Node.js Express with TypeScript (see `references/express.md` for template)
* `flask` - Python Flask for simple demos
* `spring` - Java Spring Boot for enterprise examples

## Process

1. **Framework Analysis**
   * Select optimal framework for curriculum needs
   * Consider learning objectives and complexity
   * Ensure framework aligns with target audience

1. **Project Structure**
   * Create comprehensive API structure
   * Include authentication and validation
   * Add proper error handling
   * Implement logging and monitoring

1. **Instrumentation Setup**
   * Integrate Datadog APM
   * Add custom metrics
   * Configure log correlation
   * Set up health checks

1. **Instruqt Integration** (see `references/instruqt.md` for scripts)
   * Generate challenge setup scripts
   * Configure lab environment
   * Set up validation checks

## Options

* `--database` - Database type (postgres/mysql/sqlite)
* `--auth` - Authentication method (jwt/oauth/basic)
* `--cache` - Caching layer (redis/memcached)
* `--testing` - Include test framework setup
* `--instruqt` - Generate Instruqt-specific configurations

## Examples

```
/api-scaffold ecommerce-api fastapi --database postgres --auth jwt --cache redis
/api-scaffold demo-service express --testing --instruqt
/api-scaffold simple-api flask --database sqlite --auth basic
```

## Training Features

* Realistic business logic for learning scenarios
* Built-in performance bottlenecks for optimization exercises
* Error conditions for troubleshooting practice
* Security vulnerabilities for security training
* Comprehensive logging for log analysis labs
