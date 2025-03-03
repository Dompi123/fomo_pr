/**
 * @test Phase 3 - Data Model Updates - User Model Tests
 * 
 * This test suite verifies that the User model has been correctly updated
 * to handle the feature flag for role enum as part of Phase 3 data model updates.
 */

const mongoose = require('mongoose');
const User = require('../../models/User.cjs');
const featureManager = require('../../services/payment/FeatureManager.cjs');
const { connectToTestDatabase, cleanupTestData } = require('../helpers/testSetup.cjs');

describe('User Model (Phase 3)', () => {
  beforeAll(async () => {
    await connectToTestDatabase();
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
      // Enable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', true);
      
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
      // Disable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', false);
      
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
      // Disable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', false);
      
      const user = new User({
        name: 'Test Invalid Staff',
        email: `test-${Date.now()}@example.com`,
        role: 'staff',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await expect(user.save()).rejects.toThrow();
    });

    test('should reject bartender role when feature flag is enabled', async () => {
      // Enable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', true);
      
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
      // Enable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', true);
      
      const user = new User({
        name: 'Test Staff',
        email: `test-${Date.now()}@example.com`,
        role: 'staff',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await user.save();
      
      // Staff should be recognized as having bartender role
      expect(user.hasRole('bartender')).toBe(true);
      
      // Staff should be recognized as having staff role
      expect(user.hasRole('staff')).toBe(true);
    });

    test('should recognize bartender role as equivalent to staff when checking hasRole', async () => {
      // Disable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', false);
      
      const user = new User({
        name: 'Test Bartender',
        email: `test-${Date.now()}@example.com`,
        role: 'bartender',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await user.save();
      
      // Bartender should be recognized as having staff role
      expect(user.hasRole('staff')).toBe(true);
      
      // Bartender should be recognized as having bartender role
      expect(user.hasRole('bartender')).toBe(true);
    });

    test('should handle array of roles correctly', async () => {
      // Enable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', true);
      
      const user = new User({
        name: 'Test Staff',
        email: `test-${Date.now()}@example.com`,
        role: 'staff',
        auth0Id: `auth0|${Date.now()}`
      });
      
      await user.save();
      
      // Staff should be recognized as having either bartender or owner role
      expect(user.hasRole(['bartender', 'owner'])).toBe(true);
      
      // Staff should be recognized as having either staff or owner role
      expect(user.hasRole(['staff', 'owner'])).toBe(true);
      
      // Staff should not be recognized as having either customer or owner role
      expect(user.hasRole(['customer', 'owner'])).toBe(false);
    });
  });
}); 