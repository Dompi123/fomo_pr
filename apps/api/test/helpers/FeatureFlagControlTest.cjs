/**
 * Feature Flag Control Test Example
 * 
 * This file demonstrates how to use the FeatureFlagTestContext in tests.
 */

const { describe, test, expect, beforeAll, afterAll, beforeEach, afterEach } = require('@jest/globals');
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

  // Test cases...
}); 