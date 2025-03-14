/**
 * Feature Flag Control Test
 * 
 * This test demonstrates how to use the new test infrastructure components,
 * including TestServiceRegistry and FeatureFlagTestContext.
 */

// Import jest from the central instance
const jestInstance = require('../../helpers/jestInstance.cjs');
const { describe, test, expect, beforeAll, afterAll, beforeEach, afterEach } = jestInstance;
const {
  connectToTestDatabase,
  disconnectFromTestDatabase,
  cleanupTestData,
  featureFlagContext,
  createTestUser,
  createTestVenue
} = require('../../helpers/testSetup.cjs');

// Import the service we want to test
const User = require('../../../models/User.cjs');

describe('Feature Flag Control Example', () => {
  // Set up database connection before all tests
  beforeAll(async () => {
    await connectToTestDatabase();
    await featureFlagContext.initialize();
  });

  // Clean up after each test
  afterEach(async () => {
    await cleanupTestData();
    await featureFlagContext.resetAll();
    testServiceRegistry.resetAllMocks();
  });

  // Disconnect after all tests
  afterAll(async () => {
    await disconnectFromTestDatabase();
    await testServiceRegistry.cleanup();
  });

  test('should allow staff role when USE_CLIENT_SIDE_VERIFICATION is enabled', async () => {
    // Set up feature flag for this test
    await featureFlagContext.enableFeature('USE_CLIENT_SIDE_VERIFICATION');
    
    // Create a user with staff role
    const userData = {
      email: 'staff@example.com',
      firstName: 'Staff',
      lastName: 'User',
      role: 'staff',
      verifiedBy: 'system'
    };
    
    // This should succeed when the feature flag is enabled
    const user = await createTestUser(userData);
    
    // Verify the user was created with staff role
    expect(user.role).toBe('staff');
    expect(user._id).toBeDefined();
  });

  test('should reject staff role when USE_CLIENT_SIDE_VERIFICATION is disabled', async () => {
    // Ensure feature flag is disabled
    await featureFlagContext.disableFeature('USE_CLIENT_SIDE_VERIFICATION');
    
    // Create a user with staff role
    const userData = {
      email: 'staff2@example.com',
      firstName: 'Staff',
      lastName: 'User',
      role: 'staff',
      verifiedBy: 'system'
    };
    
    // This should fail when the feature flag is disabled
    let error;
    try {
      await createTestUser(userData);
    } catch (e) {
      error = e;
    }
    
    // Verify the error
    expect(error).toBeDefined();
    expect(error.name).toBe('ValidationError');
    expect(error.message).toContain('Staff role is not allowed when USE_CLIENT_SIDE_VERIFICATION is disabled');
  });

  test('demonstrates using TestServiceRegistry for dependency mocking', async () => {
    // Create a mock implementation of the feature manager
    const mockFeatureManager = {
      isEnabled: jest.fn().mockImplementation((feature, context) => {
        if (feature === 'USE_CLIENT_SIDE_VERIFICATION') {
          return true; // Always enable this feature in our mock
        }
        return false;
      }),
      getFeatureState: jest.fn().mockResolvedValue({
        enabled: true,
        description: 'Mocked feature state'
      }),
      getFeatureStates: jest.fn().mockResolvedValue({
        'USE_CLIENT_SIDE_VERIFICATION': {
          enabled: true,
          description: 'Mocked feature state'
        }
      })
    };
    
    // Register the mock feature manager
    testServiceRegistry.registerMock('feature-manager', mockFeatureManager);
    
    // Create a user with staff role - should work with our mock
    const userData = {
      email: 'staff3@example.com',
      firstName: 'Staff',
      lastName: 'User',
      role: 'staff',
      verifiedBy: 'system'
    };
    
    const user = await createTestUser(userData);
    
    // Verify the user was created with staff role
    expect(user.role).toBe('staff');
    
    // Verify our mock was called
    expect(mockFeatureManager.isEnabled).toHaveBeenCalledWith(
      'USE_CLIENT_SIDE_VERIFICATION',
      expect.any(Object)
    );
  });

  test('demonstrates using custom dependency injection', async () => {
    // Create a function that needs dependencies
    const mockVenueService = {
      getVenueDetails: jest.fn().mockImplementation(async (venueId) => {
        return {
          id: venueId,
          name: 'Mocked Venue',
          capacity: 500
        };
      })
    };
    
    // Register the mock venue service
    testServiceRegistry.registerMock('venue-service', mockVenueService);
    
    // Create a function that uses our getDependency function
    const getDependency = testServiceRegistry.createDependencyGetter();
    
    async function checkVenueAccess(venueId, userId) {
      // Get venue service using dependency injection
      const venueService = getDependency('venue-service');
      
      // Use the service
      const venue = await venueService.getVenueDetails(venueId);
      
      // Check if venue exists
      if (!venue) {
        return false;
      }
      
      // In a real implementation, we would check if the user has access
      return true;
    }
    
    // Test our function
    const venueId = 'venue123';
    const result = await checkVenueAccess(venueId, 'user456');
    
    // Verify the result
    expect(result).toBe(true);
    
    // Verify our mock was called with the correct arguments
    expect(mockVenueService.getVenueDetails).toHaveBeenCalledWith(venueId);
  });
});

// Example of a more complex test with multiple feature flags
describe('Complex Feature Flag Interactions', () => {
  // Setup with multiple feature flags
  beforeAll(async () => {
    await connectToTestDatabase();
    await featureFlagContext.initialize();
    
    // Set up multiple feature flags
    await featureFlagContext.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', {
      enabled: true,
      rolloutPercentage: 100
    });
    
    await featureFlagContext.setFeatureState('USE_NEW_PAYMENT_PROCESSOR', {
      enabled: true,
      rolloutPercentage: 50
    });
  });
  
  afterAll(async () => {
    await featureFlagContext.resetAll();
    await disconnectFromTestDatabase();
  });
  
  test('demonstrates setting up a test environment with multiple features', async () => {
    // Verify feature flags are set correctly
    expect(await featureFlagContext.isEnabled('USE_CLIENT_SIDE_VERIFICATION')).toBe(true);
    expect(await featureFlagContext.isEnabled('USE_NEW_PAYMENT_PROCESSOR')).toBe(true);
    
    // Create a mock feature manager using our context
    const mockFeatureManager = featureFlagContext.createMockFeatureManager();
    
    // Register it with the service registry
    testServiceRegistry.registerMock('feature-manager', mockFeatureManager);
    
    // Now any service that uses the feature manager will use our mock
    const isVerificationEnabled = await mockFeatureManager.isEnabled('USE_CLIENT_SIDE_VERIFICATION');
    expect(isVerificationEnabled).toBe(true);
    
    // Check that the mock recorded the call
    expect(mockFeatureManager.isEnabled).toHaveBeenCalledWith('USE_CLIENT_SIDE_VERIFICATION', {});
  });
}); 