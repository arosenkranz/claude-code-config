# Learning Python from JavaScript

A bridge guide for JavaScript/TypeScript developers learning Python.

## Concept Mapping: JS -> Python

| JavaScript | Python | Notes |
|-----------|--------|-------|
| `const`/`let` | Variable assignment | Python has no `const`; use UPPER_CASE convention for constants |
| `===` | `==` | Python's `==` compares values (like JS `===`); use `is` for identity |
| `null`/`undefined` | `None` | Python has only `None` |
| `Array` | `list` | Very similar; Python lists are mutable |
| `Object` | `dict` | Similar but Python dicts are ordered (3.7+) |
| `arrow functions` | `lambda` | Python lambdas are single-expression only |
| `async/await` | `async/await` | Very similar syntax; Python uses `asyncio` |
| `Promise` | `coroutine` | `await` works on coroutines, not promises |
| `.map()/.filter()` | List comprehensions | `[x*2 for x in items if x > 0]` |
| `try/catch/finally` | `try/except/finally` | Python uses `except` not `catch` |
| `import { x } from 'y'` | `from y import x` | Python imports are similar but module-based |
| `class` | `class` | Python classes use `self` explicitly |
| `interface` | `Protocol` | Python uses typing.Protocol for structural typing |
| `Record<K,V>` | `dict[K,V]` | Python 3.9+ supports this syntax |
| `string template` | `f-string` | `f"Hello {name}"` similar to `` `Hello ${name}` `` |
| `...spread` | `*args, **kwargs` | Unpacking with `*` and `**` |
| `?.` optional chaining | No equivalent | Use `getattr(obj, 'attr', default)` or try/except |
| `npm`/`pnpm` | `pip`/`poetry`/`uv` | `uv` is the fastest modern option |
| `package.json` | `pyproject.toml` | Modern Python project config |
| `Jest`/`Vitest` | `pytest` | pytest is the dominant testing framework |
| `ESLint` | `ruff` | ruff is extremely fast (written in Rust) |
| `TypeScript` | Type hints + mypy | Optional but strongly recommended |

## Key Differences to Internalize

### Indentation Is Syntax
```python
# Python uses indentation, not braces
if condition:
    do_thing()
    for item in items:
        process(item)
```

### No Semicolons, No Braces
```python
# Clean, minimal syntax
def greet(name: str) -> str:
    return f"Hello, {name}!"
```

### Everything Is an Object
```python
# Functions are first-class, like JS
def apply(fn, value):
    return fn(value)

result = apply(str.upper, "hello")  # "HELLO"
```

### Truthiness
```python
# Falsy: None, False, 0, "", [], {}, set()
# Different from JS: empty collections are falsy
if not my_list:  # Pythonic way to check empty
    print("Empty!")
```

## Project Ideas for Practice

1. **CLI Tool** - Migrate a Node.js script to Python using Click/Typer
2. **REST API** - Build a FastAPI equivalent of an Express route
3. **Data Pipeline** - Process JSON/CSV files with Python's stdlib
4. **Homelab Script** - Docker container health checker in Python
5. **Web Scraper** - Use httpx + BeautifulSoup (replaces fetch + cheerio)
6. **Discord Bot** - Use discord.py (similar patterns to discord.js)

## Frameworks Comparison

| JS Framework | Python Equivalent | Similarity |
|-------------|-------------------|------------|
| Express | FastAPI / Flask | FastAPI is async-first like modern Express |
| React | Jinja2 / HTMX | Server-side templating is more common in Python |
| Jest/Vitest | pytest | pytest is more powerful with fixtures |
| Zod | Pydantic | Pydantic is built into FastAPI |
| Commander/yargs | Click / Typer | Typer uses type hints for CLI args |
| chalk | Rich | Rich is more powerful (tables, progress bars, trees) |
