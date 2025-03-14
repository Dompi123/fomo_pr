/**
 * API Test Helper
 * 
 * This file provides utilities for testing API routes and controllers
 * without needing to spin up a full server. It allows direct testing
 * of route handlers with mocked requests and responses.
 */

// Use jestInstance for consistent Jest access across the codebase
const jestInstance = require('./jestInstance.cjs');
const { createMockRequest, createMockResponse, createMockNext } = require('./RequestResponseHelpers.cjs');

/**
 * API test helper class for testing route handlers directly
 */
class ApiTestHelper {
  /**
   * Create a new ApiTestHelper
   * 
   * @param {Object} options - Configuration options
   * @param {Function} options.routeHandler - The route handler function to test
   * @param {Object} options.authUser - Default authenticated user for requests
   */
  constructor(options = {}) {
    this.routeHandler = options.routeHandler;
    this.defaultAuthUser = options.authUser || null;
  }

  /**
   * Create a test context for an API request
   * 
   * @param {Object} options - Request options
   * @param {string} options.method - HTTP method (GET, POST, etc.)
   * @param {Object} options.body - Request body
   * @param {Object} options.params - Route parameters
   * @param {Object} options.query - Query parameters
   * @param {Object} options.headers - Request headers
   * @param {Object} options.user - Override default auth user
   * @returns {Object} The test context with req, res, next
   */
  createContext(options = {}) {
    const user = options.user !== undefined ? options.user : this.defaultAuthUser;
    
    return {
      req: createMockRequest({
        method: options.method || 'GET',
        body: options.body || {},
        params: options.params || {},
        query: options.query || {},
        headers: options.headers || {},
        user,
        ...options
      }),
      res: createMockResponse(),
      next: createMockNext()
    };
  }

  /**
   * Execute a test request to the route handler
   * 
   * @param {Object} options - Request options
   * @returns {Promise<Object>} The test result
   */
  async request(options = {}) {
    const ctx = this.createContext(options);
    
    // If there's a route handler, call it
    if (this.routeHandler) {
      try {
        await this.routeHandler(ctx.req, ctx.res, ctx.next);
      } catch (error) {
        // Store any uncaught errors
        ctx.uncaughtError = error;
      }
    }
    
    return {
      ...ctx,
      // Response data helpers
      statusCode: ctx.res._statusCode,
      data: ctx.res._data,
      headers: ctx.res._headers,
      
      // Analysis helpers
      wasHandled: ctx.res._ended || ctx.res._statusCode !== 200 || ctx.res._data !== null,
      wasError: ctx.next.mock.calls.length > 0 && ctx.next.mock.calls[0][0] instanceof Error,
      wasNextCalled: ctx.next.mock.calls.length > 0,
      error: ctx.next.mock.calls.length > 0 && ctx.next.mock.calls[0][0] instanceof Error 
        ? ctx.next.mock.calls[0][0] 
        : (ctx.uncaughtError || null),
      
      // Shortcut methods for common assertions
      assertStatus: function(expectedStatus) {
        expect(this.statusCode).toBe(expectedStatus);
        return this;
      },
      
      assertData: function(expectedData) {
        expect(this.data).toEqual(expectedData);
        return this;
      },
      
      assertHeader: function(name, expectedValue) {
        const value = this.headers[name.toLowerCase()];
        expect(value).toBe(expectedValue);
        return this;
      },
      
      assertError: function(expectedMessage) {
        expect(this.error).toBeTruthy();
        if (expectedMessage) {
          expect(this.error.message).toContain(expectedMessage);
        }
        return this;
      },
      
      assertNoError: function() {
        expect(this.error).toBeFalsy();
        return this;
      }
    };
  }
  
  /**
   * Perform a GET request to the route handler
   * 
   * @param {Object} options - Request options
   * @returns {Promise<Object>} The test result
   */
  async get(options = {}) {
    return this.request({ 
      ...options,
      method: 'GET' 
    });
  }
  
  /**
   * Perform a POST request to the route handler
   * 
   * @param {Object} options - Request options
   * @returns {Promise<Object>} The test result
   */
  async post(options = {}) {
    return this.request({ 
      ...options,
      method: 'POST' 
    });
  }
  
  /**
   * Perform a PUT request to the route handler
   * 
   * @param {Object} options - Request options
   * @returns {Promise<Object>} The test result
   */
  async put(options = {}) {
    return this.request({ 
      ...options,
      method: 'PUT' 
    });
  }
  
  /**
   * Perform a DELETE request to the route handler
   * 
   * @param {Object} options - Request options
   * @returns {Promise<Object>} The test result
   */
  async delete(options = {}) {
    return this.request({ 
      ...options,
      method: 'DELETE' 
    });
  }
  
  /**
   * Perform a PATCH request to the route handler
   * 
   * @param {Object} options - Request options
   * @returns {Promise<Object>} The test result
   */
  async patch(options = {}) {
    return this.request({ 
      ...options,
      method: 'PATCH' 
    });
  }
}

/**
 * Create an API test helper for a route handler
 * 
 * @param {Function} routeHandler - The route handler to test
 * @param {Object} options - Configuration options
 * @returns {ApiTestHelper} The API test helper
 */
function createApiTestHelper(routeHandler, options = {}) {
  return new ApiTestHelper({
    routeHandler,
    ...options
  });
}

module.exports = {
  ApiTestHelper,
  createApiTestHelper
}; 