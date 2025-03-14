/**
 * @test Phase 3 - Data Model Updates - User Model Tests
 * 
 * This test suite verifies that the User model has been correctly updated
 * to handle the feature flag for role enum as part of Phase 3 data model updates.
 */

const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const { User } = require('../../models/User.cjs');
const featureManager = require('../../services/payment/FeatureManager.cjs');
const { connectToTestDatabase, cleanupTestData } = require('../helpers/testSetup.cjs');
const featureFlagContext = require('../helpers/FeatureFlagTestContext.cjs');

// Enhanced initialization helper for User model tests
async function initializeFeatureFlags(enabled = true) {
  console.log(`[TEST] Initializing feature flags with USE_CLIENT_SIDE_VERIFICATION=${enabled}`);
  
  try {
    // First check if FeatureFlagTestContext is initialized
    await featureFlagContext.initialize();
    console.log('[TEST] FeatureFlagTestContext initialized');
    
    // Use both mechanisms to ensure the flag is properly set
    if (enabled) {
      await featureFlagContext.setFeature('USE_CLIENT_SIDE_VERIFICATION', true, {
        rolloutPercentage: 100,
        description: 'Test: Enable client-side verification'
      });
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', {
        enabled: true,
        rolloutPercentage: 100,
        description: 'Test: Enable client-side verification'
      });
    } else {
      await featureFlagContext.setFeature('USE_CLIENT_SIDE_VERIFICATION', false, {
        rolloutPercentage: 0,
        description: 'Test: Disable client-side verification'
      });
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', {
        enabled: false,
        rolloutPercentage: 0,
        description: 'Test: Disable client-side verification'
      });
    }
    
    // Verify feature flag state
    const flagState = await featureManager.getFeatureState('USE_CLIENT_SIDE_VERIFICATION');
    
    console.log('[TEST] Feature flag state (FeatureManager):', flagState);
    
    return flagState;
  } catch (error) {
    console.error('[TEST] Error initializing feature flags:', error);
    throw error;
  }
}

describe('User Model (Phase 3)', () => {
  beforeAll(async () => {
    await connectToTestDatabase();
    // Initialize feature flags with default state
    await initializeFeatureFlags(true);
  });

  afterAll(async () => {
    await cleanupTestData();
    await mongoose.connection.close();
  });

  afterEach(async () => {
    await User.deleteMany({ email: /^test-.*@example.com$/ });
  });

  describe('Feature Flag Integration', () => {
    test('should allow staff role when feature flag is enabled', async () => {
      // Enable the feature flag explicitly for this test
      await initializeFeatureFlags(true);
      
      const user = new User({
        name: 'Test Staff',
        email: `test-${Date.now()}@example.com`,
        role: 'staff',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await user.save();
      
      const savedUser = await User.findById(user._id);
      expect(savedUser.role).toBe('staff');
    });

    test('should allow bartender role when feature flag is disabled', async () => {
      // Disable the feature flag explicitly for this test
      await initializeFeatureFlags(false);
      
      const user = new User({
        name: 'Test Bartender',
        email: `test-${Date.now()}@example.com`,
        role: 'bartender',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await user.save();
      
      const savedUser = await User.findById(user._id);
      expect(savedUser.role).toBe('bartender');
    });

    test('should reject staff role when feature flag is disabled', async () => {
      // Disable the feature flag explicitly for this test
      await initializeFeatureFlags(false);
      
      const user = new User({
        name: 'Test Invalid Staff',
        email: `test-${Date.now()}@example.com`,
        role: 'staff',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await expect(user.save()).rejects.toThrow();
    });

    test('should reject bartender role when feature flag is enabled', async () => {
      // Enable the feature flag explicitly for this test
      await initializeFeatureFlags(true);
      
      const user = new User({
        name: 'Test Invalid Bartender',
        email: `test-${Date.now()}@example.com`,
        role: 'bartender',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await expect(user.save()).rejects.toThrow();
    });
  });

  describe('hasRole Method', () => {
    test('should recognize staff role as equivalent to bartender when checking hasRole', async () => {
      // Enable the feature flag explicitly for this test
      await initializeFeatureFlags(true);
      
      const user = new User({
        name: 'Test Staff',
        email: `test-${Date.now()}@example.com`,
        role: 'staff',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await user.save();
      
      // Staff should be recognized as having bartender role
      const hasBartenderRole = await user.hasRole('bartender');
      console.log(`[TEST] Staff has bartender role: ${hasBartenderRole}`);
      expect(hasBartenderRole).toBe(true);
      
      // Staff should be recognized as having staff role
      const hasStaffRole = await user.hasRole('staff');
      console.log(`[TEST] Staff has staff role: ${hasStaffRole}`);
      expect(hasStaffRole).toBe(true);
    });

    test('should recognize bartender role as equivalent to staff when checking hasRole', async () => {
      // Disable the feature flag explicitly for this test
      await initializeFeatureFlags(false);
      
      const user = new User({
        name: 'Test Bartender',
        email: `test-${Date.now()}@example.com`,
        role: 'bartender',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await user.save();
      
      // Bartender should be recognized as having staff role
      const hasStaffRole = await user.hasRole('staff');
      console.log(`[TEST] Bartender has staff role: ${hasStaffRole}`);
      expect(hasStaffRole).toBe(true);
      
      // Bartender should be recognized as having bartender role
      const hasBartenderRole = await user.hasRole('bartender');
      console.log(`[TEST] Bartender has bartender role: ${hasBartenderRole}`);
      expect(hasBartenderRole).toBe(true);
    });

    test('should handle array of roles correctly', async () => {
      // Enable the feature flag explicitly for this test
      await initializeFeatureFlags(true);
      
      const user = new User({
        name: 'Test Staff',
        email: `test-${Date.now()}@example.com`,
        role: 'staff',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await user.save();
      
      // Staff should be recognized as having either bartender or owner role
      const hasBartenderOrOwner = await user.hasRole(['bartender', 'owner']);
      console.log(`[TEST] Staff has bartender or owner role: ${hasBartenderOrOwner}`);
      expect(hasBartenderOrOwner).toBe(true);
      
      // Staff should be recognized as having either staff or owner role
      const hasStaffOrOwner = await user.hasRole(['staff', 'owner']);
      console.log(`[TEST] Staff has staff or owner role: ${hasStaffOrOwner}`);
      expect(hasStaffOrOwner).toBe(true);
      
      // Staff should not be recognized as having either customer or owner role
      const hasCustomerOrOwner = await user.hasRole(['customer', 'owner']);
      console.log(`[TEST] Staff has customer or owner role: ${hasCustomerOrOwner}`);
      expect(hasCustomerOrOwner).toBe(false);
    });
  });
}); 