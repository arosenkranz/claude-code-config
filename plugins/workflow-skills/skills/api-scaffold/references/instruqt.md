# Instruqt Integration Scripts

## Challenge Setup Script

```bash
#!/bin/bash
set -euxo pipefail

# Install dependencies
pip install -r requirements.txt

# Set up database
python setup_db.py

# Start services
docker-compose up -d

# Wait for services to be ready
until curl -s http://localhost:8000/health; do
  echo "Waiting for API to be ready..."
  sleep 2
done

echo "API scaffold ready for training!"
```
