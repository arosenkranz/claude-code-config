# Datadog Monitoring for Homelab

Configure comprehensive monitoring for your projects and homelab using Datadog.

## Datadog Agent Setup

### Raspberry Pi Installation

```bash
# Install Datadog Agent on Raspberry Pi (ARM64)
DD_API_KEY=<YOUR_API_KEY> DD_SITE="datadoghq.com" bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"
```

### Docker-Based Agent

```yaml
services:
  datadog-agent:
    image: gcr.io/datadoghq/agent:7
    container_name: datadog-agent
    restart: unless-stopped
    environment:
      - DD_API_KEY=${DD_API_KEY}
      - DD_SITE=datadoghq.com
      - DD_LOGS_ENABLED=true
      - DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true
      - DD_CONTAINER_EXCLUDE="name:datadog-agent"
      - DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true
      - DD_APM_ENABLED=true
      - DD_APM_NON_LOCAL_TRAFFIC=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /proc/:/host/proc/:ro
      - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    ports:
      - "8125:8125/udp"  # DogStatsD
      - "8126:8126"       # APM
    deploy:
      resources:
        limits:
          memory: 512M
```

## Specific Integrations

### Docker Container Monitoring

```yaml
# conf.d/docker.d/conf.yaml
init_config:

instances:
  - url: "unix:///var/run/docker.sock"
    collect_container_size: true
    collect_images_stats: true
```

### Home Assistant Integration

```yaml
# conf.d/http_check.d/conf.yaml
init_config:

instances:
  - name: home-assistant
    url: http://localhost:8123
    timeout: 5
    http_response_status_code: "200"
    tags:
      - service:home-assistant
      - env:homelab
```

### Raspberry Pi System Metrics

```yaml
# conf.d/system_core.d/conf.yaml
init_config:

instances:
  - {}

# CPU temperature custom check
# /etc/datadog-agent/checks.d/pi_temp.py
import subprocess
from datadog_checks.base import AgentCheck

class PiTempCheck(AgentCheck):
    def check(self, instance):
        temp = subprocess.check_output(["vcgencmd", "measure_temp"])
        temp_value = float(temp.decode().split("=")[1].split("'")[0])
        self.gauge("raspberry_pi.cpu.temperature", temp_value)
```

## APM Tracing

### Node.js Application

```javascript
// At the very top of your entry point
const tracer = require('dd-trace').init({
  service: 'my-web-app',
  env: 'homelab',
  version: '1.0.0',
});
```

### Python Application

```python
# At the very top of your entry point
from ddtrace import tracer, patch_all
patch_all()
tracer.configure(
    service='my-python-app',
    env='homelab',
)
```

## Custom Metrics

### DogStatsD (Node.js)

```javascript
const StatsD = require('hot-shots');
const dogstatsd = new StatsD({ host: 'localhost', port: 8125 });

// Count events
dogstatsd.increment('homelab.automation.triggered', 1, { automation: 'lights_off' });

// Gauge values
dogstatsd.gauge('homelab.temperature.living_room', 72.5);

// Histogram for timing
dogstatsd.histogram('homelab.api.response_time', responseTime, { endpoint: '/status' });
```

### DogStatsD (Python)

```python
from datadog import statsd

statsd.increment('homelab.automation.triggered', tags=['automation:lights_off'])
statsd.gauge('homelab.temperature.living_room', 72.5)
statsd.histogram('homelab.api.response_time', response_time, tags=['endpoint:/status'])
```

## Log Aggregation

### Docker Log Collection

The agent automatically collects Docker logs when `DD_LOGS_ENABLED=true` and `DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true`.

### Custom Log Parsing

```yaml
# conf.d/logs.d/conf.yaml
logs:
  - type: file
    path: /var/log/homelab/*.log
    service: homelab
    source: custom
    log_processing_rules:
      - type: multi_line
        name: new_log_start_with_date
        pattern: \d{4}-\d{2}-\d{2}
```

## Monitors and Alerts

### Example Monitors

```bash
# High CPU temperature on Pi
monitor:
  name: "Raspberry Pi CPU Temperature High"
  type: metric alert
  query: "avg(last_5m):avg:raspberry_pi.cpu.temperature > 75"
  message: "CPU temp is {{value}} C on Pi. Consider adding cooling."

# Container restart loop
monitor:
  name: "Docker Container Restart Loop"
  type: metric alert
  query: "change(avg(last_5m),last_5m):avg:docker.containers.running > 0"
  message: "Container restarts detected. Check logs."

# Service down
monitor:
  name: "Home Assistant Down"
  type: service check
  query: '"http_check".over("service:home-assistant").last(3).count_by_status()'
  message: "Home Assistant is not responding."
```

## SLOs (Service Level Objectives)

### Homelab Availability SLO

```yaml
slo:
  name: "Homelab Core Services Availability"
  type: monitor
  description: "Core homelab services should be available 99.5% of the time"
  target_threshold: 99.5
  timeframe: "30d"
  monitor_ids:
    - <home-assistant-monitor-id>
    - <plex-monitor-id>
    - <traefik-monitor-id>
```

## Datadog Query Language (DQL) Examples

```
# Average CPU usage per container
avg:docker.cpu.usage{host:raspberry-pi} by {container_name}

# Memory usage trend
avg:docker.mem.rss{host:raspberry-pi} by {container_name}

# Network traffic
sum:docker.net.bytes_rcvd{host:raspberry-pi} by {container_name}.as_rate()

# Custom homelab metrics
avg:homelab.temperature.living_room{*}
```
