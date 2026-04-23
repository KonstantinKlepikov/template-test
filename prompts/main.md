# Main python Guide

## Formatting & Style

- Follow PEP 8 as baseline
- Formatter/linter: `ruff` (replaces `blue` and `isort`)
- Line length: **88**
- Quote style: **single quotes**
- Encoding: UTF-8, no encoding declarations
- Import sorting: handled by `ruff check --fix` (rule `I`)

```toml
[tool.ruff]
line-length = 88

[tool.ruff.format]
quote-style = "single"

[tool.ruff.lint]
select = ["I"]
```

## Naming conventions

| Entity | Style | Example |
| --- | --- | --- |
| Module (file) | `snake_case` | `my_module.py` |
| Class | `CapitalCamelCase` | `FlightService` |
| Class with acronym | Acronym uppercase | `CapitalCamelCaseDSN` |
| Exception | `CapitalCamelCase` | `FlightNotFoundError` |
| Function / variable | `snake_case` | `get_flights` |
| Global constant | `CONSTANT_CASE` | `MAX_RETRY_COUNT` |
| Enum class | Singular noun | `FlightStatus`, `PointType` |
| Enum values | `snake_case` or `lowercase` | `'active'`, `'cancelled'` |

- Names must be ASCII English only
- Never use `l`, `O`, `I` as single-char identifiers
- Prefix `_` = private; suffix `_` = avoid keyword clash (`type_`)

## Type hints

Type hints are **mandatory everywhere** in production code, strongly recommended in tests.

- Use built-in generic types: `list[str]`, `dict[str, int]`, `set[int]`, `tuple[str, ...]`
- Do NOT use `typing.List`, `typing.Dict`, etc. (deprecated since PEP 585)
- Use `X | None` instead of `Optional[X]`, use `X | Y` instead of `Union[X, Y]`
- Always annotate `-> None` for functions that return nothing
- Use `TypeVar` for generic/reusable functions
- Specify concrete inner types for generics: `dict[str, int]`, not bare `dict`
- If mypy complains about type reassignment, rename the variable instead of ignoring
- Newer use simplified types like `dict` or `list[dict]`. Type must be informative (e.g. `dict[str | int, SomeClass]`)
- Use alias names for complex types

```python
# Good
def process(items: list[str]) -> dict[str, int]:
    ...

# Bad
from typing import List
def process(items: List[str]) -> Dict[str, int]:
    ...
```

## Code design

### Function and classes design

- Target ~20-30 lines per function body; >50 lines = decompose
- Newer use any object or `None` for function return (example `def this() -> str | None: ...`). Function can return something or `None`, noth both.
- One level of abstraction per function: orchestrate OR implement, don't mix
- Mark methods that don't use `self` as `@staticmethod`. If it possible, use outside functions indtead of staticmethods
- Only store in `self` values that live as long as the object; never add fields outside `__init__`
- If values shared acros all class instances, declare it as attributes in class definition
- Create chared objects outside of functions or methods, and transfer it inside with function arguments. Dont use outside scoupe directly
- If it possible, dont use `nonlocal` and `global`
- To complex arguments of functions, if it used in any pipelines, compose in a class of data

### Async

- Use `async/await` for all I/O-bound operations if project use asyncio
- Use `asyncio.sleep()`, never `time.sleep()` in async code
- Use `time.monotonic()` for timing, never `time.time()`

### Decorators

- Always use `@functools.wraps(func)` in decorator wrappers
- If decorator may wrap both sync and async functions, provide both wrappers with `inspect.iscoroutinefunction` check

## Exception and logging

- Create a root exception per project: `<ExceptionName>Error(Exception)`
- All custom exceptions inherit cascading from the root
- Always use `from err` when re-raising: `raise ServiceError('msg') from err`
- Use context managers
- Use decorators for cross-cutting concerns (logging)
- Catch specific exceptions, not bare `Exception` (bare `except Exception` only at top-level safety nets, in decorators for logging, or as last `except`)
- Throw explicit exceptions for "impossible" states rather than ignoring

```python
@contextmanager
def handle_router_errors():
    try:
        yield
    except ServiceNotFoundError as err:
        raise Http404Error(err)
    except ServiceValidationError as err:
        raise Http422Error(err)
    except Exception as err:
        raise Http500Error(err)
```

## if/else patterns

- Use early returns/raises to reduce nesting: check error conditions first, keep main flow at base indentation
- Avoid `else` after `return`/`raise` — use implicit else
- For exhaustive checks over known values, always raise on unknown case instead of falling through
- In loops, use `continue` for guard clauses to reduce nesting

```python
# Good — early exit, flat main flow
def get_item(self, item_id: int) -> Item:
    if item_id not in self.items:
        raise KeyError(f'Unknown item {item_id}')
    return self.items[item_id]

# Good — exhaustive check
def get_label(status: str) -> str:
    if status == 'active':
        return 'Active'
    if status == 'cancelled':
        return 'Cancelled'
    raise ValueError(f'Unknown status: {status}')
```

## Documentation and comments

- Use english for all comments and docstrings
- Docstring style: **Google style** (`Args:`, or `Attrs:`, `Raises:`, `Yields:` and `Returns:`)
- Document public modules/functions/classes if they are part of a reusable package
- Comments must be complete sentences, starting with uppercase
- Two spaces after period in multi-sentence comments
- Never comment obvious code; comment non-obvious intent
- Always update comments when changing code
- Newer comment in a module in the header of file. Use cjmplex comments and docstrings only for functions, methods and classes

## Logging

- Use `loguru`
- Log useful context that helps trace execution flow and diagnose errors
- Don't decorate high-frequency functions (called hundreds/thousands of times) with log wrappers
