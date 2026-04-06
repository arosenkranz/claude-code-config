# FastAPI Template

## Application Template

```python
from fastapi import FastAPI, HTTPException
from ddtrace import tracer
import logging
import uvicorn

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(name)s %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Training API", version="1.0.0")

@app.middleware("http")
async def add_datadog_correlation(request, call_next):
    """Add Datadog correlation IDs to logs"""
    span = tracer.current_span()
    if span:
        logger.info(f"Request {request.url.path}", extra={
            'dd.trace_id': span.trace_id,
            'dd.span_id': span.span_id
        })
    return await call_next(request)

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    return {"status": "healthy", "service": "training-api"}

@app.get("/api/products")
@tracer.wrap("get_products")
async def get_products():
    """Get products with APM tracing"""
    with tracer.trace("database.query") as span:
        span.set_tag("query.type", "select")
        # Simulate database call
        products = [
            {"id": 1, "name": "Widget", "price": 9.99},
            {"id": 2, "name": "Gadget", "price": 19.99}
        ]

    logger.info(f"Retrieved {len(products)} products")
    return {"products": products}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

## Docker Configuration

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser
USER appuser

EXPOSE 8000

CMD ["python", "main.py"]
```

## Docker Compose with Services

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DD_SERVICE=training-api
      - DD_ENV=lab
      - DD_VERSION=1.0.0
      - DD_AGENT_HOST=datadog-agent
    depends_on:
      - postgres
      - redis
      - datadog-agent

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: training
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

  datadog-agent:
    image: gcr.io/datadoghq/agent:7
    environment:
      - DD_API_KEY=${DD_API_KEY}
      - DD_APM_ENABLED=true
      - DD_LOGS_ENABLED=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /proc/:/host/proc/:ro
      - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro

volumes:
  postgres_data:
  redis_data:
```
