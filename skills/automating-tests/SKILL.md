---
name: automating-tests
description: Create comprehensive test suites with unit, integration, and e2e tests. Use when writing tests, setting up test automation, creating test fixtures, configuring CI test pipelines, or improving test coverage.
---

# Test Automation

Build comprehensive test suites following the test pyramid pattern.

## Test Pyramid

```
     /\
    /E2E\      <- Few, slow, expensive
   /------\
  / INTEG  \   <- Some, medium speed
 /----------\
/   UNIT     \ <- Many, fast, cheap
--------------
```

Focus: Many unit tests, fewer integration tests, minimal E2E tests.

## Unit Tests

### Test Structure (Arrange-Act-Assert)

```javascript
// Jest example
describe('UserService', () => {
  describe('createUser', () => {
    it('creates user with valid data', async () => {
      // Arrange
      const service = new UserService();
      const userData = {
        email: 'test@example.com',
        name: 'Test User'
      };

      // Act
      const user = await service.createUser(userData);

      // Assert
      expect(user).toMatchObject(userData);
      expect(user.id).toBeDefined();
      expect(user.createdAt).toBeInstanceOf(Date);
    });

    it('throws ValidationError for invalid email', async () => {
      // Arrange
      const service = new UserService();

      // Act & Assert
      await expect(
        service.createUser({ email: 'invalid', name: 'Test' })
      ).rejects.toThrow(ValidationError);
    });
  });
});
```

### pytest Example

```python
import pytest
from user_service import UserService, ValidationError

class TestUserService:
    @pytest.fixture
    def service(self):
        """Provide fresh UserService for each test."""
        return UserService()

    def test_create_user_with_valid_data(self, service):
        # Arrange
        user_data = {
            'email': 'test@example.com',
            'name': 'Test User'
        }

        # Act
        user = service.create_user(user_data)

        # Assert
        assert user.email == user_data['email']
        assert user.name == user_data['name']
        assert user.id is not None

    def test_create_user_invalid_email(self, service):
        # Act & Assert
        with pytest.raises(ValidationError, match="Invalid email"):
            service.create_user({'email': 'invalid', 'name': 'Test'})

    @pytest.mark.parametrize('email,should_pass', [
        ('user@example.com', True),
        ('user+tag@example.com', True),
        ('invalid', False),
        ('@example.com', False),
        ('user@', False),
    ])
    def test_email_validation(self, service, email, should_pass):
        if should_pass:
            user = service.create_user({'email': email, 'name': 'Test'})
            assert user.email == email
        else:
            with pytest.raises(ValidationError):
                service.create_user({'email': email, 'name': 'Test'})
```

## Mocking and Stubbing

### Jest Mocks

```javascript
import { fetchUserData } from './api';
import { processUser } from './user-processor';

jest.mock('./api');

describe('processUser', () => {
  it('processes user data from API', async () => {
    // Mock the API call
    fetchUserData.mockResolvedValue({
      id: 1,
      name: 'John',
      email: 'john@example.com'
    });

    const result = await processUser(1);

    expect(fetchUserData).toHaveBeenCalledWith(1);
    expect(result.name).toBe('JOHN'); // uppercase transformation
  });

  it('handles API errors', async () => {
    fetchUserData.mockRejectedValue(new Error('API failed'));

    await expect(processUser(1)).rejects.toThrow('API failed');
  });
});
```

### pytest Mocking

```python
from unittest.mock import Mock, patch, MagicMock
import pytest

def test_user_processor_with_mock(mocker):
    # Using pytest-mock
    mock_api = mocker.patch('module.fetch_user_data')
    mock_api.return_value = {
        'id': 1,
        'name': 'John',
        'email': 'john@example.com'
    }

    result = process_user(1)

    mock_api.assert_called_once_with(1)
    assert result['name'] == 'JOHN'

def test_database_interaction():
    # Mock database connection
    mock_db = Mock()
    mock_db.query.return_value = [{'id': 1, 'name': 'Test'}]

    service = UserService(db=mock_db)
    users = service.get_all_users()

    mock_db.query.assert_called_once()
    assert len(users) == 1
```

## Fixtures and Test Data

### pytest Fixtures

```python
import pytest
from database import Database

@pytest.fixture(scope='session')
def database():
    """Session-wide database connection."""
    db = Database(':memory:')
    db.create_tables()
    yield db
    db.close()

@pytest.fixture
def sample_users():
    """Provide sample user data."""
    return [
        {'email': 'user1@example.com', 'name': 'User 1'},
        {'email': 'user2@example.com', 'name': 'User 2'},
    ]

@pytest.fixture
def user_service(database):
    """Provide UserService with test database."""
    return UserService(database)

def test_bulk_create(user_service, sample_users):
    created = user_service.bulk_create(sample_users)
    assert len(created) == 2
```

### Jest Setup/Teardown

```javascript
describe('DatabaseTests', () => {
  let db;

  beforeAll(async () => {
    // Run once before all tests
    db = await Database.connect(':memory:');
    await db.createTables();
  });

  afterAll(async () => {
    // Run once after all tests
    await db.close();
  });

  beforeEach(async () => {
    // Run before each test
    await db.clearTables();
  });

  it('inserts user', async () => {
    await db.insert('users', { name: 'Test' });
    const users = await db.query('users');
    expect(users).toHaveLength(1);
  });
});
```

## Integration Tests

### Test with Real Dependencies

```python
import pytest
from testcontainers.postgres import PostgresContainer

@pytest.fixture(scope='module')
def postgres_container():
    """Provide PostgreSQL container for integration tests."""
    with PostgresContainer('postgres:15') as postgres:
        yield postgres

@pytest.fixture
def db_connection(postgres_container):
    """Provide database connection."""
    conn = create_connection(postgres_container.get_connection_url())
    setup_schema(conn)
    yield conn
    conn.close()

def test_user_repository_integration(db_connection):
    repo = UserRepository(db_connection)

    # Insert user
    user = repo.create({'email': 'test@example.com', 'name': 'Test'})
    assert user.id is not None

    # Retrieve user
    retrieved = repo.get_by_id(user.id)
    assert retrieved.email == 'test@example.com'

    # Update user
    repo.update(user.id, {'name': 'Updated'})
    updated = repo.get_by_id(user.id)
    assert updated.name == 'Updated'
```

### API Integration Tests

```javascript
import request from 'supertest';
import app from './app';

describe('API Integration Tests', () => {
  it('creates and retrieves user', async () => {
    // Create user
    const createResponse = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Test' })
      .expect(201);

    const userId = createResponse.body.id;

    // Retrieve user
    const getResponse = await request(app)
      .get(`/api/users/${userId}`)
      .expect(200);

    expect(getResponse.body.email).toBe('test@example.com');
  });

  it('returns 404 for non-existent user', async () => {
    await request(app)
      .get('/api/users/999')
      .expect(404);
  });
});
```

## End-to-End Tests

### Playwright Example

```javascript
import { test, expect } from '@playwright/test';

test.describe('User Registration', () => {
  test('completes registration flow', async ({ page }) => {
    // Navigate to registration page
    await page.goto('/register');

    // Fill form
    await page.fill('[data-testid="email-input"]', 'test@example.com');
    await page.fill('[data-testid="password-input"]', 'SecurePass123');
    await page.fill('[data-testid="name-input"]', 'Test User');

    // Submit form
    await page.click('[data-testid="submit-button"]');

    // Wait for redirect
    await page.waitForURL('/dashboard');

    // Verify success
    await expect(page.locator('[data-testid="welcome-message"]'))
      .toContainText('Welcome, Test User');
  });

  test('shows validation errors', async ({ page }) => {
    await page.goto('/register');

    // Submit without filling
    await page.click('[data-testid="submit-button"]');

    // Check error messages
    await expect(page.locator('[data-testid="email-error"]'))
      .toContainText('Email is required');
  });
});
```

### Cypress Example

```javascript
describe('User Dashboard', () => {
  beforeEach(() => {
    // Login before each test
    cy.login('test@example.com', 'password');
    cy.visit('/dashboard');
  });

  it('displays user information', () => {
    cy.get('[data-cy=user-name]').should('contain', 'Test User');
    cy.get('[data-cy=user-email]').should('contain', 'test@example.com');
  });

  it('updates profile', () => {
    cy.get('[data-cy=edit-profile]').click();
    cy.get('[data-cy=name-input]').clear().type('Updated Name');
    cy.get('[data-cy=save-button]').click();

    cy.get('[data-cy=success-message]')
      .should('be.visible')
      .and('contain', 'Profile updated');
  });
});
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:unit

      - name: Run integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

## Coverage Analysis

### Jest Coverage

```bash
# Run with coverage
npm test -- --coverage

# Coverage thresholds in package.json
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

### pytest Coverage

```bash
# Run with coverage
pytest --cov=src --cov-report=html --cov-report=term

# Config in .coveragerc
[run]
source = src
omit = */tests/*

[report]
fail_under = 80
```

## Best Practices

1. **Test behavior, not implementation**
2. **One assertion concept per test**
3. **Make tests independent** (no shared state)
4. **Use descriptive test names**
5. **Keep tests fast** (parallelize when possible)
6. **Mock external dependencies** (APIs, databases in unit tests)
7. **Test edge cases and error paths**
8. **Avoid test duplication**
9. **Clean up resources** (use fixtures/teardown)
10. **Keep tests maintainable** (DRY principle applies)
