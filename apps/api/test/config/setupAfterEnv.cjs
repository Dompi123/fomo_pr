/**
 * Jest Setup After Environment
 * 
 * This file runs after the test environment is set up but before any tests execute.
 * It's a good place to add global mocks, extend Jest with custom matchers,
 * and ensure the test environment is properly configured.
 */

const { validateTestEnvironment } = require('../helpers/testEnvironment.cjs');
const mongoose = require('mongoose');
const path = require('path');
const dbConnectionManager = require('../../utils/dbConnectionManager.cjs');
const MockRegistry = require('../helpers/MockRegistry.cjs');
const featureFlagContext = require('../helpers/FeatureFlagTestContext.cjs');
const memoryManager = require('../../utils/memoryManager.cjs');
const mockRegistry = require('../helpers/MockRegistry.cjs');

// Double-check that we're using the test environment
validateTestEnvironment();

// Enable more verbose mongoose debugging for test troubleshooting
mongoose.set('debug', process.env.MONGOOSE_DEBUG === 'true');

// Increase the timeout for tests to accommodate database operations
jest.setTimeout(180000); // 3 minutes (increased from 90s to handle long-running tests)

// Add timeout and retry logic for database connection
const MAX_CONNECTION_ATTEMPTS = 5;
const CONNECTION_TIMEOUT = 30000; // 30 seconds
const DB_OPERATION_TIMEOUT = 10000; // 10 seconds

// Keep track of active timers to properly clean up
const activeTimers = new Set();

// Helper to create a managed timeout
const createManagedTimeout = (callback, timeout) => {
  const timerId = setTimeout(() => {
    // Remove from tracking when fired
    activeTimers.delete(timerId);
    // Execute the original callback
    callback();
  }, timeout);
  
  // Add to tracked timers
  activeTimers.add(timerId);
  
  return timerId;
};

// Clear all tracked timers
const clearAllTrackedTimers = () => {
  for (const timerId of activeTimers) {
    clearTimeout(timerId);
  }
  activeTimers.clear();
  console.log(`[CLEANUP] Cleared ${activeTimers.size} active timers`);
};

/**
 * Ensure database connection is established with improved error handling
 */
const ensureDbConnection = async () => {
  console.log('[SETUP] Ensuring database connection is established...');
  console.log('[SETUP] Current mongoose connection state:', mongoose.connection.readyState);
  console.log('[SETUP] Environment:', process.env.NODE_ENV);
  console.log('[SETUP] Use memory DB:', process.env.USE_MEMORY_DB);
  
  // Set required environment variables if not already set
  if (!process.env.USE_MEMORY_DB) {
    console.log('[SETUP] Setting USE_MEMORY_DB=true for tests');
    process.env.USE_MEMORY_DB = 'true';
  }
  
  // Log MongoDB URI if available
  const uri = process.env.MONGODB_URI || 'Not set';
  console.log(`[SETUP] MongoDB URI: ${uri.includes('mongodb+srv') ? '[Atlas URI]' : uri}`);
  
  // Try to connect with robust retries
  let retries = 5; // Increased retry count
  let connected = false;
  let lastError = null;
  
  while (retries > 0 && !connected) {
    try {
      console.log(`[SETUP] Attempting to connect (${retries} attempts left)...`);
      
      // Get fresh diagnostics before connection attempt
      let preDiagnostics = null;
      try {
        preDiagnostics = dbConnectionManager.getDiagnostics();
        console.log('[SETUP] Pre-connection diagnostics:', JSON.stringify(preDiagnostics, null, 2));
      } catch (diagError) {
        console.warn('[SETUP] Unable to get pre-connection diagnostics:', diagError.message);
      }
      
      // Ensure any existing connection is properly closed
      if (mongoose.connection.readyState !== 0) {
        console.log('[SETUP] Closing existing connection before new attempt');
        await mongoose.connection.close();
      }
      
      // Attempt connection with exponential backoff
      await dbConnectionManager.connect();
      connected = mongoose.connection.readyState === 1;
      
      // Log connection diagnostics
      try {
        const diagnostics = dbConnectionManager.getDiagnostics();
        console.log('[SETUP] Connection diagnostics:', JSON.stringify(diagnostics, null, 2));
      } catch (diagError) {
        console.warn('[SETUP] Unable to get connection diagnostics:', diagError.message);
      }
      
      if (connected) {
        console.log('[SETUP] Database connection established successfully');
        
        // Log details about the database
        try {
          if (mongoose.connection.db) {
            const admin = mongoose.connection.db.admin();
            const info = await admin.serverInfo();
            console.log('[SETUP] MongoDB server info:', info);
            
            // Verify we can perform simple operations
            const testDoc = await mongoose.connection.db.collection('test_setup').insertOne({
              timestamp: new Date(),
              test: 'connection_verification'
            });
            console.log('[SETUP] Successfully performed test write operation:', testDoc.insertedId);
            
            // Clean up test document
            await mongoose.connection.db.collection('test_setup').deleteOne({
              _id: testDoc.insertedId
            });
          }
        } catch (infoError) {
          console.warn('[SETUP] Unable to get MongoDB server info:', infoError.message);
          // Continue anyway as this is just informational
        }
        
        return;
      }
      
      console.log(`[SETUP] Connection not ready (state: ${mongoose.connection.readyState}), retrying...`);
      
      // Exponential backoff
      const delay = Math.pow(2, 5 - retries) * 1000;
      console.log(`[SETUP] Waiting ${delay}ms before next attempt...`);
      await new Promise(resolve => setTimeout(resolve, delay));
      retries--;
    } catch (error) {
      console.error('[SETUP] Error connecting to database:', error);
      console.error('[SETUP] Stack trace:', error.stack);
      lastError = error;
      retries--;
      
      if (retries > 0) {
        // Exponential backoff
        const delay = Math.pow(2, 5 - retries) * 1000;
        console.log(`[SETUP] Retrying connection after error in ${delay}ms (${retries} attempts left)...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  if (!connected) {
    console.error('[SETUP] Failed to establish database connection after multiple attempts');
    console.error('[SETUP] Current connection state:', mongoose.connection.readyState);
    console.error('[SETUP] Last error:', lastError);
    
    try {
      // Try direct MongoDB Memory Server as a last resort
      console.log('[SETUP] Attempting to create MongoDB Memory Server directly as last resort...');
      const { MongoMemoryServer } = require('mongodb-memory-server');
      const memServer = await MongoMemoryServer.create({
        instance: {
          dbName: 'fomo_test_last_resort',
          port: 27018, // Use a different port
          storageEngine: 'wiredTiger',
        },
      });
      const memUri = memServer.getUri();
      console.log('[SETUP] Successfully created last-resort in-memory MongoDB:', memUri);
      
      // Store for cleanup
      global.__MONGO_MEMORY_SERVER__ = memServer;
      
      // Attempt a direct connection
      if (mongoose.connection.readyState !== 0) {
        await mongoose.connection.close();
      }
      
      // Connect with robust options
      await mongoose.connect(memUri, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        serverSelectionTimeoutMS: 30000,
        connectTimeoutMS: 30000,
        socketTimeoutMS: 45000,
      });
      
      connected = mongoose.connection.readyState === 1;
      console.log('[SETUP] Direct connection to memory server state:', mongoose.connection.readyState);
      
      if (connected) {
        console.log('[SETUP] Last-resort direct memory server connection successful');
        return;
      }
    } catch (error) {
      console.error('[SETUP] Last-resort memory server attempt failed:', error);
    }
    
    throw new Error('Failed to establish database connection after all attempts');
  }
};

/**
 * Clear the database between tests with improved error handling
 */
const clearDatabase = async () => {
  // Ensure connection is established before clearing
  if (mongoose.connection.readyState !== 1) {
    console.log('[SETUP] Database not connected before clearing, attempting to connect...');
    try {
      await ensureDbConnection();
    } catch (error) {
      console.error('[SETUP] Failed to connect for database clearing:', error);
      throw error;
    }
  }
  
  try {
    console.log('[SETUP] Clearing database...');
    await dbConnectionManager.clearDatabase();
    console.log('[SETUP] Database cleared successfully');
  } catch (error) {
    console.error('[SETUP] Error clearing database:', error);
    
    // Attempt manual clearing as a fallback
    try {
      console.log('[SETUP] Attempting manual database clearing as fallback...');
      const { collections } = mongoose.connection;
      
      // Clear each collection manually
      for (const collection of Object.values(collections)) {
        try {
          await collection.deleteMany({});
          console.log(`[SETUP] Manually cleared collection: ${collection.collectionName}`);
        } catch (collectionError) {
          console.error(`[SETUP] Error clearing collection ${collection.collectionName}:`, collectionError);
          // Continue with other collections
        }
      }
      
      console.log('[SETUP] Manual database clearing completed');
    } catch (manualError) {
      console.error('[SETUP] Manual database clearing failed:', manualError);
      throw error; // Throw the original error
    }
  }
};

// More resilient database connection with timeout
const ensureDbConnectionWithTimeout = async () => {
  console.log('[SETUP] Ensuring database connection is established...');
  console.log('[SETUP] Current mongoose connection state:', mongoose.connection.readyState);
  console.log('[SETUP] Environment:', process.env.NODE_ENV);
  console.log('[SETUP] Use memory DB:', process.env.USE_MEMORY_DB === 'true');
  
  // If already connected, return the connection
  if (dbConnectionManager.isConnected) {
    console.log('[SETUP] Database already connected');
    return mongoose.connection;
  }
  
  let connection;
  let attempts = 0;
  let lastError;
  let connectTimeoutId;
  
  while (attempts < MAX_CONNECTION_ATTEMPTS) {
    attempts++;
    console.log(`[SETUP] Attempting to connect (${MAX_CONNECTION_ATTEMPTS - attempts + 1} attempts left)...`);
    
    try {
      // Get connection diagnostics before connecting
      const preDiagnostics = dbConnectionManager.getDiagnostics();
      console.log('[SETUP] Pre-connection diagnostics:', JSON.stringify(preDiagnostics, null, 2));
      
      // Set a timeout for the connection attempt using managed timeout
      const connectPromise = dbConnectionManager.connect();
      const timeoutPromise = new Promise((_, reject) => {
        connectTimeoutId = createManagedTimeout(() => {
          reject(new Error(`Connection timeout after ${CONNECTION_TIMEOUT}ms`));
        }, CONNECTION_TIMEOUT);
      });
      
      // Race the promises
      connection = await Promise.race([connectPromise, timeoutPromise]);
      
      // If we got here, the connection was successful - clear the timeout
      if (connectTimeoutId && activeTimers.has(connectTimeoutId)) {
        clearTimeout(connectTimeoutId);
        activeTimers.delete(connectTimeoutId);
      }
      
      // Get updated diagnostics after connecting
      const diagnostics = dbConnectionManager.getDiagnostics();
      console.log('[SETUP] Connection diagnostics:', JSON.stringify(diagnostics, null, 2));
      
      // Verify the connection is actually working with a simple operation
      try {
        // Try a simple write operation with timeout
        const testCollection = connection.collection('test_connection');
        
        let writeOperationTimeoutId;
        const writePromise = testCollection.insertOne({ test: 'connection', timestamp: new Date() });
        const writeTimeoutPromise = new Promise((_, reject) => {
          writeOperationTimeoutId = createManagedTimeout(() => {
            reject(new Error(`Write operation timeout after ${DB_OPERATION_TIMEOUT}ms`));
          }, DB_OPERATION_TIMEOUT);
        });
        
        const writeResult = await Promise.race([writePromise, writeTimeoutPromise]);
        
        // Clear the timeout if operation succeeded
        if (writeOperationTimeoutId && activeTimers.has(writeOperationTimeoutId)) {
          clearTimeout(writeOperationTimeoutId);
          activeTimers.delete(writeOperationTimeoutId);
        }
        
        console.log('[SETUP] Successfully performed test write operation:', writeResult.insertedId);
        return connection;
      } catch (operationError) {
        console.error('[SETUP] Database operation failed:', operationError);
        lastError = operationError;
        // Continue to next attempt
      }
    } catch (error) {
      console.error(`[SETUP] Connection attempt ${attempts} failed:`, error);
      lastError = error;
      
      // Short delay before retry
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
  
  // If we get here, all attempts failed
  console.error(`[SETUP] Failed to connect after ${MAX_CONNECTION_ATTEMPTS} attempts`);
  throw lastError || new Error('Failed to establish database connection');
};

// Ensure database connection before all tests with extended timeout
beforeAll(async () => {
  jest.setTimeout(300000); // 5 minutes for the initial setup
  
  try {
    console.log('[SETUP] Starting global beforeAll hook...');
    
    // Initialize mocks first to avoid race conditions with feature flags
    try {
      console.log('[SETUP] Initializing mock registry...');
      const mockResult = mockRegistry.applyMocks();
      console.log(`[SETUP] Applied ${mockResult.appliedCount} service mocks with ${mockResult.errorCount} errors`);
      
      // Special handling for socket.io mock which seems particularly problematic
      const socketIoMock = require('../mocks/socket.mock.cjs');
      if (socketIoMock && typeof socketIoMock.mockIO === 'function') {
        console.log('[SETUP] Explicitly initializing socket.io mock');
        const io = socketIoMock.mockIO();
        if (io) {
          console.log('[SETUP] Socket.io mock initialized successfully');
        }
      }
    } catch (mockError) {
      console.error('[SETUP] Error initializing mocks:', mockError);
      // Continue setup despite errors - don't fail all tests for mock issues
    }
    
    // Initialize feature flags next
    try {
      await featureFlagContext.initialize();
      console.log('[SETUP] Feature flags initialized successfully');
    } catch (featureError) {
      console.error('[SETUP] Error initializing feature flags:', featureError);
      // Continue setup despite errors - don't fail all tests for feature flag issues
    }
    
    // Then ensure database connection
    await ensureDbConnectionWithTimeout();
    
    console.log('[SETUP] Global beforeAll hook completed successfully');
  } catch (error) {
    console.error('[SETUP] beforeAll hook failed:', error);
    
    // Attempt to recover or provide better diagnostics
    try {
      console.error('[SETUP] Current connection state:', mongoose.connection.readyState);
      console.error('[SETUP] Attempting to get diagnostics...');
      const diagnostics = dbConnectionManager.getDiagnostics();
      console.error('[SETUP] Diagnostics:', JSON.stringify(diagnostics, null, 2));
    } catch (diagError) {
      console.error('[SETUP] Failed to get diagnostics:', diagError);
    }
    
    // Important: re-throw the original error
    throw error;
  }
}, 300000); // 5 minute timeout for this hook

// Clear database before each test with timeout
beforeEach(async () => {
  jest.setTimeout(60000); // 1 minute for each test
  
  try {
    await clearDatabase();
  } catch (error) {
    console.error('[SETUP] beforeEach hook failed:', error);
    throw error;
  }
}, 60000); // 1 minute timeout for this hook

// Clean up resources after all tests with timeout
afterAll(async () => {
  console.log('[TEARDOWN] Cleaning up resources...');
  try {
    // Reset feature flags to original state first
    try {
      await featureFlagContext.resetFeatures();
      console.log('[TEARDOWN] Feature flags reset successfully');
    } catch (featureError) {
      console.error('[TEARDOWN] Error resetting feature flags:', featureError);
      // Continue cleanup despite errors
    }
    
    // Shutdown memory manager to prevent open handles
    try {
      memoryManager.shutdown();
      console.log('[TEARDOWN] Memory manager shutdown complete');
    } catch (memoryError) {
      console.error('[TEARDOWN] Error shutting down memory manager:', memoryError);
      // Continue cleanup despite errors
    }
    
    // Set a timeout for the disconnect operation using managed timeout
    let disconnectTimeoutId;
    const disconnectPromise = dbConnectionManager.disconnect();
    const timeoutPromise = new Promise((_, reject) => {
      disconnectTimeoutId = createManagedTimeout(() => {
        console.error('[TEARDOWN] Disconnect timeout, forcing close...');
        // Force close connection if timeout
        mongoose.connection.close(true);
        reject(new Error('Disconnect timeout'));
      }, 30000); // 30 second timeout
    });
    
    try {
      await Promise.race([disconnectPromise, timeoutPromise]);
      
      // If we get here, the disconnect was successful - clear the timeout
      if (disconnectTimeoutId && activeTimers.has(disconnectTimeoutId)) {
        clearTimeout(disconnectTimeoutId);
        activeTimers.delete(disconnectTimeoutId);
      }
    } catch (error) {
      console.error('[TEARDOWN] Database disconnect error:', error);
    }
    
    // Clean up memory server if used
    if (global.__MONGO_MEMORY_SERVER__) {
      try {
        await global.__MONGO_MEMORY_SERVER__.stop();
        delete global.__MONGO_MEMORY_SERVER__;
      } catch (error) {
        console.error('[TEARDOWN] Error stopping memory server:', error);
      }
    }
    
    // Final step: clean up any remaining timers
    clearAllTrackedTimers();
    
    console.log('[TEARDOWN] Resources cleaned up successfully');
  } catch (error) {
    console.error('[TEARDOWN] Error during resource cleanup:', error);
    throw error;
  }
}, 60000); // 1 minute timeout for this hook

// Add custom Jest matchers if needed
expect.extend({
  toBeWithinRange(received, floor, ceiling) {
    const pass = received >= floor && received <= ceiling;
    if (pass) {
      return {
        message: () => `expected ${received} not to be within range ${floor} - ${ceiling}`,
        pass: true,
      };
    } else {
      return {
        message: () => `expected ${received} to be within range ${floor} - ${ceiling}`,
        pass: false,
      };
    }
  },
});

// Get absolute paths to mocks
const stripeMockPath = path.resolve(__dirname, '../mocks/stripe.mock.cjs');
const auth0MockPath = path.resolve(__dirname, '../mocks/auth0.mock.cjs');

// Uncomment the mocks to fix authentication tests
jest.mock('../../services/payment/stripeService.cjs', () => require(stripeMockPath));
jest.mock('../../services/auth/auth0Service.cjs', () => require(auth0MockPath));

// Log when setup is complete
console.log('[SETUP] Test environment setup complete. Running tests...'); 