/**
 * @test Phase 3 - Data Model Updates - OrderMetrics Schema Tests
 * 
 * This test suite verifies that the OrderMetrics schema has been correctly updated
 * to use verifiedBy instead of bartenderId as part of Phase 3 data model updates.
 */

const mongoose = require('mongoose');
const OrderMetrics = require('../../../models/OrderMetrics.cjs');
const { createTestVenue, clearDatabase } = require('../../helpers/testSetup.cjs');

describe('OrderMetrics Schema (Phase 3)', () => {
  beforeAll(async () => {
    // Connection is handled by the global setup
  });

  afterAll(async () => {
    // Cleanup is handled by the global teardown
  });

  afterEach(async () => {
    await OrderMetrics.deleteMany({});
  });

  describe('Schema Structure', () => {
    test('should have verifiedBy field with correct enum values', () => {
      const schemaPath = OrderMetrics.schema.paths.verifiedBy;
      
      // Verify field exists and has correct type
      expect(schemaPath).toBeDefined();
      expect(schemaPath.instance).toBe('String');
      
      // Verify enum values
      expect(schemaPath.enumValues).toEqual(['staff', 'system', 'customer']);
      
      // Verify default value
      expect(schemaPath.defaultValue).toBe('system');
    });

    test('should not have bartenderId field', () => {
      const schemaPath = OrderMetrics.schema.paths.bartenderId;
      
      // Verify field does not exist
      expect(schemaPath).toBeUndefined();
    });

    test('should have correct indexes', async () => {
      const indexes = await OrderMetrics.collection.indexes();
      
      // Find the index that includes verifiedBy
      const verifiedByIndex = indexes.find(index => 
        index.key && index.key.verifiedBy !== undefined
      );
      
      // Verify index exists
      expect(verifiedByIndex).toBeDefined();
      
      // Verify index structure
      expect(verifiedByIndex.key).toEqual({ verifiedBy: 1, timestamp: -1 });
    });
  });

  describe('Document Creation', () => {
    test('should create document with default verifiedBy value', async () => {
      const metrics = new OrderMetrics({
        orderId: new mongoose.Types.ObjectId(),
        venueId: new mongoose.Types.ObjectId(),
        eventType: 'status_change',
        orderType: 'drink',
        processingTime: 1000
      });
      
      await metrics.save();
      
      const savedMetrics = await OrderMetrics.findById(metrics._id);
      expect(savedMetrics.verifiedBy).toBe('system');
    });

    test('should create document with specified verifiedBy value', async () => {
      const metrics = new OrderMetrics({
        orderId: new mongoose.Types.ObjectId(),
        venueId: new mongoose.Types.ObjectId(),
        eventType: 'status_change',
        orderType: 'drink',
        processingTime: 1000,
        verifiedBy: 'staff'
      });
      
      await metrics.save();
      
      const savedMetrics = await OrderMetrics.findById(metrics._id);
      expect(savedMetrics.verifiedBy).toBe('staff');
    });

    test('should reject invalid verifiedBy values', async () => {
      const metrics = new OrderMetrics({
        orderId: new mongoose.Types.ObjectId(),
        venueId: new mongoose.Types.ObjectId(),
        eventType: 'status_change',
        orderType: 'drink',
        processingTime: 1000,
        verifiedBy: 'invalid-value'
      });
      
      await expect(metrics.save()).rejects.toThrow();
    });
  });

  describe('Querying', () => {
    beforeEach(async () => {
      // Create test documents with different verifiedBy values
      await OrderMetrics.create([
        {
          orderId: new mongoose.Types.ObjectId(),
          venueId: new mongoose.Types.ObjectId(),
          eventType: 'status_change',
          orderType: 'drink',
          processingTime: 1000,
          verifiedBy: 'staff'
        },
        {
          orderId: new mongoose.Types.ObjectId(),
          venueId: new mongoose.Types.ObjectId(),
          eventType: 'status_change',
          orderType: 'drink',
          processingTime: 1000,
          verifiedBy: 'system'
        },
        {
          orderId: new mongoose.Types.ObjectId(),
          venueId: new mongoose.Types.ObjectId(),
          eventType: 'status_change',
          orderType: 'drink',
          processingTime: 1000,
          verifiedBy: 'customer'
        }
      ]);
    });

    test('should query by verifiedBy field', async () => {
      const staffMetrics = await OrderMetrics.find({ verifiedBy: 'staff' });
      const systemMetrics = await OrderMetrics.find({ verifiedBy: 'system' });
      const customerMetrics = await OrderMetrics.find({ verifiedBy: 'customer' });
      
      expect(staffMetrics.length).toBe(1);
      expect(systemMetrics.length).toBe(1);
      expect(customerMetrics.length).toBe(1);
      
      expect(staffMetrics[0].verifiedBy).toBe('staff');
      expect(systemMetrics[0].verifiedBy).toBe('system');
      expect(customerMetrics[0].verifiedBy).toBe('customer');
    });
  });
}); 