# FOMO API Test Infrastructure

This directory contains the enhanced test infrastructure for the FOMO API. These utilities make it easier to write consistent, reliable tests with proper isolation between test cases.

## Core Components

### 1. TestServiceRegistry

The `TestServiceRegistry` helps manage dependencies in tests, allowing you to substitute mock implementations without modifying application source code.

Key features:
- Register mock implementations for services
- Auto-create mocks on demand for services that aren't explicitly registered
- Preserve the API of original services in mocks
- Reset mocks between tests
- Create dependency getter functions that can be used in place of `getDependency`

```javascript
const { testServiceRegistry } = require('../helpers/testSetup.cjs');

// Register a mock
testServiceRegistry.registerMock('payment-processor', mockPaymentProcessor);

// Get a dependency
const paymentProcessor = testServiceRegistry.getService('payment-processor');

// Create a dependency getter for injection into services
const getDependency = testServiceRegistry.createDependencyGetter();
```

### 2. FeatureFlagTestContext

The `FeatureFlagTestContext` provides a controlled environment for feature flags in tests. It allows you to temporarily enable or disable specific features without affecting other tests.

Key features:
- Enable or disable feature flags for specific tests
- Set complex feature flag states
- Reset flags to their original states after tests
- Create mock feature managers that use the context

```javascript
const { featureFlagContext } = require('../helpers/testSetup.cjs');

// Initialize the context
await featureFlagContext.initialize();

// Enable a feature flag
await featureFlagContext.enableFeature('USE_CLIENT_SIDE_VERIFICATION');

// Disable a feature flag
await featureFlagContext.disableFeature('USE_NEW_PAYMENT_PROCESSOR');

// Set complex state
await featureFlagContext.setFeatureState('USE_NEW_AUTH', {
  enabled: true,
  rolloutPercentage: 50,
  config: { allowLegacyFallback: true }
});

// Reset all flags
await featureFlagContext.resetAll();
```

### 3. Enhanced Model Factories

The enhanced model factories create valid test data for all models with comprehensive defaults that pass validation.

Key features:
- Generate objects with all required fields populated
- Deep merge with custom overrides
- Ensure relationships between models are consistent
- Prevent common validation errors

```javascript
const { 
  createTestUserData, 
  createTestVenueData, 
  createTestPassData,
  createTestOrderLockData,
  createTestOrderData,
  createTestPaymentData
} = require('./testFactories.cjs');

// Create test data with defaults
const userData = createTestUserData();

// Create test data with overrides
const venueData = createTestVenueData({
  name: 'Custom Venue',
  capacity: 1000,
  location: {
    city: 'New York'
  }
});
```

## Usage Examples

### Basic Test Setup

```javascript
const { describe, test, beforeAll, afterAll, afterEach } = require('@jest/globals');
const {
  connectToTestDatabase,
  disconnectFromTestDatabase,
  cleanupTestData,
  createTestUser,
  createTestVenue
} = require('../helpers/testSetup.cjs');

describe('My Test Suite', () => {
  beforeAll(async () => {
    await connectToTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestData();
  });

  afterAll(async () => {
    await disconnectFromTestDatabase();
  });

  test('should do something', async () => {
    // Create test data
    const user = await createTestUser();
    const venue = await createTestVenue();
    
    // Run tests...
  });
});
```

### Using Feature Flags in Tests

```javascript
const { describe, test, beforeAll, afterAll, afterEach } = require('@jest/globals');
const {
  connectToTestDatabase,
  disconnectFromTestDatabase,
  cleanupTestData,
  featureFlagContext,
  createTestUser
} = require('../helpers/testSetup.cjs');

describe('Feature Flag Tests', () => {
  beforeAll(async () => {
    await connectToTestDatabase();
    await featureFlagContext.initialize();
  });

  afterEach(async () => {
    await cleanupTestData();
    await featureFlagContext.resetAll();
  });

  afterAll(async () => {
    await disconnectFromTestDatabase();
  });

  test('with feature enabled', async () => {
    // Enable the feature for this test
    await featureFlagContext.enableFeature('USE_NEW_FEATURE');
    
    // Run tests...
  });

  test('with feature disabled', async () => {
    // Disable the feature for this test
    await featureFlagContext.disableFeature('USE_NEW_FEATURE');
    
    // Run tests...
  });
});
```

### Using Dependency Mocking

```javascript
const { describe, test, beforeAll, afterAll, afterEach } = require('@jest/globals');
const {
  connectToTestDatabase,
  disconnectFromTestDatabase,
  cleanupTestData,
  testServiceRegistry
} = require('../helpers/testSetup.cjs');
const PaymentService = require('../../services/payment/PaymentService.cjs');

describe('Payment Service Tests', () => {
  beforeAll(async () => {
    await connectToTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestData();
    testServiceRegistry.resetAllMocks();
  });

  afterAll(async () => {
    await disconnectFromTestDatabase();
    await testServiceRegistry.cleanup();
  });

  test('should process payment', async () => {
    // Create mock stripe service
    const mockStripe = {
      paymentIntents: {
        create: jest.fn().mockResolvedValue({
          id: 'pi_test123',
          client_secret: 'cs_test123',
          amount: 5000
        })
      }
    };
    
    // Register the mock
    testServiceRegistry.registerMock('stripe', mockStripe);
    
    // Create a PaymentService instance with our mock
    const paymentService = new PaymentService();
    paymentService.getDependency = testServiceRegistry.createDependencyGetter();
    
    // Call the service method that uses Stripe
    const result = await paymentService.createPaymentIntent({
      amount: 5000,
      currency: 'usd'
    });
    
    // Verify the result
    expect(result.id).toBe('pi_test123');
    
    // Verify the mock was called correctly
    expect(mockStripe.paymentIntents.create).toHaveBeenCalledWith({
      amount: 5000,
      currency: 'usd'
    });
  });
});
```

## Simplified Test Helpers

For convenience, `testSetup.cjs` also provides some simplified setup/teardown helpers:

```javascript
const { describe, test } = require('@jest/globals');
const { createTestSetup, createTestTeardown } = require('../helpers/testSetup.cjs');

describe('Simplified Test Setup', () => {
  // Use the simplified helpers
  beforeAll(createTestSetup({
    // Mock services to register
    services: {
      'stripe': mockStripe,
      'payment-processor': mockPaymentProcessor
    },
    // Feature flags to set
    features: {
      'USE_NEW_PAYMENT_PROCESSOR': true,
      'USE_CLIENT_SIDE_VERIFICATION': false
    },
    // Seed data to create
    seedData: {
      users: [{ email: 'test@example.com' }],
      venues: [{ name: 'Test Venue' }]
    }
  }));
  
  afterAll(createTestTeardown());
  
  test('should do something', async () => {
    // Run tests...
  });
});
```

## Best Practices

1. **Reset state between tests**: Always clean up resources and reset state between tests to maintain isolation.

2. **Use factories instead of direct model creation**: Use the factory functions to create test data to ensure it's valid.

3. **Mock dependencies, not internal implementation**: Mock the dependencies of the service you're testing, not its internal implementation.

4. **Be explicit about feature flag states**: Always explicitly set the state of feature flags your test depends on.

5. **Keep tests focused**: Each test should focus on a single aspect of behavior.

6. **Use the simplified helpers for common scenarios**: The `createTestSetup` and `createTestTeardown` helpers handle common setup/teardown tasks.

7. **Don't modify source code for testing**: Use the TestServiceRegistry to substitute dependencies instead of modifying source code.

8. **Document test assumptions**: Include comments explaining any assumptions your test makes about the environment or feature states.

## Troubleshooting

**Q: Why is my test failing with a validation error?**  
A: The model schema might have changed. Check if there are new required fields and update the factory function or your test data accordingly.

**Q: How do I mock a service that isn't registered?**  
A: Use `testServiceRegistry.registerMock('service-name', mockImplementation)` to register a mock for any service.

**Q: How do I ensure my mock has the right methods?**  
A: You can use `preserveApi: true` when registering a mock to ensure it preserves the API of the original service:
```javascript
testServiceRegistry.registerMock('service-name', mockImplementation, true);
```

**Q: My test is affecting other tests - how do I fix this?**  
A: Make sure you're cleaning up data and resetting state in `afterEach`. Use `cleanupTestData()`, `featureFlagContext.resetAll()`, and `testServiceRegistry.resetAllMocks()` to ensure a clean state for each test. 