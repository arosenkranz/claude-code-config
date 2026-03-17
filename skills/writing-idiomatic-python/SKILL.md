---
name: writing-idiomatic-python
description: Write clean, Pythonic code with type hints, decorators, and comprehensive testing. Use when writing Python code, implementing Python patterns, using async/await, working with decorators, or setting up pytest tests.
---

> **[DEPRECATED]** Candidate for removal (2026-03-03). If unused by 2026-03-17, delete this skill.

# Idiomatic Python

Write clean, performant, Pythonic code following PEP 8 and modern best practices.

## Core Principles

1. **Explicit is better than implicit**
2. **Readability counts**
3. **Simple is better than complex**
4. **Prefer composition over inheritance**

## Type Hints

```python
from typing import List, Dict, Optional, Union, TypeVar, Protocol

# ✅ Use type hints for clarity
def get_user(user_id: int) -> Optional[Dict[str, str]]:
    """Retrieve user data by ID."""
    user = database.query(user_id)
    return user if user else None

# ✅ Generic types
T = TypeVar('T')

def first_or_none(items: List[T]) -> Optional[T]:
    return items[0] if items else None

# ✅ Protocol for duck typing
class Drawable(Protocol):
    def draw(self) -> None: ...

def render(obj: Drawable) -> None:
    obj.draw()
```

## Pythonic Patterns

### List Comprehensions

```python
# ✅ List comprehensions over loops
squares = [x**2 for x in range(10)]
even_squares = [x**2 for x in range(10) if x % 2 == 0]

# ✅ Dict comprehensions
user_map = {user.id: user.name for user in users}

# ✅ Set comprehensions
unique_lengths = {len(word) for word in words}

# ❌ Don't use if logic is complex
# Instead, use a function
def process_item(item):
    # complex logic here
    return result

results = [process_item(item) for item in items]
```

### Generators

```python
# ✅ Memory-efficient iteration
def read_large_file(path: str):
    """Generator for processing large files line by line."""
    with open(path) as f:
        for line in f:
            yield line.strip()

# ✅ Generator expressions
sum_of_squares = sum(x**2 for x in range(1000000))

# ✅ Generator pipelines
def parse_logs(lines):
    for line in lines:
        if 'ERROR' in line:
            yield parse_error(line)

def filter_recent(errors, hours=24):
    cutoff = datetime.now() - timedelta(hours=hours)
    for error in errors:
        if error.timestamp > cutoff:
            yield error

# Usage
recent_errors = filter_recent(parse_logs(read_large_file('app.log')))
```

### Context Managers

```python
from contextlib import contextmanager
from typing import Generator

# ✅ Always use context managers for resources
with open('file.txt') as f:
    content = f.read()

# ✅ Custom context manager
@contextmanager
def db_transaction(connection) -> Generator:
    """Context manager for database transactions."""
    try:
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()

# Usage
with db_transaction(get_connection()) as conn:
    conn.execute('INSERT INTO users ...')
```

## Decorators

```python
from functools import wraps
from time import time
import logging

# ✅ Basic decorator
def timer(func):
    """Measure function execution time."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time()
        result = func(*args, **kwargs)
        duration = time() - start
        logging.info(f"{func.__name__} took {duration:.2f}s")
        return result
    return wrapper

@timer
def process_data(data: List[int]) -> int:
    return sum(data)

# ✅ Decorator with arguments
def retry(max_attempts: int = 3, delay: float = 1.0):
    """Retry function on failure."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    time.sleep(delay)
        return wrapper
    return decorator

@retry(max_attempts=5, delay=2.0)
def fetch_data(url: str) -> dict:
    return requests.get(url).json()
```

## Error Handling

```python
# ✅ Specific exceptions
class ValidationError(Exception):
    """Raised when data validation fails."""
    pass

class DatabaseError(Exception):
    """Raised when database operation fails."""
    pass

# ✅ EAFP: Easier to Ask for Forgiveness than Permission
def get_user(user_id: int) -> dict:
    try:
        return database.query(user_id)
    except KeyError:
        raise ValidationError(f"User {user_id} not found")

# ❌ LBYL: Look Before You Leap (less Pythonic)
def get_user_lbyl(user_id: int) -> dict:
    if user_id not in database:
        raise ValidationError(f"User {user_id} not found")
    return database.query(user_id)

# ✅ Exception chaining
try:
    data = fetch_external_data()
except requests.RequestException as e:
    raise DataFetchError("Failed to fetch data") from e
```

## Async/Await

```python
import asyncio
from typing import List

# ✅ Async functions
async def fetch_user(user_id: int) -> dict:
    async with aiohttp.ClientSession() as session:
        async with session.get(f'/api/users/{user_id}') as response:
            return await response.json()

# ✅ Gather for parallel execution
async def fetch_multiple_users(user_ids: List[int]) -> List[dict]:
    tasks = [fetch_user(uid) for uid in user_ids]
    return await asyncio.gather(*tasks)

# ✅ Async context manager
class AsyncDatabase:
    async def __aenter__(self):
        self.connection = await create_connection()
        return self.connection

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.connection.close()

async def query_data():
    async with AsyncDatabase() as db:
        return await db.query("SELECT * FROM users")
```

## Data Classes

```python
from dataclasses import dataclass, field
from datetime import datetime
from typing import List

# ✅ Use dataclasses for data containers
@dataclass
class User:
    id: int
    email: str
    name: str
    created_at: datetime = field(default_factory=datetime.now)
    tags: List[str] = field(default_factory=list)

    def __post_init__(self):
        """Validate after initialization."""
        if '@' not in self.email:
            raise ValueError("Invalid email")

# Usage
user = User(id=1, email='user@example.com', name='John')

# ✅ Frozen dataclasses for immutability
@dataclass(frozen=True)
class Config:
    api_key: str
    timeout: int = 30
```

## Testing with pytest

```python
import pytest
from unittest.mock import Mock, patch

# ✅ Simple test
def test_user_creation():
    user = User(id=1, email='test@example.com', name='Test')
    assert user.email == 'test@example.com'
    assert user.id == 1

# ✅ Parametrized tests
@pytest.mark.parametrize('email,valid', [
    ('user@example.com', True),
    ('invalid', False),
    ('user@', False),
    ('@example.com', False),
])
def test_email_validation(email: str, valid: bool):
    if valid:
        User(id=1, email=email, name='Test')
    else:
        with pytest.raises(ValueError):
            User(id=1, email=email, name='Test')

# ✅ Fixtures
@pytest.fixture
def database():
    """Provide test database connection."""
    db = Database(':memory:')
    db.create_tables()
    yield db
    db.close()

def test_user_persistence(database):
    user = User(id=1, email='test@example.com', name='Test')
    database.save(user)

    retrieved = database.get_user(1)
    assert retrieved.email == user.email

# ✅ Mocking
def test_api_call():
    with patch('requests.get') as mock_get:
        mock_get.return_value.json.return_value = {'id': 1}

        result = fetch_user_data(1)

        mock_get.assert_called_once_with('/api/users/1')
        assert result['id'] == 1

# ✅ Async tests
@pytest.mark.asyncio
async def test_async_fetch():
    result = await fetch_user(1)
    assert result['id'] == 1
```

## Performance

### Use Built-in Functions

```python
# ✅ sum() is faster than loop
total = sum(numbers)

# ✅ any() / all() for boolean checks
has_errors = any(item.error for item in items)
all_valid = all(item.is_valid() for item in items)

# ✅ set operations for membership
valid_ids = {1, 2, 3, 4, 5}
if user_id in valid_ids:  # O(1) vs O(n) for list
    process_user(user_id)
```

### List vs Generator

```python
# ❌ List: Loads everything into memory
squares = [x**2 for x in range(1000000)]
result = sum(squares)

# ✅ Generator: Memory efficient
squares = (x**2 for x in range(1000000))
result = sum(squares)
```

### String Building

```python
# ❌ Slow: Creates new string each iteration
result = ""
for item in items:
    result += str(item)

# ✅ Fast: Single allocation
result = "".join(str(item) for item in items)

# ✅ For complex formatting
parts = [f"Item {i}: {item}" for i, item in enumerate(items)]
result = "\n".join(parts)
```

## Common Patterns

### Singleton

```python
class Singleton:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
```

### Factory

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def draw(self): ...

class Circle(Shape):
    def draw(self):
        print("Drawing circle")

class Square(Shape):
    def draw(self):
        print("Drawing square")

def shape_factory(shape_type: str) -> Shape:
    shapes = {'circle': Circle, 'square': Square}
    shape_class = shapes.get(shape_type)
    if not shape_class:
        raise ValueError(f"Unknown shape: {shape_type}")
    return shape_class()
```

### Property Decorators

```python
class Temperature:
    def __init__(self, celsius: float):
        self._celsius = celsius

    @property
    def celsius(self) -> float:
        return self._celsius

    @celsius.setter
    def celsius(self, value: float):
        if value < -273.15:
            raise ValueError("Temperature below absolute zero")
        self._celsius = value

    @property
    def fahrenheit(self) -> float:
        return self._celsius * 9/5 + 32
```
