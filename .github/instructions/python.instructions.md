---
applyTo: "**/*.py"
---

# Python Code Standards

## Type Hints (Required on ALL functions)

```python
def process_data(input_data: dict[str, Any], limit: int = 100) -> list[ProcessedResult]:
```

Use `from __future__ import annotations` for forward references. Never use bare `dict` or `list` — always parameterize.

## Google-Style Docstrings (Required on ALL functions)

```python
def fetch_veteran_records(veteran_id: str, include_labs: bool = False) -> VeteranRecord:
    """Fetch complete veteran record from data store.

    Args:
        veteran_id: Veteran identifier (ICN or DFN).
        include_labs: Whether to include laboratory results. Defaults to False.

    Returns:
        Complete veteran record with demographics and clinical data.

    Raises:
        VeteranNotFoundError: When veteran_id does not exist.
        ConnectionError: When data store is unreachable.
    """
```

## Error Handling (Never bare except)

```python
# FORBIDDEN
try:
    result = risky_operation()
except:
    pass

# REQUIRED — specific exception with context
try:
    result = risky_operation()
except SpecificError as e:
    logger.error("Operation failed for %s: %s", context_id, str(e))
    raise
```

## Logging (MANDATORY)

- Use `from scripts.logging_config import setup_logging`
- **NEVER** use `print()` — enforced by ruff T201
- Log function entry/exit, file I/O, subprocess calls, external API calls
- **NEVER** log PHI/PII — mask sensitive data
