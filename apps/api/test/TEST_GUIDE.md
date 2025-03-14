# FOMO API Testing Guide

## Table of Contents
- [Test Infrastructure Overview](#test-infrastructure-overview)
- [Recommended Testing Approach](#recommended-testing-approach)
- [Environment Variables](#environment-variables)
- [Common Issues and Solutions](#common-issues-and-solutions)
- [Test Types](#test-types)
- [Adding New Tests](#adding-new-tests)
- [Test Structure Best Practices](#test-structure-best-practices)
- [Debugging Tests](#debugging-tests)
- [Core Test Components](#core-test-components)
- [Mocking](#mocking)
- [AuthN/AuthZ Testing](#authnauth-testing)
- [Database Testing](#database-testing)
- [Continuous Integration](#continuous-integration)

## Test Infrastructure Overview

The FOMO API uses a sophisticated test infrastructure with several key components:

1. **Custom Test Runner** - Located at `test/scripts/run-tests.js`
2. **Jest Configuration** - Located at `test/config/jest.config.cjs` 
3. **Test Environment Setup** - Located at `test/config/setupAfterEnv.cjs`
4. **Mock Registry** - Located at `test/helpers/MockRegistry.cjs`
5. **Feature Flag Test Context** - Located at `test/helpers/FeatureFlagTestContext.cjs`

### Directory Structure

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
│   └── RequestResponseHelpers.cjs # Request/response mocking
├── mocks/                   # Mock implementations
│   ├── stripe.mock.cjs      # Stripe API mock
│   └── socket.mock.cjs      # Socket.IO mock
├── unit/                    # Unit tests
├── integration/             # Integration tests
└── e2e/                     # End-to-end tests
```

## Recommended Testing Approach

### Running Tests

**Always use the custom test runner** to ensure proper initialization of the test environment:

```bash
# Run all unit tests (recommended)
node test/scripts/run-tests.js --unit

# Run a specific test file
node test/scripts/run-tests.js --testPathPattern=userModel.test.cjs

# Run a specific test case
node test/scripts/run-tests.js --testNamePattern="should handle array of roles correctly"
```

**Avoid running Jest directly** as it may bypass critical initialization steps.

### Quick Reference Commands

```bash
# Run all tests
npm test

# Run only unit tests
npm run test:unit

# Run only integration tests
npm run test:integration

# Run only end-to-end tests
npm run test:e2e

# List all tests without running them
node test/scripts/run-tests.js --list-only

# Run Phase 3 tests
bash test/scripts/run-phase3-tests.sh

# Run Phase 5 tests
bash test/scripts/run-phase5-tests.sh
```

### Initialization Sequence

The test environment initialization follows this sequence:

1. Mock Registry initialization and application of mocks
2. Feature Flag Context initialization and registration of critical features
3. Database connection establishment
4. Test execution

This sequence ensures that all dependencies are properly set up before tests run.

## Environment Variables

When running tests, certain environment variables can be set:

| Variable | Purpose | Default |
|----------|---------|---------|
| `NODE_ENV` | Set environment to test | `test` |
| `USE_MEMORY_DB` | Use in-memory MongoDB | `true` |
| `MONGODB_URI` | Override test database URI | `mongodb://localhost:27017/fomo_test` |
| `LOG_LEVEL` | Control test logging | `error` |
| `MONGO_CONNECTION_TIMEOUT` | Connection timeout (ms) | `30000` |
| `DISABLE_TEST_MOCKS` | Skip mock initialization | `false` |

## Common Issues and Solutions

### Socket.io Mock Issues

If you encounter errors related to socket.io mocks:

```
TypeError: mockRegistry.setupJestMock is not a function
```

**Solution:**
- Use the custom test runner which properly initializes the mock registry
- Check that `MockRegistry.normalizeSocketIOMock()` is properly handling the mock
- Run a specific test to isolate the issue:
```bash
node test/scripts/run-tests.js --testPathPattern=socket.test.cjs
```

### Feature Flag Issues

If tests fail due to missing feature flags:

```
Feature not found: USE_CLIENT_SIDE_VERIFICATION
```

**Solution:**
- Ensure that the test is using the `FeatureFlagTestContext` to initialize required features before accessing them
- Add the following to your test setup:
```javascript
beforeAll(async () => {
  await featureFlagContext.enableFeature('USE_CLIENT_SIDE_VERIFICATION');
})
```

### Database Connection Issues

If tests fail due to database connection timeouts:

```
Connection timeout after 30000ms
```

**Solution:**
- Try increasing the connection timeout:
```bash
MONGO_CONNECTION_TIMEOUT=60000 node test/scripts/run-tests.js --unit
```
- Check database connection stability with a helper:
```javascript
beforeEach(async () => {
  if (mongoose.connection.readyState !== 1) {
    console.log('[TEST] Reconnecting database before test...');
    await dbConnectionManager.connect();
  }
})
```

### Role Validation Issues

If tests related to user roles are failing:

**Solution:**
1. Check the implementation of `hasRole` in `models/User.cjs`
2. Ensure the `USE_CLIENT_SIDE_VERIFICATION` feature flag is properly registered
3. Run specific tests with increased verbosity:
```bash
node test/scripts/run-tests.js --testPathPattern=User.test.cjs --verbose
```

### Service Initialization Issues

If tests fail with service initialization errors:

```
Service initialization failed: Required dependency X not found
```

**Solution:**
1. Check the `TestServiceRegistry` and ensure all required dependencies are registered
2. Verify the mock initialization sequence in `setupAfterEnv.cjs`
3. Add manual logging to track service initialization:
```javascript
console.log(`[SERVICE] Dependencies for ${serviceName}:`, service.dependencies);
```

### Payment Processing Issues

If you see payment errors in tests:

```
Error: Circuit open
Error: Card declined
```

**Note:** These errors often appear in passing tests and are expected to validate error handling. Check if the test is actually failing or just testing error paths.

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

End-to-end tests test the entire application from the outside.

## Adding New Tests

When adding new tests:

1. Use the appropriate test helper functions from `test/helpers/testSetup.cjs`
2. Ensure all required mocks are registered via `mockRegistry.registerServiceMock()`
3. Initialize feature flags that your test depends on
4. Clean up resources in afterEach/afterAll hooks

## Test Structure Best Practices

1. **Isolation**: Tests should be independent of each other
2. **Mock Registration**: Register all required mocks before tests run
3. **Feature Flag Initialization**: Initialize feature flags that your test depends on
4. **Resource Cleanup**: Clean up resources after tests to avoid affecting other tests

## Debugging Tests

To debug a specific test:

```bash
# Run with Node inspector
node --inspect-brk test/scripts/run-tests.js --testPathPattern=userModel.test.cjs
```

Then connect to the debugger using Chrome DevTools or VS Code.

Additional debugging techniques:
1. Use `console.log` to debug test issues with descriptive prefixes
2. Inspect request and response objects with `console.dir(obj, { depth: null })`
3. Run tests with `--verbose` to see more details
4. Run one test at a time with `--testNamePattern="exact test name"`
5. Set `MONGOOSE_DEBUG=true` to see database operations

## Core Test Components

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
```

### Feature Flag Context

The `FeatureFlagTestContext` provides a way to test feature flags in isolation:

```javascript
const { featureFlagContext } = require('../helpers/testSetup.cjs');

// Enable a feature flag
await featureFlagContext.enableFeature('newPaymentFlow');

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

// Reset all mocks
mockRegistry.resetAllMocks();
```

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

## AuthN/AuthZ Testing

### Creating Authenticated Users

```javascript
const { 
  createAuthenticatedUser, 
  createAuthenticatedAdmin 
} = require('../helpers/testSetup.cjs');

// Create a regular authenticated user
const { user, token } = await createAuthenticatedUser();
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
```

## Continuous Integration

In CI environments, tests are run with:

```bash
NODE_ENV=test npm test
```

which uses the custom test runner with appropriate environment variables. 