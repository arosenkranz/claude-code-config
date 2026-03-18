---
name: docker-compose-setup
description: Create production-ready Docker Compose configurations for multi-container applications. Supports API, fullstack, microservices, and Datadog-monitored setups with multi-stage builds, health checks, and proper networking.
disable-model-invocation: true
---

# Docker Compose Setup

Create production-ready Docker Compose configurations with best practices for multi-container applications.

## Usage

```
/docker-compose-setup [application-type] [options]
```

## Application Types

* `api` - REST API with database
* `fullstack` - Frontend + Backend + Database
* `microservices` - Multi-service architecture
* `datadog` - Application with Datadog monitoring
* `lab` - Instruqt lab environment

## Process

1. **Environment Analysis**
   * Detect application framework
   * Identify service dependencies
   * Check for existing Docker files
   * Analyze port requirements

1. **Configuration Generation** (see `references/compose-templates.md` for YAML templates)
   * Create optimized Dockerfiles
   * Generate docker-compose.yml
   * Set up environment variables
   * Configure networks and volumes

1. **Service Integration**
   * Database connections
   * Service discovery
   * Health checks
   * Restart policies

1. **Dockerfile Patterns** (see `references/dockerfile-patterns.md` for multi-stage builds)

## Security Best Practices

* Non-root user execution
* Read-only root filesystem where possible
* Secrets management via Docker secrets
* Network isolation
* Security scanning integration

## Options

* `--env` - Environment (development/staging/production)
* `--monitoring` - Include Datadog monitoring
* `--secrets` - Use Docker secrets for sensitive data
* `--scale` - Configure for horizontal scaling
* `--ssl` - Include SSL/TLS configuration

## Examples

```
/docker-compose-setup api --monitoring --env production
/docker-compose-setup fullstack --framework react-node --database postgres
/docker-compose-setup microservices --scale --monitoring
/docker-compose-setup lab --instruqt --datadog
```
