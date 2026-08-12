---
name: 'Python Standards'
description: 'Python-specific coding conventions and patterns'
applyTo: '**/*.py'
---

# Python Standards

## Type Hints
- ALL functions must have type hints on parameters and return values
- Use `str`, `int`, `list[str]`, `dict[str, Any]` — not bare `dict`, `list`
- Use `Optional[str]` or `str | None` for nullable parameters
- Use Pydantic BaseModel for complex data structures

## Docstrings
- Google-style docstrings on all public functions
- Include: Args, Returns, Raises, Example (where helpful)

## Error Handling
- Specific exceptions: `except ValueError as e:` — never bare `except:`
- Include context in error messages: `f"Failed to upload {filename}: {e}"`
- Re-raise with context when catching and re-throwing
- Use custom exception classes for domain-specific errors

## Code Style
- Formatter: ruff format
- Linter: ruff check
- Max line length: 120 characters
- Import order: stdlib → third-party → local (ruff handles this)

## FastAPI Patterns
- Pydantic models for all request/response bodies
- Dependency injection for shared resources (db clients, auth)
- Background tasks for non-blocking operations
- Middleware for logging, CORS, error handling
- Health check endpoint at /health

## Testing
- pytest with pytest-asyncio for async tests
- Fixtures for shared setup
- Parametrize for multiple test cases
- Mocking with unittest.mock or pytest-mock
