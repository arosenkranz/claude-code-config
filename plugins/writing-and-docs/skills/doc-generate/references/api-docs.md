# API Documentation Patterns

## OpenAPI Generator

```python
import ast
import json
from typing import Dict, List, Any
from pathlib import Path

class APIDocumentationGenerator:
    def __init__(self, source_path: str):
        self.source_path = Path(source_path)
        self.endpoints = []
        self.schemas = {}

    def parse_fastapi_app(self, file_path: str) -> Dict[str, Any]:
        """Parse FastAPI application for endpoints"""
        with open(file_path, 'r') as file:
            tree = ast.parse(file.read())

        for node in ast.walk(tree):
            if isinstance(node, ast.FunctionDef):
                # Look for route decorators
                for decorator in node.decorator_list:
                    if self.is_route_decorator(decorator):
                        endpoint_info = self.extract_endpoint_info(node, decorator)
                        self.endpoints.append(endpoint_info)

        return {"endpoints": self.endpoints}

    def generate_openapi_spec(self) -> Dict[str, Any]:
        """Generate OpenAPI specification"""
        spec = {
            "openapi": "3.0.3",
            "info": {
                "title": "Training API",
                "version": "1.0.0",
                "description": "API for Datadog training curriculum"
            },
            "paths": {}
        }

        for endpoint in self.endpoints:
            path = endpoint["path"]
            method = endpoint["method"].lower()

            spec["paths"][path] = {
                method: {
                    "summary": endpoint["summary"],
                    "description": endpoint["description"],
                    "responses": {
                        "200": {
                            "description": "Successful response",
                            "content": {
                                "application/json": {
                                    "schema": endpoint.get("response_schema", {})
                                }
                            }
                        }
                    }
                }
            }

        return spec
```

## README Generator

```python
class ReadmeGenerator:
    def __init__(self, project_info: Dict[str, Any]):
        self.info = project_info

    def generate_readme(self) -> str:
        """Generate comprehensive README"""
        readme = f"""
# {self.info['name']}

{self.info['description']}

## Features
{self.format_features()}

## Quick Start
{self.generate_quick_start()}

## API Documentation
{self.generate_api_docs_section()}

## Development
{self.generate_dev_section()}

## Testing
{self.generate_testing_section()}

## Deployment
{self.generate_deployment_section()}

## Monitoring
{self.generate_monitoring_section()}

## Contributing
{self.generate_contributing_section()}

## License
{self.info.get('license', 'MIT')}
        """
        return readme.strip()
```

## GitHub Actions for Docs

```yaml
name: Generate Documentation

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  docs:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Generate API Documentation
      run: |
        python scripts/generate_docs.py --type api --output docs/api/

    - name: Generate Architecture Docs
      run: |
        python scripts/generate_docs.py --type architecture --output docs/architecture/

    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      if: github.ref == 'refs/heads/main'
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./docs
```
