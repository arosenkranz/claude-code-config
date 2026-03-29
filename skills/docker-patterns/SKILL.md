---
name: docker-patterns
description: Docker and Docker Compose reference patterns for local development, container security, networking, volume strategies, and multi-service orchestration. Complements docker-compose-setup (scaffolding) with best-practice reference.
---

# Docker Patterns

Reference guide for Docker and Docker Compose best practices. Use alongside `/docker-compose-setup` for scaffolding.

## When to Activate

- Setting up Docker Compose for local development
- Designing multi-container architectures
- Troubleshooting container networking or volume issues
- Reviewing Dockerfiles for security and size
- Homelab stack work on Raspberry Pi 5

## Multi-Stage Dockerfile (Dev + Production)

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

## Compose Patterns

### Service Discovery
Services in the same Compose network resolve by service name:
```
postgres://postgres:postgres@db:5432/app_dev
redis://redis:6379/0
```

### Network Isolation
```yaml
services:
  frontend:
    networks: [frontend-net]
  api:
    networks: [frontend-net, backend-net]
  db:
    networks: [backend-net]       # Only reachable from api
```

### Volume Strategies
```yaml
volumes:
  - .:/app                        # Bind mount for hot reload
  - /app/node_modules             # Protect container deps from host
  - pgdata:/var/lib/postgresql/data  # Named volume for persistence
```

### Override Files
```bash
docker compose up                  # Auto-loads override (dev)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d  # Production
```

## Container Security Checklist

- Use specific image tags (never `:latest`)
- Run as non-root user
- `security_opt: [no-new-privileges:true]`
- `read_only: true` with tmpfs for writable dirs
- `cap_drop: [ALL]`, add back only what's needed
- Never put secrets in image layers — use `.env` files or Docker secrets
- Expose ports to `127.0.0.1` only when not needed on network

## Raspberry Pi / ARM64 Considerations

- Verify images support `linux/arm64` (check Docker Hub tags)
- Use Alpine-based images for lower memory footprint
- Set memory limits: `deploy.resources.limits.memory: 256M`
- Use `platform: linux/arm64` in compose to catch mismatches early
- Monitor with Datadog Agent (already running on Pi 5)

## Debugging Quick Reference

```bash
docker compose logs -f app           # Follow logs
docker compose exec app sh           # Shell in
docker compose exec db psql -U postgres
docker compose ps                     # Running services
docker stats                          # Resource usage
docker compose down -v                # Stop + remove volumes (DESTRUCTIVE)
docker system prune                   # Clean unused images
```

## Anti-Patterns

- Running compose in production without orchestration
- Storing data in containers without volumes
- Running as root
- One giant container with all services
- Putting secrets in docker-compose.yml
