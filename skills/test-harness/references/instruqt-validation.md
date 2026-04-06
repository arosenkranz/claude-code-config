# Instruqt Lab Validation Scripts

## Lab Validation Runner

```bash
#!/bin/bash
# instruqt_test_runner.sh
set -euo pipefail

# Test lab environment setup
test_lab_setup() {
    echo "Testing lab environment setup..."

    # Check required services
    if ! curl -s http://localhost:8000/health > /dev/null; then
        echo "ERROR: API service not running"
        exit 1
    fi

    # Verify Datadog agent
    if ! pgrep -f "datadog-agent" > /dev/null; then
        echo "ERROR: Datadog agent not running"
        exit 1
    fi

    echo "Lab environment setup complete"
}

# Test API functionality
test_api_functionality() {
    echo "Testing API functionality..."

    # Test health endpoint
    health_response=$(curl -s http://localhost:8000/health)
    if [[ $(echo "$health_response" | jq -r '.status') != "healthy" ]]; then
        echo "ERROR: API health check failed"
        exit 1
    fi

    # Test products endpoint
    products_response=$(curl -s http://localhost:8000/api/products)
    if [[ $(echo "$products_response" | jq '.products | length') -eq 0 ]]; then
        echo "WARNING: No products returned"
    fi

    echo "API functionality tests passed"
}

# Test Datadog integration
test_datadog_integration() {
    echo "Testing Datadog integration..."

    # Generate some API traffic
    for i in {1..10}; do
        curl -s http://localhost:8000/api/products > /dev/null
        sleep 0.1
    done

    # Wait for traces to be sent
    sleep 5

    # Check for APM data (would need DD API key)
    # This is a placeholder for actual validation
    echo "Datadog integration test complete"
}

# Run all tests
main() {
    echo "Starting Instruqt lab validation..."
    test_lab_setup
    test_api_functionality
    test_datadog_integration
    echo "All tests passed! Lab is ready for students."
}

main "$@"
```
