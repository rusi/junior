# Python Modern Conventions

## Project Tooling Selection

Before running Python commands, read the consuming project's contributor guidance, package
configuration, lockfiles, environment setup, task scripts, and CI commands. Use the runner,
Python version, and tools established for the component being changed. A `pyproject.toml`
alone does not establish a package manager.

- Prefer the project's documented wrapper or task command when it sets up the environment.
- For a uv-managed project, use `uv run`; for Poetry, use `poetry run`; for a pip/venv
  project, use its configured environment's interpreter or activated environment.
- Preserve existing test, lint, format, type-check, benchmark, and CLI tooling. The named
  tools below are defaults for projects without an established equivalent, not migration
  requirements. Examples apply only where their runner and tools are configured.
- Do not add dependencies, change lockfiles, upgrade Python, or migrate tooling solely to
  satisfy these examples. Match syntax and tool settings to the supported Python version.
- If evidence is missing or conflicting, resolve the intended environment before commands
  that install dependencies or modify project state. Recommend a setup for a new project
  and agree it before adding tooling.

Runner examples for projects using pytest: `uv run pytest`, `poetry run pytest`, or
`python -m pytest` with the configured virtual environment active. These are alternatives,
not a sequence to execute.

## Type Hints (Python 3.10+)

**ALWAYS use modern type hint syntax:**

```python
# ✅ CORRECT - Modern Python 3.10+
from __future__ import annotations

def process(items: list[str]) -> dict[str, int]:
    result: dict[str, int] = {}
    optional_value: str | None = None
    return result

# ❌ WRONG - Old style (pre-3.10)
from typing import List, Dict, Optional

def process(items: List[str]) -> Dict[str, int]:
    result: Dict[str, int] = {}
    optional_value: Optional[str] = None
    return result
```

**Rules:**
- Use `list[X]` not `List[X]`
- Use `dict[K, V]` not `Dict[K, V]`
- Use `set[X]` not `Set[X]`
- Use `tuple[X, Y]` not `Tuple[X, Y]`
- Use `X | None` not `Optional[X]`
- Use `X | Y` not `Union[X, Y]`
- **Always add `from __future__ import annotations` at the top**

## Pytest Conventions

### Test Organization

**Use classes for grouping related tests:**

```python
class TestUserAuthentication:
    """Tests for user authentication flow."""

    @pytest.fixture
    def user(self):
        return User(username="test")

    def test_login_success(self, user):
        assert user.login("password")

    def test_login_failure(self, user):
        assert not user.login("wrong")
```

**Use functions for simple, independent tests:**

```python
def test_add_numbers():
    assert add(2, 3) == 5

def test_subtract_numbers():
    assert subtract(5, 3) == 2
```

**When to use classes:**
- Tests share fixtures
- Testing a specific class/component
- Logical grouping needed
- Multiple related test scenarios

**When to use functions:**
- Simple, independent tests
- No shared setup
- Testing pure functions

### Modern Pytest Features

```python
# ✅ Use parametrize for multiple test cases
@pytest.mark.parametrize("input,expected", [
    (2, 4),
    (3, 9),
    (4, 16),
])
def test_square(input, expected):
    assert square(input) == expected

# ✅ Use fixtures with type hints
@pytest.fixture
def database() -> Database:
    db = Database()
    yield db
    db.close()

# ✅ Use descriptive test names
def test_user_cannot_access_admin_page_without_permission():
    # Clear what is being tested
    pass
```

## Code Style

### Imports

**Order:** future, stdlib, third-party, local

**Clarity convention - Classes vs Functions:**

**RULE:** Third-party **classes** OK to import directly (capitalized, clear). Third-party **functions** need module prefix.

```python
# ✅ CLASSES - Import directly (capitalized = clear)
from bleak import BleakClient, BleakScanner
from bleak.backends.device import BLEDevice

# Usage
client = BleakClient(device)  # Clear it's a class from bleak
scanner = BleakScanner()

# ✅ MODULES - Import with clear alias for functions
from cryptography.hazmat import backends as crypto_backends
from cryptography.hazmat.primitives import ciphers as crypto_ciphers
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec, utils as crypto_utils

# Usage - Functions prefixed, classes/constants OK
backend = crypto_backends.default_backend()  # Function - needs prefix
cipher = crypto_ciphers.Cipher(...)  # Function - needs prefix
algo = hashes.SHA256()  # Function - but hashes. prefix makes it clear
key = ec.EllipticCurvePrivateKey  # Class - clear even without prefix
r, s = crypto_utils.decode_dss_signature(...)  # Function - needs prefix
```

**Why this matters:**

```python
# ❌ BAD - Functions look like our code
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature

backend = default_backend()  # Whose function is this?
r, s = decode_dss_signature(sig)  # Decode what? From where?

# ✅ GOOD - Clear origin
from cryptography.hazmat import backends as crypto_backends
from cryptography.hazmat.primitives.asymmetric import utils as crypto_utils

backend = crypto_backends.default_backend()  # Crypto's backend
r, s = crypto_utils.decode_dss_signature(sig)  # Crypto's decoder
```

**Quick reference:**

| Type | Import Style | Example |
|------|-------------|---------|
| **Classes** (capitalized) | Direct import | `from bleak import BleakClient` |
| **Functions** (lowercase) | Module prefix | `from cryptography.hazmat import backends as crypto_backends` |
| **Our own code** | Always direct | `from app.models import User` |
| **Standard library** | Direct OK | `from typing import cast` |

**Exceptions:**
- Standard library: Always OK to import directly
- Our own code: Always OK to import classes/functions
- Very common patterns: OK if idiomatic (`import asyncio`, `import json`)

### NO Inline Imports (CRITICAL)

**NEVER use inline/local imports inside functions or methods:**

```python
# ❌ WRONG - Inline import (BAD PRACTICE)
def process_item(item_id: int) -> Item:
    from app.services.data_service import DataService  # ❌ Inside function

    return DataService.process(...)

# ✅ CORRECT - Import at top of file
from app.services.data_service import DataService

def process_item(item_id: int) -> Item:
    return DataService.process(...)
```

**Why inline imports are bad:**
- ❌ Harder to see module dependencies at a glance
- ❌ Repeated import overhead (if function called multiple times)
- ❌ Harder to detect circular import issues
- ❌ Not PEP 8 compliant
- ❌ Violates "all imports at top of file" convention

**Only acceptable exception:**
- Breaking circular imports (very rare, indicates design problem)
- If you need inline imports to avoid circular imports, **redesign your modules** instead

**Detection:** Search for `from.*import` inside function/method bodies:
```bash
grep -n "^[[:space:]]\+from.*import" *.py
```

### String Formatting

```python
# ✅ CORRECT - Use f-strings
name = "world"
message = f"Hello, {name}!"

# ❌ WRONG - Old style
message = "Hello, {}!".format(name)
message = "Hello, %s!" % name
```

### Dataclasses

```python
from dataclasses import dataclass

@dataclass
class Config:
    host: str
    port: int
    debug: bool = False
```

## Ruff Configuration

For projects selecting Ruff under Project Tooling Selection, adapt this configuration to
the project's Python version and formatting conventions:

```toml
[tool.ruff]
target-version = "py310"
line-length = 120

[tool.ruff.lint]
select = ["E", "F", "I", "UP"]  # UP = pyupgrade for modern Python
```

## Performance Testing

Use the project's benchmark framework. For pytest projects without an existing equivalent,
prefer pytest-benchmark for statistical performance testing.

### Why pytest-benchmark?

- ✅ Statistical analysis (mean, median, stddev, outliers)
- ✅ Regression detection via `--benchmark-compare`
- ✅ Multiple iterations automatically
- ✅ Built-in warmup and calibration
- ❌ **NEVER use manual `time.perf_counter()` in tests**

### Basic Usage

```python
def test_function_performance(benchmark):
    """
    GIVEN a performance-critical function
    WHEN benchmarked
    THEN completes within target time
    """
    result = benchmark(my_function, arg1, arg2)

    # Verify correctness
    assert result == expected_value

    # Verify performance (benchmark.stats.mean is in seconds)
    mean_time_ms = benchmark.stats.mean * 1000
    assert mean_time_ms < 100, f"Too slow: {mean_time_ms:.2f}ms > 100ms"
```

### Running Benchmarks

Example for a uv-managed project with pytest-benchmark; otherwise use the selected runner
and benchmark framework.

```bash
# Run benchmarks
uv run pytest tests/test_performance.py --benchmark-only

# Compare with baseline
uv run pytest tests/ --benchmark-compare

# Save baseline
uv run pytest tests/ --benchmark-save=baseline
```

### When to Write Performance Tests

- ✅ Performance-critical paths (parsing, algorithms, database queries)
- ✅ Features with explicit performance requirements
- ✅ Known bottlenecks
- ✅ APIs with latency SLAs

## CLI Applications

### Use Modern Frameworks

When choosing new CLI tooling, these are defaults; preserve established equivalents under
Project Tooling Selection.

**CLI Parsing:**
- ✅ Use `typer` for type-safe CLI applications
- ❌ Avoid raw `argparse` (verbose, error-prone)

**Console Output:**
- ✅ Use `rich` for beautiful console output
- ❌ Avoid manual string formatting and `print()`

**Logging:**
- ✅ Use `structlog` with concise timestamp format
- ❌ Avoid verbose ISO timestamps in console

**Example:**
```python
import typer
from rich.console import Console
from rich.progress import track

app = typer.Typer()
console = Console()

@app.command()
def main(debug: bool = False):
    """CLI application."""
    for item in track(items, description="Processing"):
        process(item)

if __name__ == "__main__":
    app()
```

### Module Structure

**Extract Utilities:**
- `cli/logging.py` - Logging configuration
- `cli/ui.py` - Console UI helpers (progress bars, formatters)
- `cli/args.py` - Argument parsing (if complex)

**Main Application:**
- Keep focused on orchestration
- Delegate to utilities
- Target 30-50 lines for simple operations

## Summary Checklist

- [ ] Use the consuming project's configured Python environment, runner, and tools
- [ ] Use `from __future__ import annotations`
- [ ] Use modern type hints (`list`, `dict`, `X | None`)
- [ ] No `typing.List`, `typing.Optional`, etc.
- [ ] Classes for grouped tests, functions for simple tests
- [ ] f-strings for formatting
- [ ] No build system for standalone apps
- [ ] Type hint fixtures and functions
- [ ] Use the selected benchmark framework for statistical performance tests
- [ ] Follow the project's CLI and console-output conventions
- [ ] Extract utilities (logging, UI, args)
