# Test Plan

## Strategy
- **Unit Tests:** pytest with 85%+ coverage target
- **Integration Tests:** All API endpoints covered
- **E2E Tests:** Playwright for critical user flows
- **Security Tests:** OWASP pattern checks, secret scanning

## Coverage Targets

| Layer | Target |
|-------|--------|
| Unit tests | 85%+ line coverage |
| Integration tests | All API endpoints |
| E2E tests | Critical user flows |

## VA-Specific Testing

- [ ] No PHI/PII in test data (use synthetic data)
- [ ] No real SSNs, ICNs, or DFNs in fixtures
- [ ] Section 508 accessibility tests for frontend
- [ ] Azure Government endpoint verification tests

## Running Tests

```bash
# Unit tests
python -m pytest tests/ -v

# With coverage
pytest --cov=backend --cov-report=term-missing

# E2E (Playwright)
npx playwright test
```
