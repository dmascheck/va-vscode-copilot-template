---
name: 'Code Standards'
description: 'Universal coding standards for all languages and frameworks'
applyTo: '**'
---

# Code Standards

## General
- Type hints on ALL functions (Python: full typing, JS/TS: TypeScript types)
- Google-style docstrings (Python) or JSDoc (TypeScript) on all public functions
- Error handling: specific exceptions with context. Never bare `except` or `catch`.
- Input validation at every system boundary
- No bare `print()` or `console.log()` in application code — use structured logging

## Python
- Use `ruff` for formatting and linting
- Type hints: use `str`, `int`, `list[str]`, `dict[str, Any]` — not bare `dict`, `list`
- Async preferred where available
- Pydantic models for request/response validation

## TypeScript / JavaScript
- Strict TypeScript — no `any` unless absolutely necessary with a comment explaining why
- Prefer `const` over `let`, never `var`
- Use named exports over default exports
- Group imports: external libraries → internal modules → relative paths

## Azure
- NEVER use connection strings, SAS tokens, or access keys
- ALWAYS use DefaultAzureCredential (Service Principal for dev, Managed Identity for prod)
- Auth priority: environment → MCP lookup → configuration
- Store resource names in .env.project, NEVER secrets

## Security
- No secrets in code, environment variables via .env files (gitignored)
- SQL: parameterized queries only, never string concatenation
- User input: sanitize and validate with Pydantic or Zod
- Dependencies: verify maintained, check for vulnerabilities
