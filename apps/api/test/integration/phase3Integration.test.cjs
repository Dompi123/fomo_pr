/**
 * @test Phase 3 - Data Model Updates - Integration Tests
 * 
 * This test suite verifies that all Phase 3 changes work together correctly
 * in an integrated environment.
 */

const mongoose = require('mongoose');
const OrderMetrics = require('../../models/OrderMetrics.cjs');
const User = require('../../models/User.cjs');
const featureManager = require('../../services/payment/FeatureManager.cjs');
const migrateBartenderFields = require('../../scripts/migrations/update-bartender-fields');
const { 
  connectToTestDatabase, 
  cleanupTestData, 
  createTestUser, 
  createTestOrderMetrics 
} = require('../helpers/testSetup.cjs');

describe('Phase 3 Integration Tests', () => {
  beforeAll(async () => {
    await connectToTestDatabase();
  });

  afterAll(async () => {
    await cleanupTestData();
    await mongoose.connection.close();
  });

  beforeEach(async () => {
    // Clear collections before each test
    await OrderMetrics.deleteMany({});
    await User.deleteMany({ email: /^test-.*@example.com$/ });
  });

  describe('Feature Flag and Data Model Integration', () => {
    test('should correctly handle staff role and verifiedBy field when feature flag is enabled', async () => {
      // Enable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', true);
      
      // Create a staff user
      const staffUser = await createTestUser({ role: 'staff' });
      
      // Create OrderMetrics with staff verification
      const metrics = await createTestOrderMetrics({
        verifiedBy: 'staff',
        metadata: {
          verificationMethod: 'manual',
          updatedByRole: 'staff'
        }
      });
      
      // Verify the user has staff role
      expect(staffUser.role).toBe('staff');
      
      // Verify the metrics have verifiedBy=staff
      expect(metrics.verifiedBy).toBe('staff');
      
      // Verify hasRole works correctly
      expect(staffUser.hasRole('bartender')).toBe(true);
      expect(staffUser.hasRole('staff')).toBe(true);
      expect(staffUser.hasRole(['bartender', 'owner'])).toBe(true);
    });

    test('should correctly handle bartender role and verifiedBy field when feature flag is disabled', async () => {
      // Disable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', false);
      
      // Create a bartender user
      const bartenderUser = await createTestUser({ role: 'bartender' });
      
      // Create OrderMetrics with staff verification (should still work)
      const metrics = await createTestOrderMetrics({
        verifiedBy: 'staff',
        metadata: {
          verificationMethod: 'manual',
          updatedByRole: 'staff'
        }
      });
      
      // Verify the user has bartender role
      expect(bartenderUser.role).toBe('bartender');
      
      // Verify the metrics have verifiedBy=staff
      expect(metrics.verifiedBy).toBe('staff');
      
      // Verify hasRole works correctly
      expect(bartenderUser.hasRole('staff')).toBe(true);
      expect(bartenderUser.hasRole('bartender')).toBe(true);
      expect(bartenderUser.hasRole(['staff', 'owner'])).toBe(true);
    });
  });

  describe('Migration and Query Compatibility', () => {
    test('should migrate data and maintain query compatibility', async () => {
      // Disable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', false);
      
      // Create a bartender user
      const bartenderUser = await createTestUser({ role: 'bartender' });
      const bartenderId = bartenderUser._id;
      
      // Create test documents with bartenderId using the collection directly
      await OrderMetrics.collection.insertMany([
        {
          orderId: new mongoose.Types.ObjectId(),
          venueId: new mongoose.Types.ObjectId(),
          eventType: 'status_change',
          orderType: 'drink',
          processingTime: 1000,
          bartenderId: bartenderId
        },
        {
          orderId: new mongoose.Types.ObjectId(),
          venueId: new mongoose.Types.ObjectId(),
          eventType: 'verification',
          orderType: 'drink',
          processingTime: 1000,
          bartenderId: bartenderId
        }
      ]);
      
      // Run the migration
      await migrateBartenderFields();
      
      // Verify the documents have been updated
      const updatedDocs = await OrderMetrics.find({});
      
      expect(updatedDocs.length).toBe(2);
      
      // All documents should now have verifiedBy=staff
      updatedDocs.forEach(doc => {
        expect(doc.verifiedBy).toBe('staff');
        expect(doc.bartenderId).toBeUndefined();
      });
      
      // Enable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', true);
      
      // Create a staff user
      const staffUser = await createTestUser({ role: 'staff' });
      
      // Create a new OrderMetrics document with staff verification
      const newMetrics = await createTestOrderMetrics({
        verifiedBy: 'staff',
        metadata: {
          verificationMethod: 'manual',
          updatedByRole: 'staff'
        }
      });
      
      // Query for all staff-verified documents
      const staffVerifiedDocs = await OrderMetrics.find({ verifiedBy: 'staff' });
      
      // Should find all 3 documents (2 migrated + 1 new)
      expect(staffVerifiedDocs.length).toBe(3);
    });
  });

  describe('End-to-End Workflow', () => {
    test('should support complete workflow with feature flag enabled', async () => {
      // Enable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', true);
      
      // Create users with different roles
      const staffUser = await createTestUser({ role: 'staff' });
      const customerUser = await createTestUser({ role: 'customer' });
      const ownerUser = await createTestUser({ role: 'owner' });
      
      // Create OrderMetrics with different verifiedBy values
      const staffMetrics = await createTestOrderMetrics({
        verifiedBy: 'staff',
        metadata: {
          verificationMethod: 'manual',
          updatedByRole: 'staff'
        }
      });
      
      const systemMetrics = await createTestOrderMetrics({
        verifiedBy: 'system',
        metadata: {
          verificationMethod: 'automatic',
          updatedByRole: 'system'
        }
      });
      
      const customerMetrics = await createTestOrderMetrics({
        verifiedBy: 'customer',
        metadata: {
          verificationMethod: 'self',
          updatedByRole: 'customer'
        }
      });
      
      // Verify all users have correct roles
      expect(staffUser.role).toBe('staff');
      expect(customerUser.role).toBe('customer');
      expect(ownerUser.role).toBe('owner');
      
      // Verify all metrics have correct verifiedBy values
      expect(staffMetrics.verifiedBy).toBe('staff');
      expect(systemMetrics.verifiedBy).toBe('system');
      expect(customerMetrics.verifiedBy).toBe('customer');
      
      // Verify hasRole works correctly for all users
      expect(staffUser.hasRole('bartender')).toBe(true);
      expect(staffUser.hasRole('staff')).toBe(true);
      expect(customerUser.hasRole('customer')).toBe(true);
      expect(ownerUser.hasRole('owner')).toBe(true);
      
      // Verify querying works correctly
      const staffVerifiedDocs = await OrderMetrics.find({ verifiedBy: 'staff' });
      const systemVerifiedDocs = await OrderMetrics.find({ verifiedBy: 'system' });
      const customerVerifiedDocs = await OrderMetrics.find({ verifiedBy: 'customer' });
      
      expect(staffVerifiedDocs.length).toBe(1);
      expect(systemVerifiedDocs.length).toBe(1);
      expect(customerVerifiedDocs.length).toBe(1);
    });

    test('should support complete workflow with feature flag disabled', async () => {
      // Disable the feature flag
      await featureManager.setFeatureState('USE_CLIENT_SIDE_VERIFICATION', false);
      
      // Create users with different roles
      const bartenderUser = await createTestUser({ role: 'bartender' });
      const customerUser = await createTestUser({ role: 'customer' });
      const ownerUser = await createTestUser({ role: 'owner' });
      
      // Create OrderMetrics with different verifiedBy values
      const staffMetrics = await createTestOrderMetrics({
        verifiedBy: 'staff',
        metadata: {
          verificationMethod: 'manual',
          updatedByRole: 'staff'
        }
      });
      
      const systemMetrics = await createTestOrderMetrics({
        verifiedBy: 'system',
        metadata: {
          verificationMethod: 'automatic',
          updatedByRole: 'system'
        }
      });
      
      // Verify all users have correct roles
      expect(bartenderUser.role).toBe('bartender');
      expect(customerUser.role).toBe('customer');
      expect(ownerUser.role).toBe('owner');
      
      // Verify all metrics have correct verifiedBy values
      expect(staffMetrics.verifiedBy).toBe('staff');
      expect(systemMetrics.verifiedBy).toBe('system');
      
      // Verify hasRole works correctly for all users
      expect(bartenderUser.hasRole('staff')).toBe(true);
      expect(bartenderUser.hasRole('bartender')).toBe(true);
      expect(customerUser.hasRole('customer')).toBe(true);
      expect(ownerUser.hasRole('owner')).toBe(true);
      
      // Verify querying works correctly
      const staffVerifiedDocs = await OrderMetrics.find({ verifiedBy: 'staff' });
      const systemVerifiedDocs = await OrderMetrics.find({ verifiedBy: 'system' });
      
      expect(staffVerifiedDocs.length).toBe(1);
      expect(systemVerifiedDocs.length).toBe(1);
    });
  });
}); 