---
name: docker
description: Docker and Docker Compose for local dev, homelab (Raspberry Pi 5 / ARM64), and production. Scaffolds production-ready Compose configs via /docker, and serves as a best-practice reference for container security, networking, volumes, multi-stage builds, and debugging. Use when writing Dockerfiles, setting up Compose, troubleshooting containers, or doing homelab stack work.
---

# Docker

Two things in one skill: a **scaffolding command** that generates production-ready Docker Compose setups, and a **reference** of container best practices to apply when reasoning about any Docker work.

## When to activate

- Setting up Docker Compose for local development or a homelab stack
- Designing multi-container architectures
- Troubleshooting container networking or volume issues
- Reviewing Dockerfiles for security and image size
- Raspberry Pi 5 / ARM64 homelab work

---

## Scaffolding — `/docker`

```
/docker [application-type] [options]
```

### Application types

* `api` — REST API with database
* `fullstack` — Frontend + Backend + Database
* `microservices` — Multi-service architecture
* `datadog` — Application with Datadog monitoring
* `homelab` — Single-host stack tuned for Pi 5 / ARM64

### Process

1. **Environment analysis** — detect framework, identify service dependencies, check for existing Docker files, analyze port requirements.
2. **Configuration generation** (see `references/compose-templates.md` for YAML templates) — optimized Dockerfiles, `docker-compose.yml`, environment variables, networks and volumes.
3. **Service integration** — database connections, service discovery, health checks, restart policies.
4. **Dockerfile patterns** — see `references/dockerfile-patterns.md` for multi-stage builds.

### Options

* `--env` — Environment (development/staging/production)
* `--monitoring` — Include Datadog monitoring
* `--secrets` — Use Docker secrets for sensitive data
* `--scale` — Configure for horizontal scaling
* `--ssl` — Include SSL/TLS configuration

### Examples

```
/docker api --monitoring --env production
/docker fullstack --framework react-node --database postgres
/docker microservices --scale --monitoring
/docker homelab --env production
```

---

## Reference patterns

### Multi-stage Dockerfile (dev + production)

```dockerfile
# Stage: dependencies
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Stage: dev (hot reload)
FROM node:22-alpine AS dev
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Stage: production (minimal image)
FROM node:22-alpine AS production
WORKDIR /app
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001
USER appuser
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
ENV NODE_ENV=production
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "dist/server.js"]
```

### Service discovery

Services in the same Compose network resolve by service name:
```
postgres://postgres:postgres@db:5432/app_dev
redis://redis:6379/0
```

### Network isolation

```yaml
services:
  frontend:
    networks: [frontend-net]
  api:
    networks: [frontend-net, backend-net]
  db:
    networks: [backend-net]       # Only reachable from api
```

### Volume strategies

```yaml
volumes:
  - .:/app                        # Bind mount for hot reload
  - /app/node_modules             # Protect container deps from host
  - pgdata:/var/lib/postgresql/data  # Named volume for persistence
```

### Override files

```bash
docker compose up                  # Auto-loads override (dev)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d  # Production
```

## Container security checklist

- Use specific image tags (never `:latest`)
- Run as non-root user
- `security_opt: [no-new-privileges:true]`
- `read_only: true` with tmpfs for writable dirs
- `cap_drop: [ALL]`, add back only what's needed
- Never put secrets in image layers — use `.env` files or Docker secrets
- Expose ports to `127.0.0.1` only when not needed on the network
- Run security scanning in CI

## Raspberry Pi / ARM64 considerations

- Verify images support `linux/arm64` (check Docker Hub tags)
- Use Alpine-based images for lower memory footprint
- Set memory limits: `deploy.resources.limits.memory: 256M`
- Use `platform: linux/arm64` in compose to catch mismatches early
- Monitor with the Datadog Agent (already running on Pi 5)

## Debugging quick reference

```bash
docker compose logs -f app           # Follow logs
docker compose exec app sh           # Shell in
docker compose exec db psql -U postgres
docker compose ps                     # Running services
docker stats                          # Resource usage
docker compose down -v                # Stop + remove volumes (DESTRUCTIVE)
docker system prune                   # Clean unused images
```

## Anti-patterns

- Running compose in production without orchestration
- Storing data in containers without volumes
- Running as root
- One giant container with all services
- Putting secrets in `docker-compose.yml`
