/**
 * MongoDB Connection Manager
 * 
 * Handles MongoDB connections across the application. Ensures only one
 * connection is active at any time, and provides specialized handling
 * for test environments.
 */

const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const logger = require('../utils/logger.cjs');

class MongoDBConnectionManager {
  constructor() {
    this.isConnected = false;
    this.uri = null;
    this.mongodInstance = null;
    this.connectionAttempts = 0;
    this.lastConnectionTime = null;
    this.lastError = null;
    this.isTestEnv = process.env.NODE_ENV === 'test';
    this.useMemoryDB = this.isTestEnv && process.env.USE_MEMORY_DB === 'true';
    
    this.logger = logger || console;
    this.logger.info(`[DB] Initialized connection manager (Test: ${this.isTestEnv}, MemoryDB: ${this.useMemoryDB})`);
  }

  /**
   * Get connection options for Mongoose
   */
  getConnectionOptions() {
    // Increased timeout values for test environments
    const baseOptions = {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    };

    // Add enhanced timeout values for tests
    if (this.isTestEnv) {
      return {
        ...baseOptions,
        // Increased timeouts for test environments
        serverSelectionTimeoutMS: 60000,  // 60 seconds (up from 30s)
        connectTimeoutMS: 60000,          // 60 seconds (up from 30s)
        socketTimeoutMS: 90000,           // 90 seconds (up from 45s)
        maxPoolSize: 10,                  // Limit connections to avoid resource exhaustion
        minPoolSize: 1,                   // Ensure at least one connection is maintained
        // Better handling of retries and connection failures
        heartbeatFrequencyMS: 2000,       // Check connection health more frequently in tests
        waitQueueTimeoutMS: 30000,        // Wait queue timeout for operations (up from 15s)
      };
    }

    return baseOptions;
  }

  /**
   * Get the MongoDB connection URI based on environment
   */
  async getConnectionUri() {
    try {
      this.logger.info(`[DB] Getting connection URI for environment: ${process.env.NODE_ENV}`);
      
      // If we already have a URI and not using memory DB, return it
      if (this.uri && !this.useMemoryDB) {
        this.logger.info('[DB] Reusing existing connection URI');
        return this.uri;
      }
      
      // For test environment with in-memory MongoDB
      if (this.useMemoryDB) {
        this.logger.info('[DB] Setting up in-memory MongoDB for tests');
        
        try {
          // If we already have a MongoDB instance, use it
          if (this.mongodInstance && await this.isMemoryServerRunning()) {
            this.logger.info('[DB] Reusing existing MongoDB memory server instance');
            return this.mongodInstance.getUri();
          }
          
          // Create a new MongoDB instance with retry logic
          return await this.createMemoryServer();
        } catch (memoryError) {
          this.logger.error('[DB] Error creating in-memory MongoDB:', memoryError);
          this.lastError = memoryError;
          
          // Fallback to test database if memory DB fails
          if (process.env.MONGODB_TEST_URI) {
            this.logger.warn('[DB] Falling back to MONGODB_TEST_URI after memory DB failure');
            this.uri = process.env.MONGODB_TEST_URI;
            return this.uri;
          }
          
          throw memoryError;
        }
      } 
      
      // For other environments, use the configured URI
      const configuredUri = process.env.MONGODB_URI;
      
      if (!configuredUri) {
        this.logger.error('[DB] No MONGODB_URI found in environment variables');
        throw new Error('MONGODB_URI is required but not provided in environment variables');
      }
      
      this.logger.info('[DB] Using configured MongoDB URI');
      this.uri = configuredUri;
      return configuredUri;
    } catch (error) {
      this.logger.error('[DB] Error getting connection URI:', error);
      this.lastError = error;
      throw error;
    }
  }

  /**
   * Check if memory server is running and responsive
   */
  async isMemoryServerRunning() {
    if (!this.mongodInstance) return false;
    
    try {
      const uri = this.mongodInstance.getUri();
      return !!uri && uri.includes('mongodb://');
    } catch (error) {
      this.logger.warn('[DB] Memory server check failed:', error.message);
      return false;
    }
  }

  /**
   * Create memory server with retry logic
   */
  async createMemoryServer(retries = 2) {
    this.logger.info(`[DB] Creating new MongoDB memory server instance (retries: ${retries})`);
    
    // Close previous instance if it exists
    if (this.mongodInstance) {
      try {
        await this.mongodInstance.stop();
        this.logger.info('[DB] Cleaned up previous memory server instance');
      } catch (stopError) {
        this.logger.warn('[DB] Error stopping previous memory server:', stopError.message);
      }
      this.mongodInstance = null;
    }
    
    try {
      // Configure memory server with explicit options
      const mongod = await MongoMemoryServer.create({
        instance: {
          dbName: 'fomo_test',
          port: 27017 + Math.floor(Math.random() * 1000), // Random port to avoid conflicts
          storageEngine: 'wiredTiger',
        },
        binary: {
          version: '4.4.6', // Specify version for consistency
        },
      });
      
      this.mongodInstance = mongod;
      const memoryUri = mongod.getUri();
      this.logger.info(`[DB] Memory MongoDB URI: ${memoryUri}`);
      
      this.uri = memoryUri;
      return memoryUri;
    } catch (error) {
      this.logger.error(`[DB] Error creating MongoDB memory server (retries left: ${retries}):`, error);
      
      if (retries > 0) {
        this.logger.info(`[DB] Retrying memory server creation (${retries} attempts left)...`);
        await new Promise(resolve => setTimeout(resolve, 1000));
        return this.createMemoryServer(retries - 1);
      }
      
      throw new Error(`Failed to create MongoDB memory server after multiple attempts: ${error.message}`);
    }
  }

  /**
   * Connect to MongoDB with improved retry logic and error handling
   */
  async connect() {
    try {
      this.connectionAttempts++;
      const attemptNum = this.connectionAttempts;
      this.lastConnectionTime = new Date();
      
      this.logger.info(`[DB] Connection attempt #${attemptNum} (isConnected: ${this.isConnected}, state: ${mongoose.connection.readyState})`);
      
      // If already connected, return the existing connection
      if (this.isConnected && mongoose.connection.readyState === 1) {
        this.logger.info('[DB] Already connected to MongoDB, reusing connection');
        return mongoose.connection;
      }
      
      // Close existing connection if in wrong state
      if (mongoose.connection.readyState !== 0) {
        this.logger.info(`[DB] Closing existing connection (state: ${mongoose.connection.readyState})`);
        await mongoose.connection.close();
      }
      
      // Get connection URI
      const uri = await this.getConnectionUri();
      const options = this.getConnectionOptions();
      
      this.logger.info(`[DB] Connecting to MongoDB with options: ${JSON.stringify(options)}`);
      
      // Connect to MongoDB with exponential backoff retry
      let retries = 3;
      let lastError = null;
      
      while (retries > 0) {
        try {
          await mongoose.connect(uri, options);
          
          // Verify connection is established
          if (mongoose.connection.readyState === 1) {
            this.isConnected = true;
            this.logger.info(`[DB] Successfully connected to MongoDB (attempt #${attemptNum})`);
            this.lastError = null;
            
            this.setupConnectionEventHandlers();
            return mongoose.connection;
          }
          
          throw new Error(`Connection established but in incorrect state: ${mongoose.connection.readyState}`);
        } catch (error) {
          lastError = error;
          retries--;
          
          if (retries > 0) {
            // Exponential backoff
            const delay = Math.pow(2, 3 - retries) * 1000;
            this.logger.warn(`[DB] Connection attempt failed, retrying in ${delay}ms... Error: ${error.message}`);
            await new Promise(resolve => setTimeout(resolve, delay));
          }
        }
      }
      
      // All retries failed
      this.isConnected = false;
      this.lastError = lastError;
      throw lastError || new Error('Failed to connect to MongoDB after multiple attempts');
    } catch (error) {
      this.isConnected = false;
      this.lastError = error;
      this.logger.error('[DB] Error connecting to MongoDB:', error);
      throw error;
    }
  }

  /**
   * Set up connection event handlers
   */
  setupConnectionEventHandlers() {
    // Remove existing listeners to avoid duplicates
    mongoose.connection.removeAllListeners('connected');
    mongoose.connection.removeAllListeners('error');
    mongoose.connection.removeAllListeners('disconnected');
    
    // Set up connection event handlers
    mongoose.connection.on('connected', () => {
      this.logger.info('[DB] Mongoose connected to MongoDB');
      this.isConnected = true;
    });
    
    mongoose.connection.on('error', (err) => {
      this.logger.error('[DB] Mongoose connection error:', err);
      this.isConnected = false;
      this.lastError = err;
    });
    
    mongoose.connection.on('disconnected', () => {
      this.logger.info('[DB] Mongoose disconnected from MongoDB');
      this.isConnected = false;
    });
  }

  /**
   * Disconnect from MongoDB
   */
  async disconnect() {
    try {
      this.logger.info('[DB] Disconnecting from MongoDB');
      
      if (mongoose.connection.readyState !== 0) {
        await mongoose.connection.close();
        this.logger.info('[DB] Mongoose connection closed');
      } else {
        this.logger.info('[DB] No active connection to close');
      }
      
      // Clean up in-memory MongoDB if using it
      if (this.useMemoryDB && this.mongodInstance) {
        this.logger.info('[DB] Stopping in-memory MongoDB instance');
        await this.mongodInstance.stop();
        this.mongodInstance = null;
        this.logger.info('[DB] In-memory MongoDB instance stopped');
      }
      
      this.isConnected = false;
      this.uri = null;
      
      return true;
    } catch (error) {
      this.logger.error('[DB] Error disconnecting from MongoDB:', error);
      throw error;
    }
  }

  /**
   * Clear all data in the database
   * Only allowed in test environment
   */
  async clearDatabase() {
    if (!this.isTestEnv) {
      const error = new Error('clearDatabase() is only allowed in test environment');
      this.logger.error('[DB] Attempted to clear database outside test environment');
      throw error;
    }
    
    try {
      this.logger.info('[DB] Clearing database');
      
      // Ensure connection is established
      if (!this.isConnected || mongoose.connection.readyState !== 1) {
        this.logger.info('[DB] No active connection, connecting before clearing');
        await this.connect();
      }
      
      const { collections } = mongoose.connection;
      
      // Get collections and clear each one
      const collectionPromises = Object.values(collections).map(async (collection) => {
        try {
          await collection.deleteMany({});
          this.logger.info(`[DB] Cleared collection: ${collection.collectionName}`);
        } catch (error) {
          this.logger.error(`[DB] Error clearing collection ${collection.collectionName}:`, error);
          throw error;
        }
      });
      
      await Promise.all(collectionPromises);
      this.logger.info('[DB] All collections cleared successfully');
      
      return true;
    } catch (error) {
      this.logger.error('[DB] Error clearing database:', error);
      throw error;
    }
  }

  /**
   * Get the current connection state
   */
  getConnectionState() {
    const state = mongoose.connection.readyState;
    const stateMap = {
      0: 'disconnected',
      1: 'connected',
      2: 'connecting',
      3: 'disconnecting',
      99: 'uninitialized'
    };
    
    return {
      readyState: state,
      status: stateMap[state] || 'unknown',
      isConnected: this.isConnected,
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Get detailed diagnostics for troubleshooting
   */
  getDiagnostics() {
    return {
      connectionState: this.getConnectionState(),
      environment: {
        nodeEnv: process.env.NODE_ENV,
        useMemoryDb: this.useMemoryDB,
        mongoDbUri: this.uri ? (this.uri.includes('mongodb+srv') ? '[Atlas URI]' : this.uri) : 'Not set',
      },
      stats: {
        connectionAttempts: this.connectionAttempts,
        lastConnectionTime: this.lastConnectionTime ? this.lastConnectionTime.toISOString() : null,
        hasMemoryInstance: !!this.mongodInstance,
      },
      error: this.lastError ? {
        message: this.lastError.message,
        name: this.lastError.name,
        stack: this.lastError.stack,
      } : null,
      mongoose: {
        version: mongoose.version,
        models: Object.keys(mongoose.models),
      },
      memoryDb: this.mongodInstance ? {
        uri: this.mongodInstance.getUri(),
        instanceInfo: this.mongodInstance.instanceInfo,
      } : null,
    };
  }
}

// Export singleton instance
module.exports = new MongoDBConnectionManager(); 