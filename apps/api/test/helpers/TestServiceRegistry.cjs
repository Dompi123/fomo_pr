/**
 * Test Service Registry
 * 
 * A registry for managing service dependencies and mocks in tests.
 * This allows tests to substitute mock implementations of services without
 * modifying source code.
 */

// Using the global jest object provided by the test runner
// No direct import needed
const ServiceContainer = require('../../utils/serviceContainer.cjs');

class TestServiceRegistry {
  constructor() {
    this.mocks = new Map();
    this.originals = new Map();
    this.container = new ServiceContainer();
    this.autoMockMode = false;
  }

  /**
   * Register a mock implementation for a service
   * @param {string} serviceName - The name of the service to mock
   * @param {Object} mockImplementation - The mock implementation
   * @param {boolean} preserveApi - Whether to preserve the API of the original service
   * @returns {Object} The registered mock
   */
  registerMock(serviceName, mockImplementation, preserveApi = true) {
    // Check if jest is available in the global scope
    const hasJest = typeof global.jest !== 'undefined';

    if (preserveApi && this.originals.has(serviceName)) {
      // Ensure mock preserves the same API as original
      const original = this.originals.get(serviceName);
      Object.keys(original).forEach(key => {
        if (typeof original[key] === 'function' && !mockImplementation[key]) {
          if (hasJest) {
            mockImplementation[key] = global.jest.fn();
          } else {
            // Fallback if jest is not available - create a simple function stub
            mockImplementation[key] = function() { return undefined; };
          }
        }
      });
    }

    // Add test helper methods
    mockImplementation.__isMock = true;
    mockImplementation.__serviceName = serviceName;
    mockImplementation.__resetMock = function() {
      Object.keys(this).forEach(key => {
        if (typeof this[key] === 'function' && this[key].mockReset) {
          this[key].mockReset();
        }
      });
    };

    this.mocks.set(serviceName, mockImplementation);
    return mockImplementation;
  }

  /**
   * Get a service from the registry
   * If the service has been mocked, returns the mock
   * Otherwise, returns the original implementation
   * 
   * @param {string} serviceName - The name of the service to get
   * @returns {Object} The service implementation (mock or original)
   */
  getService(serviceName) {
    if (this.mocks.has(serviceName)) {
      return this.mocks.get(serviceName);
    }
    
    if (this.autoMockMode) {
      // In auto-mock mode, create a mock on demand
      return this.createAutoMock(serviceName);
    }
    
    // Get the service from the container
    try {
      const service = this.container.getService(serviceName);
      this.originals.set(serviceName, service);
      return service;
    } catch (error) {
      throw new Error(`Service "${serviceName}" not found and no mock registered. ${error.message}`);
    }
  }

  /**
   * Create an auto-generated mock for a service
   * Used in auto-mock mode when a service is requested but no specific mock is registered
   * 
   * @param {string} serviceName - The name of the service to mock
   * @returns {Object} The generated mock
   */
  createAutoMock(serviceName) {
    const hasJest = typeof global.jest !== 'undefined';
    
    const autoMock = {
      __isMock: true,
      __serviceName: serviceName,
      __isAutoMock: true,
      __resetMock: function() {
        Object.keys(this).forEach(key => {
          if (typeof this[key] === 'function' && this[key].mockReset) {
            this[key].mockReset();
          }
        });
      }
    };
    
    // Create a proxy to automatically generate mock methods on demand
    const mockProxy = new Proxy(autoMock, {
      get(target, prop) {
        if (prop in target) {
          return target[prop];
        }
        
        // Auto-create mock methods
        if (typeof prop === 'string' && !prop.startsWith('__')) {
          if (hasJest) {
            target[prop] = global.jest.fn().mockName(`${serviceName}.${prop}`);
          } else {
            // Fallback mock function if jest is not available
            const mockFn = function() { return undefined; };
            mockFn.mockName = () => mockFn;
            mockFn.mockReset = () => {};
            target[prop] = mockFn;
          }
          return target[prop];
        }
        
        return undefined;
      }
    });
    
    this.mocks.set(serviceName, mockProxy);
    return mockProxy;
  }

  /**
   * Register a real service implementation
   * 
   * @param {string} name - The name of the service
   * @param {Function} ServiceClass - The service class constructor
   * @returns {Object} The registered service
   */
  registerService(name, ServiceClass) {
    const service = this.container.register(name, ServiceClass);
    this.originals.set(name, service);
    return service;
  }

  /**
   * Enable auto-mock mode
   * In this mode, any requested service that hasn't been explicitly
   * registered will automatically get a mock implementation
   * 
   * @param {boolean} enabled - Whether to enable auto-mock mode
   */
  setAutoMockMode(enabled = true) {
    this.autoMockMode = enabled;
  }

  /**
   * Initialize the service container
   * This initializes all registered real services
   */
  async initialize() {
    return this.container.initialize();
  }

  /**
   * Reset all registered mocks
   */
  resetAllMocks() {
    for (const [_, mock] of this.mocks.entries()) {
      if (typeof mock.__resetMock === 'function') {
        mock.__resetMock();
      }
    }
  }

  /**
   * Clear all registered mocks and services
   */
  async cleanup() {
    this.mocks.clear();
    this.originals.clear();
    await this.container.cleanup();
  }

  /**
   * Create a dependency getter function
   * This returns a function that can be used in place of getDependency
   * in services to ensure they use mocked dependencies in tests
   * 
   * @returns {Function} A dependency getter function
   */
  createDependencyGetter() {
    const registry = this;
    return function getDependency(name) {
      return registry.getService(name);
    };
  }

  /**
   * Apply mocks to modules using Jest's module mocking system
   * This patches the require system to return mocks for specified modules
   */
  applyModuleMocks() {
    const hasJest = typeof global.jest !== 'undefined';
    if (!hasJest) {
      console.warn('Cannot apply module mocks: Jest not available in this environment');
      return;
    }

    for (const [name, mock] of this.mocks.entries()) {
      // Find the module path that corresponds to this service
      // This requires a naming convention or a mapping between service names and module paths
      const modulePath = this.resolveModulePath(name);
      if (modulePath) {
        global.jest.mock(modulePath, () => mock);
      }
    }
  }

  /**
   * Resolve a service name to a module path
   * This is a simplistic implementation - in a real system, you would have
   * a more sophisticated mapping between service names and module paths
   * 
   * @param {string} serviceName - The name of the service
   * @returns {string|null} The module path, or null if not found
   */
  resolveModulePath(serviceName) {
    // This is a simplified implementation
    // In a real system, you would have a more comprehensive mapping
    const commonPaths = {
      'stripe': 'stripe',
      'payment-processor': '../../services/payment/PaymentProcessor.cjs',
      'feature-manager': '../../services/payment/FeatureManager.cjs',
      'transaction-manager': '../../services/payment/TransactionManager.cjs',
      'idempotency-service': '../../services/IdempotencyService.cjs',
      'circuit-breaker': '../../utils/circuitBreaker.cjs',
      'socket-io': 'socket.io'
      // Add more mappings as needed
    };
    
    return commonPaths[serviceName] || null;
  }
}

// Create a singleton instance
const instance = new TestServiceRegistry();

module.exports = instance; 