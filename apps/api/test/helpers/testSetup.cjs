/**
 * Test Setup Utilities
 * 
 * This file contains helper functions for setting up test environments,
 * creating test data, and managing test database connections.
 */

const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const { User } = require('../../models/User.cjs');
const Venue = require('../../models/Venue.cjs');
const Pass = require('../../models/Pass.cjs');
const OrderMetrics = require('../../models/OrderMetrics.cjs');
const OrderLock = require('../../models/OrderLock.cjs');
const dbConnectionManager = require('../../utils/dbConnectionManager.cjs');
const testServiceRegistry = require('./TestServiceRegistry.cjs');
const FeatureFlagTestContext = require('./FeatureFlagTestContext.cjs');
const mockRegistry = require('./MockRegistry.cjs');
const { 
  createTestVenueData, 
  createTestUserData, 
  createTestPassData, 
  createTestOrderLockData 
} = require('./testFactories.cjs');
const { mockStripe } = require('../mocks/stripe.mock.cjs');
const { mongodbMock } = require('../mocks/mongodb.mock.cjs');
const authTestHelper = require('./AuthTestHelper.cjs');
const { ApiTestHelper, createApiTestHelper } = require('./ApiTestHelper.cjs');
const {
  createMockRequest,
  createMockResponse,
  createMockNext,
  runMiddleware
} = require('./RequestResponseHelpers.cjs');

// Get the feature flag context singleton
const featureFlagContext = require('./FeatureFlagTestContext.cjs');

// Use the mockRegistry singleton directly instead of creating a new instance
// const mockRegistry = new MockRegistry();

// Register core service mocks
mockRegistry.registerServiceMock('stripe', mockStripe);
mockRegistry.registerServiceMock('mongodb', mongodbMock);
// Register socket.io mock
const socketIoMock = require('../mocks/socket.mock.cjs');
mockRegistry.registerServiceMock('socket.io', socketIoMock);

/**
 * Connect to an in-memory MongoDB instance for testing
 */
async function connectToTestDatabase() {
  // Set environment to indicate in-memory database should be used
  process.env.USE_MEMORY_DB = 'true';
  
  // Use the connection manager to connect
  await dbConnectionManager.connect();
  
  console.log(`Connected to test database at ${await dbConnectionManager.getConnectionUri()}`);
}

/**
 * Disconnect from the test database and stop the MongoDB server
 */
async function disconnectFromTestDatabase() {
  await dbConnectionManager.disconnect();
  console.log('Disconnected from test database');
}

/**
 * Clean up all test data from the database
 */
async function cleanupTestData() {
  await dbConnectionManager.clearDatabase();
  console.log('Test data cleaned up');
}

/**
 * Set up a test environment with required dependencies and mocks
 * @param {Object} options - Setup options
 * @param {Object} options.services - Services to register/mock
 * @param {Object} options.features - Feature flags to set
 * @param {Object} options.mocks - Additional service mocks to register
 * @param {Object} options.mockConfig - Configuration for service mocks
 */
async function setupTestEnvironment(options = {}) {
  // Initialize service registry
  if (options.services) {
    for (const [name, implementation] of Object.entries(options.services)) {
      testServiceRegistry.registerMock(name, implementation);
    }
  }
  
  // Initialize mock registry
  if (options.mocks) {
    for (const [name, implementation] of Object.entries(options.mocks)) {
      mockRegistry.registerServiceMock(name, implementation);
    }
  }
  
  // Configure mocks if needed
  if (options.mockConfig) {
    if (options.mockConfig.stripe) {
      mockStripe.configure(options.mockConfig.stripe);
    }
    if (options.mockConfig.mongodb) {
      mongodbMock.configure(options.mockConfig.mongodb);
    }
  }
  
  // Initialize feature flags
  if (options.features) {
    await featureFlagContext.initialize();
    for (const [feature, state] of Object.entries(options.features)) {
      if (typeof state === 'boolean') {
        state ? await featureFlagContext.enableFeature(feature) : 
                await featureFlagContext.disableFeature(feature);
      } else {
        await featureFlagContext.setFeatureState(feature, state);
      }
    }
  }
  
  // Apply module mocks if needed
  if (options.applyModuleMocks) {
    testServiceRegistry.applyModuleMocks();
  }
  
  // Apply service mocks with Jest
  if (options.applyServiceMocks !== false) {
    console.log('[TEST] Applying service mocks via MockRegistry...');
    const mockResult = mockRegistry.applyMocks();
    console.log(`[TEST] Applied ${mockResult.appliedCount} service mocks with ${mockResult.errorCount} errors`);
    
    // Log any failures for easier debugging
    if (mockResult.errorCount > 0 && mockResult.results && mockResult.results.failed) {
      console.error('[TEST] Failed to apply these mocks:', 
        mockResult.results.failed.map(f => `${f.service}: ${f.error}`).join(', '));
    }
  }
  
  return {
    testServiceRegistry,
    featureFlagContext,
    mockRegistry
  };
}

/**
 * Reset all mocks and restore original implementations
 */
function resetAllMocks() {
  // Reset service registry mocks
  testServiceRegistry.resetAllMocks();
  
  // Reset dedicated service mocks
  mockStripe.reset();
  mongodbMock.reset();
  
  // Reset all other mocks
  mockRegistry.resetAllMocks();
}

/**
 * Tear down the test environment and reset state
 */
async function teardownTestEnvironment() {
  // Reset feature flags
  try {
    await featureFlagContext.resetFeatures();
    console.log('[TEST] Feature flags reset successfully');
  } catch (error) {
    console.warn('[TEST] Error resetting feature flags:', error);
    // Continue cleanup despite errors
  }
  
  // Reset all mocks
  resetAllMocks();
  
  // Cleanup service registry
  await testServiceRegistry.cleanup();
  
  // Reset mock registry
  mockRegistry.resetAll();
}

/**
 * Create a test user with specified properties
 * @param {Object} props - Properties to override default user data
 * @returns {Promise<Object>} The created user document
 */
async function createTestUser(props = {}) {
  const userData = createTestUserData(props);
  const user = new User(userData);
  return await user.save();
}

/**
 * Create a test admin user
 * @returns {Promise<Object>} The created admin user document
 */
async function createTestAdmin() {
  return await createTestUser({
    email: 'admin@example.com',
    role: 'admin',
    firstName: 'Admin',
    lastName: 'User'
  });
}

/**
 * Create a test venue
 * @param {Object} props - Properties to override default venue data
 * @returns {Promise<Object>} The created venue document
 */
async function createTestVenue(props = {}) {
  const venueData = createTestVenueData(props);
  const venue = new Venue(venueData);
  return await venue.save();
}

/**
 * Create a test pass
 * @param {Object} props - Properties to override default pass data
 * @returns {Promise<Object>} The created pass document
 */
async function createTestPass(props = {}) {
  const passData = createTestPassData(props);
  const pass = new Pass(passData);
  return await pass.save();
}

/**
 * Create a test order lock
 * @param {Object} props - Properties to override default order lock data
 * @returns {Promise<Object>} The created order lock document
 */
async function createTestOrderLock(props = {}) {
  const lockData = createTestOrderLockData(props);
  const lock = new OrderLock(lockData);
  return await lock.save();
}

/**
 * Initialize metrics for testing
 * @param {Object} props - Properties to override default metrics
 * @returns {Promise<Object>} The created metrics document
 */
async function initializeMetrics(props = {}) {
  const defaults = {
    totalOrders: 0,
    successfulOrders: 0,
    failedOrders: 0,
    totalRevenue: 0,
    refunds: 0,
    averageOrderValue: 0
  };
  
  const metricsData = { ...defaults, ...props };
  const metrics = new OrderMetrics(metricsData);
  return await metrics.save();
}

/**
 * Get a dependency injection getter function
 * This can be used to replace the getDependency function in services
 * @returns {Function} A dependency getter function
 */
function getDependencyGetter() {
  return testServiceRegistry.createDependencyGetter();
}

/**
 * Create an authenticated user with a JWT token
 * @param {Object} userProps - User properties
 * @returns {Object} User object with token
 */
async function createAuthenticatedUser(userProps = {}) {
  const user = await createTestUser(userProps);
  const token = authTestHelper.generateAuthToken(user);
  return { user, token };
}

/**
 * Create an authenticated admin with a JWT token
 * @returns {Object} Admin user object with token
 */
async function createAuthenticatedAdmin() {
  const admin = await createTestAdmin();
  const token = authTestHelper.generateAuthToken(admin);
  return { user: admin, token };
}

/**
 * Create Jest beforeAll hook for test setup
 * @param {Object} options - Setup options
 * @returns {Function} A beforeAll hook function
 */
function createTestSetup(options = {}) {
  return async () => {
    // Connect to test database if needed
    if (options.database !== false) {
      await connectToTestDatabase();
    }
    
    // Set up test environment
    await setupTestEnvironment(options);
    
    // Initialize with test data if needed
    if (options.seedData) {
      for (const [modelName, data] of Object.entries(options.seedData)) {
        switch (modelName) {
          case 'users':
            await Promise.all(data.map(user => createTestUser(user)));
            break;
          case 'venues':
            await Promise.all(data.map(venue => createTestVenue(venue)));
            break;
          case 'passes':
            await Promise.all(data.map(pass => createTestPass(pass)));
            break;
          case 'orderLocks':
            await Promise.all(data.map(lock => createTestOrderLock(lock)));
            break;
          default:
            console.warn(`Unknown model type: ${modelName}`);
        }
      }
    }
  };
}

/**
 * Create Jest afterAll hook for test teardown
 * @param {Object} options - Teardown options
 * @returns {Function} An afterAll hook function
 */
function createTestTeardown(options = {}) {
  return async () => {
    // Clean up test environment
    await teardownTestEnvironment();
    
    // Clean up test data if needed
    if (options.cleanupData !== false) {
      await cleanupTestData();
    }
    
    // Disconnect from test database if needed
    if (options.database !== false) {
      await disconnectFromTestDatabase();
    }
  };
}

/**
 * Create a Jest beforeEach hook to reset mocks
 * @returns {Function} A beforeEach hook function
 */
function createMockResetter() {
  return () => {
    resetAllMocks();
  };
}

module.exports = {
  // Core test setup functions
  connectToTestDatabase,
  disconnectFromTestDatabase,
  cleanupTestData,
  setupTestEnvironment,
  teardownTestEnvironment,
  resetAllMocks,
  
  // Test data creation
  createTestUser,
  createTestAdmin,
  createTestVenue,
  createTestPass,
  createTestOrderLock,
  initializeMetrics,
  
  // Authentication helpers
  createAuthenticatedUser,
  createAuthenticatedAdmin,
  
  // Test lifecycle helpers
  createTestSetup,
  createTestTeardown,
  createMockResetter,
  
  // Dependency injection
  getDependencyGetter,
  
  // Core objects
  testServiceRegistry,
  featureFlagContext,
  mockRegistry,
  mockStripe,
  mongodbMock,
  
  // Request/response mocking
  createMockRequest,
  createMockResponse,
  createMockNext,
  runMiddleware,
  ApiTestHelper,
  createApiTestHelper,
  
  // Auth testing
  authTestHelper
}; 