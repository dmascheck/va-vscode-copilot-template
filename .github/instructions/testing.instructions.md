---
applyTo: "**/tests/**, **/*.test.py, **/*.spec.ts, **/*.spec.tsx, **/test_*.py"
---

# Testing Standards

## TDD Approach (Test First)

Write the failing test BEFORE writing the implementation:

```python
# Step 1: Write test (will fail)
def test_sync_veteran_documents_returns_count():
    result = sync_veteran_documents(veteran_id="12345", documents=[mock_doc])
    assert result.synced_count == 1
    assert result.failed_count == 0

# Step 2: Run it — watch it fail
# Step 3: Write implementation to make it pass
# Step 4: Refactor
```

## pytest Patterns (Python)

```python
import pytest
from unittest.mock import AsyncMock, patch, MagicMock

@pytest.fixture
def mock_credential():
    return MagicMock()

# Always mock Azure SDK calls in unit tests
@pytest.mark.asyncio
async def test_fetch_records(client):
    with patch.object(client.storage_client, "get_blob") as mock_get:
        mock_get.return_value = AsyncMock(return_value=b"test data")
        result = await client.fetch_records("12345")
        assert result is not None
```

## Test Data Rules (VA-Specific)

- **NEVER** use real veteran data in tests — use synthetic test data
- **NEVER** use real SSNs, ICNs, or DFNs — generate fake identifiers
- Test fixtures must not contain PHI/PII
- Document test data sources in test docstrings

## Coverage Targets

| Layer | Target |
|-------|--------|
| Unit tests | 85%+ line coverage |
| Integration tests | All API endpoints covered |
| E2E tests | All critical user flows |

## Test Logging

All test output captured to `Logs/logging/tests.log` via pytest config.
- **NEVER** use `print()` in tests — use the logger.
