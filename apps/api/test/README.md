# FOMO API Test Framework

This directory contains the test framework for the FOMO API. The framework provides utilities for testing various components of the API, including unit tests, integration tests, and end-to-end tests.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Core Components](#core-components)
- [Test Types](#test-types)
- [Best Practices](#best-practices)
- [Mocking](#mocking)
- [AuthN/AuthZ Testing](#authn/authz-testing)
- [API Testing](#api-testing)
- [Database Testing](#database-testing)
- [Troubleshooting](#troubleshooting)

## Overview

The FOMO API test framework is designed to make testing as simple and maintainable as possible. It provides utilities for:

- Setting up test environments
- Creating test data
- Mocking external dependencies
- Testing API routes
- Testing authentication
- Testing database operations

## Directory Structure

```
test/
├── config/                  # Test configuration
│   ├── jest.config.cjs      # Jest configuration
│   ├── setup.cjs            # Global setup script
│   ├── teardown.cjs         # Global teardown script
│   └── setupAfterEnv.cjs    # Setup file for all tests
├── helpers/                 # Test helper utilities
│   ├── testSetup.cjs        # Core test setup utilities 
│   ├── testFactories.cjs    # Factories for creating test data
│   ├── TestServiceRegistry.cjs # Service dependency management
│   ├── FeatureFlagTestContext.cjs # Feature flag testing
│   ├── MockRegistry.cjs     # External service mocking
│   ├── RequestResponseHelpers.cjs # Request/response mocking
│   ├── ApiTestHelper.cjs    # API testing utilities
│   └── AuthTestHelper.cjs   # Authentication testing
├── mocks/                   # Mock implementations
│   ├── stripe.mock.cjs      # Stripe API mock
│   ├── mongodb.mock.cjs     # MongoDB mock
│   └── circuitBreaker.mock.cjs # Circuit breaker mock
├── unit/                    # Unit tests
├── integration/             # Integration tests
├── e2e/                     # End-to-end tests
└── README.md                # This file
```

## Core Components

### Test Service Registry

The `TestServiceRegistry` provides a way to manage service dependencies in tests. It allows you to:

- Register mock implementations of services
- Get dependencies in a consistent way
- Reset mocks between tests

```javascript
const { testServiceRegistry } = require('../helpers/testSetup.cjs');

// Register a mock service
testServiceRegistry.registerMock('emailService', {
  sendEmail: jest.fn().mockResolvedValue({ success: true })
});

// Get a dependency
const emailService = testServiceRegistry.getDependency('emailService');

// Reset all mocks
testServiceRegistry.resetAllMocks();
```

### Feature Flag Context

The `FeatureFlagTestContext` provides a way to test feature flags in isolation:

```javascript
const { featureFlagContext } = require('../helpers/testSetup.cjs');

// Enable a feature flag
await featureFlagContext.enableFeature('newPaymentFlow');

// Disable a feature flag
await featureFlagContext.disableFeature('beta');

// Reset all feature flags
await featureFlagContext.resetAll();
```

### Mock Registry

The `MockRegistry` provides a centralized way to manage mocks of external services:

```javascript
const { mockRegistry, stripeMock } = require('../helpers/testSetup.cjs');

// Configure stripe mock
stripeMock.configure({
  shouldFailOnOperation: false,
  delayMs: 0
});

// Reset stripe mock
stripeMock.reset();

// Reset all mocks
mockRegistry.resetAllMocks();
```

### Request/Response Helpers

The `RequestResponseHelpers` module provides utilities for mocking Express request and response objects:

```javascript
const { 
  createMockRequest, 
  createMockResponse, 
  runMiddleware 
} = require('../helpers/testSetup.cjs');

// Create a mock request
const req = createMockRequest({
  method: 'GET',
  path: '/api/users',
  query: { limit: 10 },
  user: { id: '123', role: 'admin' }
});

// Create a mock response
const res = createMockResponse();

// Run middleware
const result = await runMiddleware(authMiddleware, { req });
```

### Auth Testing

The `AuthTestHelper` provides utilities for testing authentication:

```javascript
const { authTestHelper } = require('../helpers/testSetup.cjs');

// Generate a valid token
const token = authTestHelper.generateAuthToken(user);

// Generate an expired token
const expiredToken = authTestHelper.generateExpiredToken(user);

// Verify a token
const decoded = authTestHelper.verifyAuthToken(token);
```

### API Testing

The `ApiTestHelper` provides utilities for testing API routes:

```javascript
const { createApiTestHelper } = require('../helpers/testSetup.cjs');

// Create an API test helper for a route handler
const apiHelper = createApiTestHelper(userController.getUsers);

// Test GET request
const response = await apiHelper.get({
  query: { limit: 10 },
  user: adminUser
});

// Check response
expect(response.statusCode).toBe(200);
expect(response.data.users).toHaveLength(10);
```

## Test Types

### Unit Tests

Unit tests test individual functions or classes in isolation. They should be fast and not depend on external services or the database.

Example:

```javascript
const { resetAllMocks } = require('../../helpers/testSetup.cjs');

describe('calculateTotal', () => {
  beforeEach(() => {
    resetAllMocks();
  });

  test('adds items correctly', () => {
    const result = calculateTotal([10, 20, 30]);
    expect(result).toBe(60);
  });
});
```

### Integration Tests

Integration tests test how components work together. They may use the database and external services (typically mocked).

Example:

```javascript
const { 
  createTestSetup, 
  createTestTeardown, 
  createTestUser 
} = require('../../helpers/testSetup.cjs');

const testSetup = createTestSetup();
const testTeardown = createTestTeardown();

describe('User service', () => {
  let testUser;

  beforeAll(async () => {
    await testSetup();
    testUser = await createTestUser();
  });

  afterAll(async () => {
    await testTeardown();
  });

  test('gets user by ID', async () => {
    const result = await userService.getUserById(testUser._id);
    expect(result).toEqual(expect.objectContaining({
      email: testUser.email
    }));
  });
});
```

### E2E Tests

End-to-end tests test the entire application from the outside. They typically use Supertest to make HTTP requests to the app.

Example:

```javascript
const request = require('supertest');
const { app } = require('../../app.cjs');
const { 
  createTestSetup, 
  createTestTeardown, 
  createAuthenticatedUser 
} = require('../helpers/testSetup.cjs');

const testSetup = createTestSetup();
const testTeardown = createTestTeardown();

describe('User API', () => {
  let authData;

  beforeAll(async () => {
    await testSetup();
    authData = await createAuthenticatedUser({ role: 'admin' });
  });

  afterAll(async () => {
    await testTeardown();
  });

  test('gets users', async () => {
    const response = await request(app)
      .get('/api/users')
      .set('Authorization', `Bearer ${authData.token}`);

    expect(response.status).toBe(200);
    expect(response.body.users).toBeDefined();
  });
});
```

## Best Practices

1. **Use the test setup utilities**: They handle common tasks like database setup, cleanup, and mock registration.
2. **Reset mocks between tests**: Use `beforeEach(() => resetAllMocks())` to ensure tests don't affect each other.
3. **Create test data with factories**: Use the factories in `testFactories.cjs` to create consistent test data.
4. **Mock external dependencies**: Don't test external services like Stripe or MongoDB directly.
5. **Clean up after tests**: Always clean up the database and reset mocks after tests.
6. **Use descriptive test names**: Test names should describe what the test is checking.
7. **Test error cases**: Test both success and error cases for every function.

## Mocking

### Service Mocking

Use the MockRegistry to register and manage mocks:

```javascript
const { mockRegistry } = require('../helpers/testSetup.cjs');

// Register a custom mock
mockRegistry.registerServiceMock('paymentGateway', {
  processPayment: jest.fn().mockResolvedValue({ success: true }),
  refund: jest.fn().mockResolvedValue({ success: true })
});

// Apply mocks to Jest
mockRegistry.applyMocks();
```

### Stripe Mocking

The `stripe.mock.cjs` file provides a comprehensive mock of the Stripe API:

```javascript
const { stripeMock } = require('../helpers/testSetup.cjs');

// Configure Stripe mock
stripeMock.configure({
  shouldFailOnOperation: false,
  simulateNetworkPartition: false
});

// Use the mock
const result = await stripeMock.paymentIntents.create({
  amount: 2000,
  currency: 'usd',
  metadata: {
    userId: '123',
    venueId: '456'
  }
});

// Reset the mock
stripeMock.reset();
```

## AuthN/AuthZ Testing

### Creating Authenticated Users

```javascript
const { 
  createAuthenticatedUser, 
  createAuthenticatedAdmin 
} = require('../helpers/testSetup.cjs');

// Create a regular authenticated user
const { user, token } = await createAuthenticatedUser();

// Create an admin user
const { user: admin, token: adminToken } = await createAuthenticatedAdmin();
```

### Testing Middleware

```javascript
const { runMiddleware } = require('../helpers/testSetup.cjs');

// Test a middleware function
const result = await runMiddleware(authMiddleware, {
  req: {
    headers: {
      authorization: `Bearer ${token}`
    }
  }
});

// Check results
expect(result.wasNext).toBe(true);
expect(result.req.user).toBeDefined();
```

## API Testing

### Direct Route Handler Testing

```javascript
const { createApiTestHelper } = require('../helpers/testSetup.cjs');

// Create a helper for the route handler
const apiHelper = createApiTestHelper(userController.updateUser);

// Test the route handler directly
const result = await apiHelper.put({
  params: { id: '123' },
  body: { name: 'New Name' },
  user: adminUser
});

// Assert on the response
expect(result.statusCode).toBe(200);
expect(result.data).toEqual(expect.objectContaining({
  name: 'New Name'
}));
```

### Supertest for HTTP Testing

```javascript
const request = require('supertest');
const { app } = require('../../app.cjs');

// Make a real HTTP request to the app
const response = await request(app)
  .get('/api/users')
  .set('Authorization', `Bearer ${token}`);

// Assert on the response
expect(response.status).toBe(200);
expect(response.body.users).toBeDefined();
```

## Database Testing

### Memory Database

The test framework uses an in-memory MongoDB server for testing:

```javascript
const { 
  connectToTestDatabase, 
  cleanupTestData, 
  disconnectFromTestDatabase 
} = require('../helpers/testSetup.cjs');

// Connect to the test database
await connectToTestDatabase();

// Clean up data
await cleanupTestData();

// Disconnect
await disconnectFromTestDatabase();
```

### MongoDB Mocking

For tests that need fine-grained control, use the MongoDB mock:

```javascript
const { mongodbMock } = require('../helpers/testSetup.cjs');

// Configure the mock
mongodbMock.configure({
  shouldFailOnOperation: false,
  failureRate: 0
});

// Reset the mock
mongodbMock.reset();
```

## Troubleshooting

### Common Issues

1. **Tests affecting each other**: Make sure to use `beforeEach(() => resetAllMocks())` to reset mocks between tests.
2. **Database issues**: Check if the MongoDB memory server is running. Use `connectToTestDatabase()` to connect.
3. **Auth issues**: Make sure you're using a valid token. Use `createAuthenticatedUser()` to get a valid token.
4. **Mocking issues**: Check if you're using the correct mock functions. Reset mocks between tests.

### Debugging Tips

1. Use `console.log` to debug test issues.
2. Inspect request and response objects with `console.dir(obj, { depth: null })`.
3. Run tests with `--verbose` to see more details.
4. Run a single test with `npm test -- -t 'test name'`.

### Getting Help

If you're having trouble with the test framework, contact the maintainers:

- Open an issue on the repo
- Ask in the #testing channel on Slack 