/**
 * MongoDB Mock
 * 
 * This file provides a mock implementation of MongoDB for testing.
 * It simulates the MongoDB driver and allows for customized behavior
 * during tests without requiring a real database connection.
 */

// Using jestInstance for consistent jest access across mocks
const jestInstance = require('../helpers/jestInstance.cjs');
const { EventEmitter } = require('events');
const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// Use the fn method from jestInstance instead of directly from jest
const createMockFn = (name) => {
  // Create the base mock function
  const mockFn = jestInstance.fn() || ((impl) => impl || (() => {}));
  
  // Ensure mockImplementation is available
  if (!mockFn.mockImplementation) {
    mockFn.mockImplementation = function(impl) {
      // Replace the function with the implementation
      const newFn = impl;
      // Copy all properties from mockFn to newFn
      Object.keys(mockFn).forEach(key => {
        if (key !== 'mockImplementation') {
          newFn[key] = mockFn[key];
        }
      });
      // Add mockImplementation to the new function too
      newFn.mockImplementation = mockFn.mockImplementation;
      // Add mockName if it doesn't exist
      if (!newFn.mockName && name) {
        newFn.mockName = () => name;
      }
      return newFn;
    };
  }
  
  // Add mockName if it doesn't exist
  if (mockFn.mockName && name) {
    mockFn.mockName(name);
  } else if (!mockFn.mockName && name) {
    mockFn.mockName = () => name;
  }
  
  return mockFn;
}

/**
 * Mock MongoDB implementation for testing
 * Simulates MongoDB behavior without a real connection
 */
class MongoDBMock extends EventEmitter {
  constructor() {
    super();
    this._reset();
    this._setupMocks();
  }

  /**
   * Reset the mock state
   */
  _reset() {
    // Store collections with their documents
    this._collections = new Map();
    
    // Configure behavior
    this._config = {
      shouldFailOnOperation: false,
      shouldDelay: false,
      delayMs: 0,
      failureRate: 0,
      nextOperationFails: false,
      simulateNetworkPartition: false,
      simulateTimeout: false,
      timeoutMs: 5000
    };

    // Operation statistics
    this._stats = {
      totalOperations: 0,
      successfulOperations: 0,
      failedOperations: 0,
      lastOperation: null
    };
  }

  /**
   * Set up mock methods
   */
  _setupMocks() {
    // Main DB connection methods
    this.connect = createMockFn('connect').mockImplementation(() => this._simulateOperation('connect'));
    this.close = createMockFn('close').mockImplementation(() => this._simulateOperation('close'));
    
    // Collection-level methods
    this.db = createMockFn('db').mockImplementation(() => ({
      collection: (name) => this._getCollection(name)
    }));
  }

  /**
   * Configure the mock behavior
   * 
   * @param {Object} config - Configuration options
   */
  configure(config = {}) {
    this._config = {
      ...this._config,
      ...config
    };
    return this;
  }

  /**
   * Reset the mock to its initial state
   */
  reset() {
    this._reset();
    return this;
  }

  /**
   * Get operation statistics
   * 
   * @returns {Object} Statistics about operations performed
   */
  getStats() {
    return { ...this._stats };
  }

  /**
   * Get a collection, creating it if it doesn't exist
   * 
   * @param {string} name - Collection name
   * @returns {Object} A mock collection object
   */
  _getCollection(name) {
    if (!this._collections.has(name)) {
      this._collections.set(name, []);
    }

    return this._createCollectionMethods(name);
  }

  /**
   * Create mock methods for a collection
   * 
   * @param {string} collectionName - Name of the collection
   * @returns {Object} Collection with mock methods
   */
  _createCollectionMethods(collectionName) {
    return {
      // Find operations
      find: createMockFn('find').mockImplementation((query = {}) => 
        this._wrapCursor(this._simulateOperation('find', { 
          collection: collectionName, 
          query 
        }))),
      
      findOne: createMockFn('findOne').mockImplementation((query = {}) => 
        this._simulateOperation('findOne', { 
          collection: collectionName, 
          query 
        })),
      
      // Mutation operations
      insertOne: createMockFn('insertOne').mockImplementation((doc) => 
        this._simulateOperation('insertOne', { 
          collection: collectionName, 
          doc 
        })),
      
      insertMany: createMockFn('insertMany').mockImplementation((docs) => 
        this._simulateOperation('insertMany', { 
          collection: collectionName, 
          docs 
        })),
      
      updateOne: createMockFn('updateOne').mockImplementation((filter, update, options = {}) => 
        this._simulateOperation('updateOne', { 
          collection: collectionName, 
          filter, 
          update, 
          options 
        })),
      
      updateMany: createMockFn('updateMany').mockImplementation((filter, update, options = {}) => 
        this._simulateOperation('updateMany', { 
          collection: collectionName, 
          filter, 
          update, 
          options 
        })),
      
      deleteOne: createMockFn('deleteOne').mockImplementation((filter) => 
        this._simulateOperation('deleteOne', { 
          collection: collectionName, 
          filter 
        })),
      
      deleteMany: createMockFn('deleteMany').mockImplementation((filter) => 
        this._simulateOperation('deleteMany', { 
          collection: collectionName, 
          filter 
        })),
      
      // Aggregation
      aggregate: createMockFn('aggregate').mockImplementation((pipeline) => 
        this._wrapCursor(this._simulateOperation('aggregate', { 
          collection: collectionName, 
          pipeline 
        }))),
      
      // Count/exists operations
      countDocuments: createMockFn('countDocuments').mockImplementation((query = {}) => 
        this._simulateOperation('countDocuments', { 
          collection: collectionName, 
          query 
        })),
      
      estimatedDocumentCount: createMockFn('estimatedDocumentCount').mockImplementation(() => 
        this._simulateOperation('estimatedDocumentCount', { 
          collection: collectionName 
        }))
    };
  }

  /**
   * Wrap a result in a cursor-like object
   * 
   * @param {Promise<Array>} resultPromise - Promise with array of results
   * @returns {Object} A mock cursor
   */
  _wrapCursor(resultPromise) {
    const cursor = {
      // Core cursor methods
      toArray: createMockFn('toArray').mockImplementation(() => resultPromise),
      
      // Cursor modifiers
      limit: createMockFn('limit').mockImplementation(() => cursor),
      skip: createMockFn('skip').mockImplementation(() => cursor),
      sort: createMockFn('sort').mockImplementation(() => cursor),
      project: createMockFn('project').mockImplementation(() => cursor),
      
      // Iteration methods
      forEach: createMockFn('forEach').mockImplementation(async (callback) => {
        const results = await resultPromise;
        for (const doc of results) {
          callback(doc);
        }
      }),
      
      // Other cursor methods
      hasNext: createMockFn('hasNext').mockImplementation(async () => {
        const results = await resultPromise;
        return results.length > 0;
      }),
      
      next: createMockFn('next').mockImplementation(async () => {
        const results = await resultPromise;
        return results.length > 0 ? results[0] : null;
      }),
      
      count: createMockFn('count').mockImplementation(async () => {
        const results = await resultPromise;
        return results.length;
      })
    };
    
    return cursor;
  }

  /**
   * Simulate an operation with configurable behavior
   * 
   * @param {string} operation - Name of the operation
   * @param {Object} params - Operation parameters
   * @returns {Promise<any>} Result of the operation
   */
  async _simulateOperation(operation, params = {}) {
    this._stats.totalOperations++;
    this._stats.lastOperation = { operation, params, timestamp: Date.now() };
    
    // Check for configured failures
    if (this._shouldFailOperation()) {
      this._stats.failedOperations++;
      return this._simulateFailure(operation);
    }
    
    // Simulate delays if configured
    if (this._config.shouldDelay) {
      await new Promise(resolve => setTimeout(resolve, this._config.delayMs));
    }
    
    // Simulate network issues if configured
    if (this._config.simulateNetworkPartition) {
      this._stats.failedOperations++;
      throw new Error('MongoDB connection lost');
    }
    
    // Simulate timeout if configured
    if (this._config.simulateTimeout) {
      this._stats.failedOperations++;
      await new Promise(resolve => setTimeout(resolve, this._config.timeoutMs));
      throw new Error('MongoDB operation timeout');
    }
    
    // Otherwise proceed with the operation
    try {
      const result = await this._executeOperation(operation, params);
      this._stats.successfulOperations++;
      return result;
    } catch (error) {
      this._stats.failedOperations++;
      throw error;
    }
  }

  /**
   * Determine if the operation should fail based on configuration
   * 
   * @returns {boolean} Whether the operation should fail
   */
  _shouldFailOperation() {
    if (this._config.nextOperationFails) {
      this._config.nextOperationFails = false;
      return true;
    }
    
    if (this._config.shouldFailOnOperation && 
        Math.random() < this._config.failureRate) {
      return true;
    }
    
    return false;
  }

  /**
   * Simulate a failure for an operation
   * 
   * @param {string} operation - The operation that failed
   * @returns {Promise<never>} A rejected promise
   */
  _simulateFailure(operation) {
    const errorTypes = [
      { name: 'MongoNetworkError', message: 'Connection lost to MongoDB' },
      { name: 'MongoTimeoutError', message: 'Operation timed out' },
      { name: 'MongoServerError', message: 'Internal server error', code: 5000 }
    ];
    
    const errorType = errorTypes[Math.floor(Math.random() * errorTypes.length)];
    const error = new Error(errorType.message);
    error.name = errorType.name;
    if (errorType.code) error.code = errorType.code;
    
    return Promise.reject(error);
  }

  /**
   * Execute the actual operation logic
   * 
   * @param {string} operation - Operation name
   * @param {Object} params - Operation parameters
   * @returns {Promise<any>} Operation result
   */
  async _executeOperation(operation, params) {
    const { collection: collectionName } = params;
    const docs = collectionName ? 
      this._collections.get(collectionName) || [] : 
      [];
    
    switch (operation) {
      case 'connect':
        return { db: this.db };
        
      case 'close':
        return true;
        
      case 'find':
        return this._executeFind(docs, params.query);
        
      case 'findOne':
        const results = await this._executeFind(docs, params.query);
        return results.length > 0 ? results[0] : null;
        
      case 'insertOne': {
        const _id = params.doc._id || new mongoose.Types.ObjectId();
        const newDoc = { ...params.doc, _id };
        this._collections.set(collectionName, [...docs, newDoc]);
        return { 
          acknowledged: true, 
          insertedId: _id 
        };
      }
        
      case 'insertMany': {
        const insertedDocs = params.docs.map(doc => ({
          ...doc,
          _id: doc._id || new mongoose.Types.ObjectId()
        }));
        
        this._collections.set(collectionName, [...docs, ...insertedDocs]);
        
        return { 
          acknowledged: true, 
          insertedCount: insertedDocs.length,
          insertedIds: insertedDocs.map(doc => doc._id)
        };
      }
        
      case 'updateOne': {
        const { filter, update, options } = params;
        const foundIndex = docs.findIndex(doc => this._matchesFilter(doc, filter));
        
        if (foundIndex === -1) {
          // Handle upsert
          if (options && options.upsert) {
            const newDoc = {
              ...filter,
              ...this._applyUpdate(update, {})
            };
            return this._executeOperation('insertOne', {
              collection: collectionName,
              doc: newDoc
            });
          }
          
          return { 
            acknowledged: true, 
            matchedCount: 0, 
            modifiedCount: 0 
          };
        }
        
        const updatedDoc = this._applyUpdate(update, docs[foundIndex]);
        const newDocs = [...docs];
        newDocs[foundIndex] = updatedDoc;
        this._collections.set(collectionName, newDocs);
        
        return { 
          acknowledged: true, 
          matchedCount: 1, 
          modifiedCount: 1,
          upsertedId: null
        };
      }
        
      case 'updateMany': {
        const { filter, update, options } = params;
        const matchingIndices = docs
          .map((doc, index) => this._matchesFilter(doc, filter) ? index : -1)
          .filter(index => index !== -1);
        
        if (matchingIndices.length === 0) {
          // Handle upsert
          if (options && options.upsert) {
            const newDoc = {
              ...filter,
              ...this._applyUpdate(update, {})
            };
            return this._executeOperation('insertOne', {
              collection: collectionName,
              doc: newDoc
            });
          }
          
          return { 
            acknowledged: true, 
            matchedCount: 0, 
            modifiedCount: 0 
          };
        }
        
        const newDocs = [...docs];
        matchingIndices.forEach(index => {
          newDocs[index] = this._applyUpdate(update, docs[index]);
        });
        
        this._collections.set(collectionName, newDocs);
        
        return { 
          acknowledged: true, 
          matchedCount: matchingIndices.length, 
          modifiedCount: matchingIndices.length,
          upsertedId: null
        };
      }
        
      case 'deleteOne': {
        const { filter } = params;
        const index = docs.findIndex(doc => this._matchesFilter(doc, filter));
        
        if (index === -1) {
          return { 
            acknowledged: true, 
            deletedCount: 0 
          };
        }
        
        const newDocs = [...docs];
        newDocs.splice(index, 1);
        this._collections.set(collectionName, newDocs);
        
        return { 
          acknowledged: true, 
          deletedCount: 1 
        };
      }
        
      case 'deleteMany': {
        const { filter } = params;
        const originalCount = docs.length;
        const newDocs = docs.filter(doc => !this._matchesFilter(doc, filter));
        this._collections.set(collectionName, newDocs);
        
        return { 
          acknowledged: true, 
          deletedCount: originalCount - newDocs.length 
        };
      }
        
      case 'aggregate': {
        // This is a simplified aggregation implementation
        // For now, it just returns all documents
        // A full implementation would process the pipeline
        return docs;
      }
        
      case 'countDocuments': {
        const { query } = params;
        const count = docs.filter(doc => this._matchesFilter(doc, query)).length;
        return count;
      }
        
      case 'estimatedDocumentCount': {
        return docs.length;
      }
        
      default:
        throw new Error(`Unimplemented operation: ${operation}`);
    }
  }

  /**
   * Find documents that match a query
   * 
   * @param {Array} docs - Collection documents
   * @param {Object} query - Query filter
   * @returns {Promise<Array>} Matching documents
   */
  async _executeFind(docs, query) {
    return docs.filter(doc => this._matchesFilter(doc, query));
  }

  /**
   * Check if a document matches a filter
   * 
   * @param {Object} doc - Document to check
   * @param {Object} filter - Filter to apply
   * @returns {boolean} Whether the document matches
   */
  _matchesFilter(doc, filter) {
    // Simple implementation for basic query matching
    // A full implementation would handle operators like $gt, $lt, etc.
    return Object.entries(filter).every(([key, value]) => {
      if (key === '_id' && typeof value === 'string') {
        // Handle ObjectId comparison
        return doc._id.toString() === value;
      }
      
      // Handle nested properties with dot notation
      if (key.includes('.')) {
        const parts = key.split('.');
        let current = doc;
        for (const part of parts.slice(0, -1)) {
          if (current === undefined || current === null) {
            return false;
          }
          current = current[part];
        }
        return current && current[parts[parts.length - 1]] === value;
      }
      
      // Handle operators
      if (typeof value === 'object' && value !== null) {
        // $eq operator
        if (value.$eq !== undefined) {
          return doc[key] === value.$eq;
        }
        
        // $ne operator
        if (value.$ne !== undefined) {
          return doc[key] !== value.$ne;
        }
        
        // $in operator
        if (value.$in !== undefined) {
          return Array.isArray(value.$in) && value.$in.includes(doc[key]);
        }
        
        // $nin operator
        if (value.$nin !== undefined) {
          return !Array.isArray(value.$nin) || !value.$nin.includes(doc[key]);
        }
        
        // $gt operator
        if (value.$gt !== undefined) {
          return doc[key] > value.$gt;
        }
        
        // $gte operator
        if (value.$gte !== undefined) {
          return doc[key] >= value.$gte;
        }
        
        // $lt operator
        if (value.$lt !== undefined) {
          return doc[key] < value.$lt;
        }
        
        // $lte operator
        if (value.$lte !== undefined) {
          return doc[key] <= value.$lte;
        }
        
        // $exists operator
        if (value.$exists !== undefined) {
          return (key in doc) === value.$exists;
        }
        
        // If value is a nested object, not an operator
        return JSON.stringify(doc[key]) === JSON.stringify(value);
      }
      
      return doc[key] === value;
    });
  }

  /**
   * Apply update operators to a document
   * 
   * @param {Object} update - Update operations
   * @param {Object} doc - Document to update
   * @returns {Object} Updated document
   */
  _applyUpdate(update, doc) {
    const newDoc = { ...doc };
    
    // Handle different update operators
    if (update.$set) {
      Object.entries(update.$set).forEach(([key, value]) => {
        // Handle dot notation for nested fields
        if (key.includes('.')) {
          const parts = key.split('.');
          let current = newDoc;
          for (let i = 0; i < parts.length - 1; i++) {
            const part = parts[i];
            if (!(part in current)) {
              current[part] = {};
            }
            current = current[part];
          }
          current[parts[parts.length - 1]] = value;
        } else {
          newDoc[key] = value;
        }
      });
    }
    
    if (update.$unset) {
      Object.keys(update.$unset).forEach(key => {
        if (key.includes('.')) {
          const parts = key.split('.');
          let current = newDoc;
          for (let i = 0; i < parts.length - 1; i++) {
            const part = parts[i];
            if (!(part in current)) {
              return;
            }
            current = current[part];
          }
          delete current[parts[parts.length - 1]];
        } else {
          delete newDoc[key];
        }
      });
    }
    
    if (update.$inc) {
      Object.entries(update.$inc).forEach(([key, value]) => {
        if (key.includes('.')) {
          const parts = key.split('.');
          let current = newDoc;
          for (let i = 0; i < parts.length - 1; i++) {
            const part = parts[i];
            if (!(part in current)) {
              current[part] = {};
            }
            current = current[part];
          }
          const lastPart = parts[parts.length - 1];
          current[lastPart] = (current[lastPart] || 0) + value;
        } else {
          newDoc[key] = (newDoc[key] || 0) + value;
        }
      });
    }
    
    if (update.$push) {
      Object.entries(update.$push).forEach(([key, value]) => {
        if (key.includes('.')) {
          const parts = key.split('.');
          let current = newDoc;
          for (let i = 0; i < parts.length - 1; i++) {
            const part = parts[i];
            if (!(part in current)) {
              current[part] = {};
            }
            current = current[part];
          }
          const lastPart = parts[parts.length - 1];
          if (!Array.isArray(current[lastPart])) {
            current[lastPart] = [];
          }
          current[lastPart].push(value);
        } else {
          if (!Array.isArray(newDoc[key])) {
            newDoc[key] = [];
          }
          newDoc[key].push(value);
        }
      });
    }
    
    if (update.$pull) {
      Object.entries(update.$pull).forEach(([key, value]) => {
        if (!Array.isArray(newDoc[key])) {
          return;
        }
        
        newDoc[key] = newDoc[key].filter(item => {
          if (typeof value === 'object') {
            return !this._matchesFilter(item, value);
          }
          return item !== value;
        });
      });
    }
    
    // If the update is a replacement (not using operators)
    if (!Object.keys(update).some(key => key.startsWith('$'))) {
      return { _id: newDoc._id, ...update };
    }
    
    return newDoc;
  }

  /**
   * Simulate a network error during an operation
   * 
   * @param {string} operation - The operation that failed
   * @returns {Promise<never>} A rejected promise
   */
  _simulateNetworkError(operation) {
    this._stats.failedOperations++;
    
    const errorTypes = [
      'connection reset by peer',
      'socket hang up',
      'connection timed out',
      'network unreachable'
    ];
    
    const randomError = errorTypes[Math.floor(Math.random() * errorTypes.length)];
    const error = new Error(`MongoDB ${operation} failed: ${randomError}`);
    error.code = 'NETWORK_ERROR';
    error.operation = operation;
    
    return Promise.reject(error);
  }

  /**
   * Simulate operation success
   * 
   * @param {string} operation - The operation that succeeded
   * @param {*} result - The result to return
   * @returns {Promise<*>} A resolved promise with the result
   */
  _simulateSuccess(operation, result) {
    this._stats.successfulOperations++;
    return Promise.resolve(result);
  }

  /**
   * Simulate a MongoDB ObjectId
   * @returns {Object} A simulated ObjectId
   */
  createObjectId() {
    const id = uuidv4().replace(/-/g, '').substring(0, 24);
    return {
      toString: () => id,
      toHexString: () => id,
      equals: (otherId) => id === (typeof otherId === 'string' ? otherId : otherId.toString())
    };
  }

  /**
   * Create a MongoDB-like error
   * 
   * @param {string} code - Error code
   * @param {string} message - Error message
   * @returns {Error} MongoDB-like error
   */
  createError(code, message) {
    const error = new Error(message);
    error.code = code;
    error.name = 'MongoError';
    return error;
  }
}

/**
 * Create a MongoDB client mock
 * @returns {Object} MongoDB client mock
 */
function createMongoClientMock() {
  const dbMock = new MongoDBMock();
  
  return {
    connect: createMockFn('client.connect').mockImplementation(() => dbMock.connect()),
    close: createMockFn('client.close').mockImplementation(() => dbMock.close()),
    db: createMockFn('client.db').mockImplementation(() => dbMock.db()),
    
    // Allow configuration of the mock
    _mock: dbMock
  };
}

/**
 * Create a mongoose connection mock
 * @returns {Object} Mongoose connection mock
 */
function createMongooseConnectionMock() {
  const dbMock = new MongoDBMock();
  
  // Create a mock model that simulates mongoose models
  const createModelMock = (modelName, schema) => {
    return {
      modelName,
      schema,
      find: createMockFn(`${modelName}.find`).mockImplementation(() => ({ exec: () => Promise.resolve([]) })),
      findOne: createMockFn(`${modelName}.findOne`).mockImplementation(() => ({ exec: () => Promise.resolve(null) })),
      findById: createMockFn(`${modelName}.findById`).mockImplementation(() => ({ exec: () => Promise.resolve(null) })),
      create: createMockFn(`${modelName}.create`).mockImplementation((doc) => Promise.resolve({ ...doc, _id: dbMock.createObjectId() })),
      updateOne: createMockFn(`${modelName}.updateOne`).mockImplementation(() => Promise.resolve({ nModified: 1 })),
      updateMany: createMockFn(`${modelName}.updateMany`).mockImplementation(() => Promise.resolve({ nModified: 1 })),
      deleteOne: createMockFn(`${modelName}.deleteOne`).mockImplementation(() => Promise.resolve({ deletedCount: 1 })),
      deleteMany: createMockFn(`${modelName}.deleteMany`).mockImplementation(() => Promise.resolve({ deletedCount: 1 })),
      countDocuments: createMockFn(`${modelName}.countDocuments`).mockImplementation(() => Promise.resolve(0)),
      exists: createMockFn(`${modelName}.exists`).mockImplementation(() => Promise.resolve(false)),
    };
  };
  
  return {
    // Connection state
    readyState: 1, // Connected
    models: {},
    
    // Connection methods
    on: createMockFn('connection.on').mockImplementation((event, callback) => this),
    once: createMockFn('connection.once').mockImplementation((event, callback) => this),
    
    // Model creation
    model: createMockFn('connection.model').mockImplementation((name, schema) => {
      if (!this.models[name]) {
        this.models[name] = createModelMock(name, schema);
      }
      return this.models[name];
    }),
    
    // Database operations
    collection: createMockFn('connection.collection').mockImplementation((name) => dbMock._getCollection(name)),
    
    // Allow configuration of the mock
    _mock: dbMock
  };
}

// Create the central MongoDB mock
const mongodbMock = {
  // Main exports
  MongoClient: {
    connect: createMockFn('MongoClient.connect').mockImplementation(() => createMongoClientMock())
  },
  
  // Helper for creating ObjectIds
  ObjectId: function(id) {
    const dbMock = new MongoDBMock();
    return dbMock.createObjectId(id);
  },
  
  // Connection mock for mongoose
  createConnection: createMockFn('createConnection').mockImplementation(() => createMongooseConnectionMock()),
  
  // Configure method for test setup
  configure: (config) => {
    const dbMock = new MongoDBMock();
    return dbMock.configure(config);
  },
  
  // Reset method for test cleanup
  reset: () => {
    const dbMock = new MongoDBMock();
    return dbMock.reset();
  }
};

module.exports = { mongodbMock }; 