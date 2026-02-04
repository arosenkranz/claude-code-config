# Python MCP Server Implementation Guide

## Quick Reference

### Key Imports
```python
from mcp.server.fastmcp import FastMCP
from pydantic import BaseModel, Field, field_validator, ConfigDict
from typing import Optional, List, Dict, Any
from enum import Enum
import httpx
```

### Server Initialization
```python
mcp = FastMCP("service_mcp")
```

### Tool Registration Pattern
```python
@mcp.tool(name="tool_name", annotations={...})
async def tool_function(params: InputModel) -> str:
    # Implementation
    pass
```

---

## Server Naming Convention

Python MCP servers must follow this naming pattern:
- **Format**: `{service}_mcp` (lowercase with underscores)
- **Examples**: `github_mcp`, `jira_mcp`, `stripe_mcp`

## Tool Implementation

### Tool Naming

Use snake_case with service prefix:
- `slack_send_message` not `send_message`
- `github_create_issue` not `create_issue`

### Complete Tool Example

```python
from pydantic import BaseModel, Field, ConfigDict
from mcp.server.fastmcp import FastMCP
from typing import Optional, List
from enum import Enum

mcp = FastMCP("example_mcp")

class ResponseFormat(str, Enum):
    MARKDOWN = "markdown"
    JSON = "json"

class UserSearchInput(BaseModel):
    model_config = ConfigDict(
        str_strip_whitespace=True,
        validate_assignment=True,
        extra='forbid'
    )

    query: str = Field(
        ...,
        description="Search string to match against names/emails",
        min_length=2,
        max_length=200
    )
    limit: Optional[int] = Field(
        default=20,
        description="Maximum results to return",
        ge=1,
        le=100
    )
    offset: Optional[int] = Field(
        default=0,
        description="Number of results to skip for pagination",
        ge=0
    )
    response_format: ResponseFormat = Field(
        default=ResponseFormat.MARKDOWN,
        description="Output format: 'markdown' or 'json'"
    )

@mcp.tool(
    name="example_search_users",
    annotations={
        "title": "Search Example Users",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": True
    }
)
async def search_users(params: UserSearchInput) -> str:
    '''Search for users in the Example system by name, email, or team.

    Args:
        params (UserSearchInput): Validated input parameters

    Returns:
        str: JSON-formatted response containing search results
    '''
    try:
        data = await _make_api_request(
            "users/search",
            params={"q": params.query, "limit": params.limit, "offset": params.offset}
        )

        response = {
            "total": data["total"],
            "count": len(data["users"]),
            "offset": params.offset,
            "users": data["users"],
            "has_more": data["total"] > params.offset + len(data["users"])
        }

        return json.dumps(response, indent=2)
    except Exception as e:
        return _handle_api_error(e)
```

## Pydantic v2 Key Features

```python
from pydantic import BaseModel, Field, field_validator, ConfigDict

class CreateUserInput(BaseModel):
    model_config = ConfigDict(
        str_strip_whitespace=True,
        validate_assignment=True
    )

    name: str = Field(..., description="User's full name", min_length=1, max_length=100)
    email: str = Field(..., description="User's email", pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        return v.lower()
```

## Error Handling

```python
def _handle_api_error(e: Exception) -> str:
    if isinstance(e, httpx.HTTPStatusError):
        if e.response.status_code == 404:
            return "Error: Resource not found."
        elif e.response.status_code == 403:
            return "Error: Permission denied."
        elif e.response.status_code == 429:
            return "Error: Rate limit exceeded."
        return f"Error: API request failed with status {e.response.status_code}"
    return f"Error: {type(e).__name__}"
```

## Shared Utilities

```python
async def _make_api_request(endpoint: str, method: str = "GET", **kwargs) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.request(
            method,
            f"{API_BASE_URL}/{endpoint}",
            timeout=30.0,
            **kwargs
        )
        response.raise_for_status()
        return response.json()
```

## Quality Checklist

- [ ] All tools have comprehensive docstrings
- [ ] Input validation using Pydantic models
- [ ] Consistent error handling
- [ ] Pagination support for list operations
- [ ] Tool annotations provided
- [ ] Async/await for all I/O operations
- [ ] Full type hints
- [ ] Syntax verified with `python -m py_compile`
