---
name: testing
description: "Testing patterns for pytest, Playwright E2E, and API testing. TDD workflow with red-green-refactor. Use when writing tests, running test suites, or improving test coverage."
---

# Testing Skill

## TDD Workflow (Red-Green-Refactor)
1. **Red**: Write a failing test that describes the desired behavior
2. **Green**: Write minimal implementation to make the test pass
3. **Refactor**: Improve code quality while keeping tests green

## Python Testing (pytest)
```python
# Test structure
tests/
  conftest.py          # Shared fixtures
  test_api.py          # API endpoint tests
  test_services.py     # Service layer tests
  test_models.py       # Data model tests
  e2e/
    test_flows.py      # End-to-end flows

# Fixtures
@pytest.fixture
def client():
    """Create test client for FastAPI app."""
    from backend.main import app
    with TestClient(app) as client:
        yield client

# Async tests
@pytest.mark.asyncio
async def test_create_item(async_client):
    response = await async_client.post("/items", json={"name": "test"})
    assert response.status_code == 201

# Parametrized tests
@pytest.mark.parametrize("input,expected", [
    ("valid", 200),
    ("invalid", 422),
    ("", 422),
])
def test_validation(client, input, expected):
    response = client.post("/validate", json={"value": input})
    assert response.status_code == expected
```

## Playwright E2E Testing
```typescript
// Page object pattern
class LoginPage {
  constructor(private page: Page) {}
  
  async login(email: string, password: string) {
    await this.page.fill('[data-testid="email"]', email);
    await this.page.fill('[data-testid="password"]', password);
    await this.page.click('[data-testid="submit"]');
  }
}

// Test
test('user can log in', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.login('test@example.com', 'password');
  await expect(page.locator('[data-testid="dashboard"]')).toBeVisible();
});
```

## API Testing
```python
# FastAPI test client
def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

# Test with auth
def test_protected_endpoint(client, auth_headers):
    response = client.get("/api/data", headers=auth_headers)
    assert response.status_code == 200
```

## Rules
- Every new feature must have tests BEFORE implementation (TDD)
- Bug fixes must include a regression test
- Test data must be synthetic (especially for HIPAA projects)
- Tests must be deterministic (no random data without seeding)
- Coverage target: 80%+ for business logic
