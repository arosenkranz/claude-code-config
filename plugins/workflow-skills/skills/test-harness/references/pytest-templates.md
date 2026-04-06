# pytest Templates

## conftest.py

```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from app.main import app
from app.database import get_db

# Test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})

@pytest.fixture
def client():
    """Test client fixture"""
    with TestClient(app) as c:
        yield c

@pytest.fixture
def test_db():
    """Test database fixture"""
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def sample_products():
    """Sample test data"""
    return [
        {"id": 1, "name": "Test Widget", "price": 9.99},
        {"id": 2, "name": "Test Gadget", "price": 19.99}
    ]
```

## test_api.py

```python
def test_health_check(client):
    """Test health endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_get_products(client, sample_products):
    """Test products endpoint"""
    response = client.get("/api/products")
    assert response.status_code == 200
    data = response.json()
    assert "products" in data
    assert len(data["products"]) >= 0

def test_create_product(client):
    """Test product creation"""
    product_data = {
        "name": "New Product",
        "price": 29.99,
        "description": "Test product"
    }

    response = client.post("/api/products", json=product_data)
    assert response.status_code == 201

    data = response.json()
    assert data["name"] == product_data["name"]
    assert data["price"] == product_data["price"]

def test_product_validation(client):
    """Test input validation"""
    invalid_data = {"name": "", "price": -10}

    response = client.post("/api/products", json=invalid_data)
    assert response.status_code == 422
```

## Performance Testing (locustfile.py)

```python
from locust import HttpUser, task, between

class APIUser(HttpUser):
    wait_time = between(1, 2)
    host = "http://localhost:8000"

    def on_start(self):
        """Called when user starts"""
        response = self.client.get("/health")
        if response.status_code != 200:
            print("API not healthy!")

    @task(3)
    def get_products(self):
        """Get products - most common operation"""
        self.client.get("/api/products")

    @task(1)
    def create_product(self):
        """Create product - less common operation"""
        product_data = {
            "name": f"Test Product {self.environment.runner.user_count}",
            "price": 19.99,
            "description": "Load test product"
        }
        self.client.post("/api/products", json=product_data)

    @task(2)
    def get_specific_product(self):
        """Get specific product"""
        product_id = 1
        self.client.get(f"/api/products/{product_id}")
```

## GitHub Actions Integration

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest pytest-cov

    - name: Run tests
      run: |
        pytest --cov=app --cov-report=xml

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
```
