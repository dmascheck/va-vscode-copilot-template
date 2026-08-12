---
agent: agent
description: Run tests, lint, security audit, flag TODOs. One-page code health report.
---

# Quality Report

**Purpose:** One-page code health dashboard.

## Steps

1. **Tests:** `python -m pytest tests/ -v --tb=short`
2. **Lint:** `ruff check . && ruff format --check .`
3. **Security:** Check for hardcoded secrets, dependency vulnerabilities
4. **TODOs:** `grep -rn "TODO\|FIXME\|HACK" --include="*.py" --include="*.ts" .`
5. **Coverage:** `pytest --cov=backend --cov-report=term-missing`
6. **VA Compliance:** Verify no commercial Azure endpoints, no PHI in logs

## Output

```
📊 QUALITY REPORT — {date}

🧪 Tests:     {passed}/{total} passed · {coverage}% coverage
🔍 Lint:      {errors} errors · {warnings} warnings
🔒 Security:  {findings or "clean"}
📝 TODOs:     {count} in production code
🛡️ VA Compliance: {status}

⚠️ Top Issues:
1. {most important}
2. {second}
3. {third}
```
