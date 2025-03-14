/**
 * Mock Registry
 * 
 * A system for registering and managing mock implementations of external services.
 * This registry ensures consistency between mocks and production code,
 * and integrates with both Jest's mocking system and our TestServiceRegistry.
 */

// Import testServiceRegistry to use its mock functions
const testServiceRegistry = require('./TestServiceRegistry.cjs');
const jestInstance = require('./jestInstance.cjs');
// Using jestInstance's mock functions consistently throughout the codebase

class MockRegistry {
  constructor() {
    this.mocks = new Map();
    this.originalModules = new Map();
    this.mockPaths = new Map();
    
    // Map of service names to their module paths
    this.serviceModulePaths = {
      'stripe': '../config/stripeConfig.cjs',
      'mongodb': '../utils/dbConnectionManager.cjs',
      'auth0': '../config/auth0Config.cjs',
      'socket.io': '../mocks/socket.mock.cjs',
      // Add more mappings as needed
    };
  }

  /**
   * Create a mock function
   * @param {string} name - Optional name for the mock function
   * @returns {Function} A mock function
   */
  createMockFunction(name = '') {
    return testServiceRegistry.createMockFunction(name);
  }

  /**
   * Register a service mock with proper structure and integration
   * 
   * @param {string} serviceName - The name of the service to mock
   * @param {Object} mockImplementation - The mock implementation
   * @param {Object} options - Options for mock registration
   * @param {boolean} options.setupJestMock - Whether to set up Jest module mocking
   * @param {string} options.modulePath - Custom module path for Jest mocking
   * @param {boolean} options.preserveApi - Whether to preserve the API of the original service
   * @returns {Object} The registered mock
   */
  registerServiceMock(serviceName, mockImplementation, options = {}) {
    console.log(`[MockRegistry] Registering service mock for ${serviceName}`);
    
    if (!mockImplementation) {
      console.error(`[MockRegistry] Cannot register null/undefined mock for ${serviceName}`);
      return null;
    }
    
    const normalizedOptions = {
      setupJestMock: true,
      preserveApi: true,
      ...options
    };
    
    // Normalize mock structure to match production exports
    let normalizedMock;
    try {
      normalizedMock = this.normalizeMockStructure(
        serviceName, 
        mockImplementation,
        normalizedOptions
      );
      console.log(`[MockRegistry] Normalized mock structure for ${serviceName}`);
    } catch (error) {
      console.error(`[MockRegistry] Error normalizing mock for ${serviceName}:`, error);
      // Fall back to original implementation
      normalizedMock = mockImplementation;
    }
    
    // Register with TestServiceRegistry if available
    try {
      if (testServiceRegistry && typeof testServiceRegistry.registerMock === 'function') {
        testServiceRegistry.registerMock(serviceName, normalizedMock, normalizedOptions.preserveApi);
        console.log(`[MockRegistry] Registered ${serviceName} with TestServiceRegistry`);
      } else {
        console.warn(`[MockRegistry] TestServiceRegistry not available, skipping registration for ${serviceName}`);
      }
    } catch (error) {
      console.error(`[MockRegistry] Error registering ${serviceName} with TestServiceRegistry:`, error);
    }
    
    // Store in internal registry
    this.mocks.set(serviceName, normalizedMock);
    console.log(`[MockRegistry] Added ${serviceName} to internal mock registry`);
    
    // Set up Jest module mocking if needed
    if (normalizedOptions.setupJestMock) {
      const success = this.setupJestMock(serviceName, normalizedMock, normalizedOptions);
      if (success) {
        console.log(`[MockRegistry] Successfully set up Jest mock for ${serviceName}`);
      } else {
        console.warn(`[MockRegistry] Failed to set up Jest mock for ${serviceName}`);
      }
    }
    
    return normalizedMock;
  }
  
  /**
   * Normalize a mock implementation's structure to match production exports
   * 
   * @param {string} serviceName - The name of the service
   * @param {Object} mockImplementation - The mock implementation
   * @param {Object} options - Normalization options
   * @returns {Object} The normalized mock
   */
  normalizeMockStructure(serviceName, mockImplementation, options = {}) {
    // Handle special cases based on service name
    switch (serviceName) {
      case 'stripe':
        // Stripe mock should export as 'stripe' to match production
        return this.normalizeStripeMock(mockImplementation);
        
      case 'mongodb':
        // MongoDB mock special handling
        return this.normalizeMongoDB(mockImplementation);
        
      case 'socket.io':
        // Socket.io mock special handling
        return this.normalizeSocketIOMock(mockImplementation);
        
      default:
        // Generic mock normalization
        return mockImplementation;
    }
  }
  
  /**
   * Normalize a Stripe mock to match production exports
   * 
   * @param {Object} stripeMock - The Stripe mock implementation
   * @returns {Object} The normalized Stripe mock
   */
  normalizeStripeMock(stripeMock) {
    // If this is already the normalized structure, return as is
    if (stripeMock.stripe) {
      return stripeMock;
    }
    
    // If it's the raw stripeMock object, wrap it properly
    return {
      stripe: stripeMock,
      stripeMock, // Keep original for backward compatibility
      __isMock: true,
      __resetMock: typeof stripeMock.reset === 'function' ? 
        stripeMock.reset.bind(stripeMock) : 
        () => console.warn('No reset method on stripeMock')
    };
  }
  
  /**
   * Normalize a MongoDB mock to match production exports
   * 
   * @param {Object} mongoDBMock - The MongoDB mock implementation
   * @returns {Object} The normalized MongoDB mock
   */
  normalizeMongoDB(mongoDBMock) {
    // MongoDB specific normalization
    // This would handle the specific structure needed for MongoDB mocking
    return mongoDBMock;
  }
  
  /**
   * Normalize a Socket.IO mock to match production exports
   * 
   * @param {Object} socketIOMock - The Socket.IO mock implementation
   * @returns {Object} The normalized Socket.IO mock
   */
  normalizeSocketIOMock(socketIOMock) {
    console.log('[MockRegistry] Normalizing socket.io mock');
    
    if (!socketIOMock) {
      console.error('[MockRegistry] Socket.IO mock is null or undefined');
      // Create a minimal placeholder mock to prevent errors
      return {
        mockIO: () => ({
          on: jest.fn(),
          emit: jest.fn(),
          to: jest.fn().mockReturnThis(),
          removeAllListeners: jest.fn()
        }),
        __isMock: true,
        __resetMock: () => console.log('[MockRegistry] Resetting placeholder socket.io mock')
      };
    }
    
    // Check if mock has essential methods
    if (typeof socketIOMock.mockIO !== 'function') {
      console.warn('[MockRegistry] Socket.IO mock missing mockIO method, adding placeholder');
      socketIOMock.mockIO = () => ({
        on: jest.fn(),
        emit: jest.fn(),
        to: jest.fn().mockReturnThis(),
        removeAllListeners: jest.fn()
      });
    }
    
    // Ensure the mock has a reset method
    if (typeof socketIOMock.resetMockIO === 'function') {
      // If resetMockIO exists, use it
      socketIOMock.__resetMock = () => {
        console.log('[MockRegistry] Resetting Socket.IO mock via resetMockIO');
        socketIOMock.resetMockIO();
      };
    } else {
      // Add a default reset method if none exists
      socketIOMock.__resetMock = () => {
        console.log('[MockRegistry] Resetting Socket.IO mock with standard cleanup');
        // Reset any internal state if needed
        if (socketIOMock.mockIO) {
          const io = socketIOMock.mockIO();
          if (io) {
            // Reset common socket methods
            if (typeof io.removeAllListeners === 'function') {
              io.removeAllListeners();
            }
            if (typeof io.cleanup === 'function') {
              io.cleanup();
            }
            // Reset common Jest mock methods
            ['on', 'emit', 'to'].forEach(method => {
              if (io[method] && typeof io[method].mockReset === 'function') {
                io[method].mockReset();
              }
            });
          }
        }
      };
    }
    
    // Mark as a mock
    socketIOMock.__isMock = true;
    
    console.log('[MockRegistry] Successfully normalized socket.io mock');
    return socketIOMock;
  }
  
  /**
   * Set up Jest module mocking
   * 
   * @param {string} serviceName - The name of the service
   * @param {Object} mockImplementation - The mock implementation
   * @param {Object} options - Mocking options
   * @returns {boolean} Whether the mock was successfully set up
   */
  setupJestMock(serviceName, mockImplementation, options = {}) {
    console.log(`[MockRegistry] Setting up Jest mock for ${serviceName}`);
    
    // Verify jestInstance is available
    if (!jestInstance || typeof jestInstance.mock !== 'function') {
      console.error(`[MockRegistry] Cannot set up Jest mock: jestInstance not properly initialized`);
      return false;
    }
    
    // Determine the module path to mock
    const modulePath = options.modulePath || this.serviceModulePaths[serviceName];
    
    if (!modulePath) {
      console.warn(`[MockRegistry] Cannot set up Jest mock for ${serviceName}: Module path not found`);
      return false;
    }
    
    // Set up the Jest mock
    try {
      jestInstance.mock(modulePath, () => mockImplementation);
      this.mockPaths.set(serviceName, modulePath);
      console.log(`[MockRegistry] Successfully set up Jest mock for ${serviceName} at ${modulePath}`);
      
      // Special handling for socket.io mock
      if (serviceName === 'socket.io' && mockImplementation) {
        try {
          // If this is a socket.io mock, ensure it has the necessary methods
          if (typeof mockImplementation.mockIO !== 'function') {
            console.warn(`[MockRegistry] socket.io mock missing mockIO method`);
          }
          
          // Add socket.io specific initialization if needed
          if (typeof mockImplementation.initializeSocketMock === 'function') {
            mockImplementation.initializeSocketMock();
            console.log(`[MockRegistry] Initialized socket.io mock`);
          }
        } catch (socketError) {
          console.error(`[MockRegistry] Error in socket.io initialization:`, socketError);
        }
      }
      
      return true;
    } catch (error) {
      console.error(`[MockRegistry] Error setting up Jest mock for ${serviceName}:`, error);
      console.error(error.stack);
      return false;
    }
  }
  
  /**
   * Reset a specific mock
   * 
   * @param {string} serviceName - The name of the service to reset
   */
  resetMock(serviceName) {
    const mock = this.mocks.get(serviceName);
    
    if (!mock) {
      console.warn(`Cannot reset mock for ${serviceName}: Mock not found`);
      return;
    }
    
    // Use the __resetMock method if available
    if (typeof mock.__resetMock === 'function') {
      mock.__resetMock();
    } 
    // Call reset method directly if available
    else if (typeof mock.reset === 'function') {
      mock.reset();
    }
    // For socket.io mock, check for resetMockIO
    else if (serviceName === 'socket.io' && typeof mock.resetMockIO === 'function') {
      mock.resetMockIO();
    }
    // For simple mocks without reset methods
    else {
      // Reset all Jest mock functions in the mock
      Object.keys(mock).forEach(key => {
        if (typeof mock[key] === 'function' && typeof mock[key].mockReset === 'function') {
          mock[key].mockReset();
        }
      });
    }
  }
  
  /**
   * Reset all registered mocks
   */
  resetAllMocks() {
    for (const [serviceName] of this.mocks.entries()) {
      this.resetMock(serviceName);
    }
  }
  
  /**
   * Create pre-configured mock profiles for common testing scenarios
   * 
   * @param {string} profileName - The name of the profile to use
   * @returns {Object} Mock configuration profile
   */
  getProfile(profileName) {
    const profiles = {
      unit: {
        stripe: { simulateNetworkErrors: false },
        mongodb: { inMemory: true, seedData: false }
      },
      integration: {
        stripe: { simulateNetworkErrors: false },
        mongodb: { inMemory: true, seedData: true }
      },
      performance: {
        stripe: { simulateNetworkErrors: true, simulateLatency: true },
        mongodb: { inMemory: false, seedData: true }
      }
    };
    
    return profiles[profileName] || {};
  }
  
  /**
   * Apply a mock profile configuration
   * 
   * @param {string} profileName - The name of the profile to apply
   */
  applyProfile(profileName) {
    const profile = this.getProfile(profileName);
    
    if (!profile) {
      console.warn(`Profile ${profileName} not found`);
      return;
    }
    
    // Apply the profile configuration to each registered mock
    for (const [serviceName, config] of Object.entries(profile)) {
      const mock = this.mocks.get(serviceName);
      
      if (!mock) {
        console.warn(`Cannot apply profile to ${serviceName}: Mock not registered`);
        continue;
      }
      
      // Apply configuration
      if (typeof mock.__applyConfig === 'function') {
        mock.__applyConfig(config);
      } else {
        // Fallback to direct property assignment
        Object.assign(mock.__testState || {}, config);
      }
    }
  }

  /**
   * Apply all registered mocks to Jest
   * @returns {Object} Summary of applied mocks
   */
  applyMocks() {
    console.log('[MockRegistry] Applying all registered service mocks...');
    
    // First, ensure all mocks have valid module paths
    for (const [serviceName, mock] of this.mocks.entries()) {
      if (!this.mockPaths.has(serviceName)) {
        // If no path registered, try to find it from the service path mapping
        const modulePath = this.serviceModulePaths[serviceName];
        if (modulePath) {
          this.mockPaths.set(serviceName, modulePath);
          console.log(`[MockRegistry] Found module path for ${serviceName}: ${modulePath}`);
        } else {
          console.warn(`[MockRegistry] No module path found for ${serviceName}, mock will not be applied`);
        }
      }
    }
    
    // Then apply all mocks with proper error handling
    let appliedCount = 0;
    let errorCount = 0;
    const results = {
      applied: [],
      failed: []
    };
    
    for (const [serviceName, mockImplementation] of this.mocks.entries()) {
      const modulePath = this.mockPaths.get(serviceName);
      if (modulePath) {
        try {
          // Apply mock to Jest using the persistent jestInstance
          jestInstance.mock(modulePath, () => mockImplementation);
          console.log(`[MockRegistry] Successfully applied mock for ${serviceName} at ${modulePath}`);
          appliedCount++;
          results.applied.push(serviceName);
          
          // Special handling for socket.io mock
          if (serviceName === 'socket.io' && mockImplementation) {
            try {
              // If socket.io mock has a setupSocketMock method, call it
              if (typeof mockImplementation.setupSocketMock === 'function') {
                mockImplementation.setupSocketMock();
                console.log(`[MockRegistry] Applied special setup for socket.io mock`);
              }
              
              // Verify socket.io mock has required methods
              if (typeof mockImplementation.mockIO !== 'function') {
                console.warn(`[MockRegistry] socket.io mock missing mockIO method`);
              }
            } catch (socketError) {
              console.error(`[MockRegistry] Error in socket.io special setup:`, socketError);
            }
          }
        } catch (error) {
          console.error(`[MockRegistry] Error applying mock for ${serviceName}:`, error);
          errorCount++;
          results.failed.push({
            service: serviceName,
            error: error.message
          });
        }
      }
    }
    
    console.log(`[MockRegistry] Applied ${appliedCount} mocks with ${errorCount} errors`);
    return { 
      appliedCount, 
      errorCount,
      results
    };
  }

  /**
   * Reset all mocks (alias for resetAllMocks for backward compatibility)
   */
  resetAll() {
    this.resetAllMocks();
  }
}

// Export a singleton instance
const mockRegistry = new MockRegistry();
module.exports = mockRegistry; 