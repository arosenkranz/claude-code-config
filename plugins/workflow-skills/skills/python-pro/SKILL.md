---
name: python-pro
description: Write idiomatic Python code with advanced features like decorators, generators, context managers, and async/await. Use when writing Python code, refactoring Python, optimizing Python performance, implementing design patterns in Python, or setting up pytest testing.
---

# Python Pro

Guidelines for writing clean, performant, and idiomatic Python code.

## Core Principles

1. **Pythonic code** - Follow PEP 8, use Python idioms
2. **Composition over inheritance** - Prefer mixins and protocols
3. **Explicit is better than implicit** - Clear error handling
4. **Generators for efficiency** - Lazy evaluation for large datasets
5. **Type hints everywhere** - Enable static analysis with mypy

## Code Patterns

### Type Hints (Python 3.10+)

```python
from typing import Protocol, TypeVar, Generic
from collections.abc import Callable, Iterator

T = TypeVar('T')

class Repository(Protocol[T]):
    def get(self, id: str) -> T | None: ...
    def save(self, item: T) -> None: ...

def process_items[T](items: list[T], fn: Callable[[T], T]) -> Iterator[T]:
    for item in items:
        yield fn(item)
```

### Context Managers

```python
from contextlib import contextmanager
from typing import Generator

@contextmanager
def managed_resource(name: str) -> Generator[Resource, None, None]:
    resource = Resource(name)
    try:
        yield resource
    finally:
        resource.cleanup()
```

### Decorators with Proper Typing

```python
from functools import wraps
from typing import ParamSpec, TypeVar, Callable

P = ParamSpec('P')
R = TypeVar('R')

def retry(max_attempts: int = 3) -> Callable[[Callable[P, R]], Callable[P, R]]:
    def decorator(func: Callable[P, R]) -> Callable[P, R]:
        @wraps(func)
        def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
            raise RuntimeError("Unreachable")
        return wrapper
    return decorator
```

### Async Patterns

```python
import asyncio
from typing import AsyncIterator

async def fetch_all[T](urls: list[str], parse: Callable[[str], T]) -> list[T]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_one(session, url, parse) for url in urls]
        return await asyncio.gather(*tasks)

async def stream_data() -> AsyncIterator[bytes]:
    async with aiofiles.open('large.csv', 'rb') as f:
        async for chunk in f:
            yield chunk
```

### Custom Exceptions

```python
from dataclasses import dataclass

@dataclass
class ValidationError(Exception):
    field: str
    message: str
    value: object = None

    def __str__(self) -> str:
        return f"{self.field}: {self.message} (got {self.value!r})"
```

## Testing with Pytest

### Fixtures and Parametrization

```python
import pytest
from typing import Generator

@pytest.fixture
def db_session() -> Generator[Session, None, None]:
    session = Session()
    yield session
    session.rollback()

@pytest.fixture
def sample_user(db_session: Session) -> User:
    user = User(name="test", email="test@example.com")
    db_session.add(user)
    return user

@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("World", "WORLD"),
    ("", ""),
])
def test_uppercase(input: str, expected: str) -> None:
    assert input.upper() == expected
```

### Async Testing

```python
import pytest

@pytest.mark.asyncio
async def test_fetch_data() -> None:
    result = await fetch_data("https://api.example.com")
    assert result.status == "success"
```

## Project Structure

```
project/
├── pyproject.toml          # Modern Python config
├── src/
│   └── package/
│       ├── __init__.py
│       ├── py.typed        # PEP 561 marker
│       ├── domain/         # Business logic
│       ├── services/       # Application services
│       └── adapters/       # External integrations
├── tests/
│   ├── conftest.py         # Shared fixtures
│   ├── unit/
│   └── integration/
└── .python-version         # pyenv version
```

## pyproject.toml Template

```toml
[project]
name = "myproject"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = []

[project.optional-dependencies]
dev = ["pytest>=8.0", "mypy>=1.8", "ruff>=0.2"]

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]

[tool.mypy]
strict = true
python_version = "3.11"

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
```

## Performance Tips

- Use `__slots__` for data classes with many instances
- Prefer `dict.get()` over `try/except KeyError`
- Use `itertools` for efficient iteration
- Profile with `cProfile` and `line_profiler`
- Use `functools.lru_cache` for expensive pure functions

## Common Anti-Patterns to Avoid

- Mutable default arguments: `def f(items=[])` → `def f(items=None)`
- Bare `except:` clauses → Always specify exception type
- Using `type()` for comparisons → Use `isinstance()`
- String concatenation in loops → Use `"".join()` or f-strings
- Ignoring return values → Handle or explicitly discard with `_`
