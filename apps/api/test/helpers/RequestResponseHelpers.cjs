/**
 * Request and Response Helpers
 * 
 * This file provides utilities for mocking Express request and response objects
 * for testing middleware, route handlers, and controllers.
 */

// Use jestInstance for consistent Jest access across the codebase
const jestInstance = require('./jestInstance.cjs');

/**
 * Create a mock Express request object
 * 
 * @param {Object} options - Options for the mock request
 * @param {Object} options.user - User object to attach to the request
 * @param {Object} options.body - Request body
 * @param {Object} options.params - Route parameters
 * @param {Object} options.query - Query parameters
 * @param {Object} options.headers - Request headers
 * @param {Object} options.cookies - Request cookies
 * @param {Object} options.session - Session data
 * @param {Object} options.app - Express app object
 * @returns {Object} A mock Express request object
 */
function createMockRequest(options = {}) {
  const headers = {
    ...(options.headers || {})
  };
  
  // Convert header keys to lowercase for case-insensitive access
  const lowercaseHeaders = {};
  Object.keys(headers).forEach(key => {
    lowercaseHeaders[key.toLowerCase()] = headers[key];
  });
  
  return {
    // Standard request properties
    user: options.user || null,
    body: options.body || {},
    params: options.params || {},
    query: options.query || {},
    headers: lowercaseHeaders,
    cookies: options.cookies || {},
    session: options.session || {},
    
    // Express-specific properties
    app: options.app || { locals: {} },
    
    // Express request methods
    get: jestInstance.fn((header) => {
      return lowercaseHeaders[header.toLowerCase()];
    }),
    
    // Common request methods
    is: jestInstance.fn((type) => {
      const contentType = lowercaseHeaders['content-type'] || '';
      return contentType.includes(type);
    }),
    
    // Express middleware usually adds these objects
    ip: options.ip || '127.0.0.1',
    protocol: options.protocol || 'http',
    secure: options.secure || false,
    hostname: options.hostname || 'localhost',
    originalUrl: options.originalUrl || '/',
    path: options.path || '/',
    method: options.method || 'GET',
    
    // Additional options
    ...options
  };
}

/**
 * Create a mock Express response object
 * 
 * @returns {Object} A mock Express response object with spy methods
 */
function createMockResponse() {
  // Storage for response state
  const res = {
    _statusCode: 200,
    _headers: {},
    _data: null,
    _cookies: [],
    _ended: false,
    _locals: {},
    
    // Express response methods
    status: jestInstance.fn(function(code) {
      this._statusCode = code;
      return this;
    }),
    
    json: jestInstance.fn(function(data) {
      this._data = data;
      return this;
    }),
    
    send: jestInstance.fn(function(data) {
      this._data = data;
      return this;
    }),
    
    end: jestInstance.fn(function(data) {
      if (data) this._data = data;
      this._ended = true;
      return this;
    }),
    
    setHeader: jestInstance.fn(function(name, value) {
      this._headers[name.toLowerCase()] = value;
      return this;
    }),
    
    getHeader: jestInstance.fn(function(name) {
      return this._headers[name.toLowerCase()];
    }),
    
    removeHeader: jestInstance.fn(function(name) {
      delete this._headers[name.toLowerCase()];
      return this;
    }),
    
    cookie: jestInstance.fn(function(name, value, options) {
      this._cookies.push({ name, value, options });
      return this;
    }),
    
    clearCookie: jestInstance.fn(function(name, options) {
      this._cookies = this._cookies.filter(c => c.name !== name);
      return this;
    }),
    
    redirect: jestInstance.fn(function(url) {
      this._redirect = url;
      return this;
    }),
    
    render: jestInstance.fn(function(view, data) {
      this._view = view;
      this._data = data;
      return this;
    }),
    
    // Express response properties
    locals: {},
    
    // Test helper methods
    _getStatusCode: function() { 
      return this._statusCode; 
    },
    _getData: function() { 
      return this._data; 
    },
    _getHeaders: function() { 
      return this._headers; 
    },
    _getCookies: function() { 
      return this._cookies; 
    },
    _getRedirect: function() { 
      return this._redirect; 
    },
    _isEnded: function() { 
      return this._ended; 
    }
  };
  
  return res;
}

/**
 * Create a mock Express next function
 * 
 * @returns {Function} A Jest mock function representing Express next
 */
function createMockNext() {
  try {
    // Ensure we're using a valid Jest mock function with proper methods
    const mockNext = jestInstance.fn();
    
    // Verify the mock has expected properties
    if (!mockNext.mock || !Array.isArray(mockNext.mock.calls)) {
      console.warn('[TEST] createMockNext: jestInstance.fn() did not return a proper mock');
      
      // Create a fallback mock with the expected structure
      const fallbackMock = function(...args) {
        fallbackMock.mock.calls.push(args);
        return fallbackMock.mockReturnValue;
      };
      
      fallbackMock.mock = {
        calls: [],
        results: [],
        instances: []
      };
      
      fallbackMock.mockReturnValue = undefined;
      fallbackMock.mockClear = function() {
        fallbackMock.mock.calls = [];
        fallbackMock.mock.results = [];
        fallbackMock.mock.instances = [];
      };
      
      console.log('[TEST] createMockNext: Created fallback mock function');
      return fallbackMock;
    }
    
    console.log('[TEST] createMockNext: Created proper Jest mock function');
    return mockNext;
  } catch (error) {
    console.error('[TEST] Error creating mock next function:', error);
    
    // Return a minimal fallback implementation
    const fallbackFn = function() {};
    fallbackFn.mock = { calls: [] };
    return fallbackFn;
  }
}

/**
 * Creates a complete middleware test context with request, response, and next
 * 
 * @param {Object} options - Options for the middleware test
 * @param {Object} options.req - Request options
 * @param {Object} options.res - Response options
 * @returns {Object} The middleware test context with req, res, and next
 */
function createMiddlewareTestContext(options = {}) {
  return {
    req: createMockRequest(options.req || {}),
    res: createMockResponse(),
    next: createMockNext()
  };
}

/**
 * Run middleware with mock request, response, and next
 * 
 * @param {Function} middleware - The middleware function to test
 * @param {Object} options - Options for the middleware test
 * @returns {Promise<Object>} The middleware test context after running
 */
async function runMiddleware(middleware, options = {}) {
  const ctx = createMiddlewareTestContext(options);
  
  // Run the middleware
  await middleware(ctx.req, ctx.res, ctx.next);
  
  // Safely access mock properties
  const hasNextCalls = ctx.next && ctx.next.mock && Array.isArray(ctx.next.mock.calls);
  const nextCallsLength = hasNextCalls ? ctx.next.mock.calls.length : 0;
  const firstNextCall = nextCallsLength > 0 ? ctx.next.mock.calls[0] : [];
  const firstNextArg = firstNextCall.length > 0 ? firstNextCall[0] : null;
  const isFirstArgError = firstNextArg instanceof Error;
  
  console.log('[TEST] Middleware test result:', {
    hasNextMock: Boolean(ctx.next && ctx.next.mock),
    nextCalled: nextCallsLength > 0,
    firstArgIsError: isFirstArgError
  });
  
  return {
    ...ctx,
    // Helper methods
    wasNext: nextCallsLength > 0,
    wasError: nextCallsLength > 0 && firstNextCall.length > 0 && isFirstArgError,
    wasHandled: ctx.res._ended || ctx.res._statusCode !== 200,
    errorMessage: isFirstArgError ? firstNextArg.message : null
  };
}

module.exports = {
  createMockRequest,
  createMockResponse,
  createMockNext,
  createMiddlewareTestContext,
  runMiddleware
}; 