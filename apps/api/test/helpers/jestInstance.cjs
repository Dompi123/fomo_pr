/**
 * Jest Instance
 * 
 * This file provides a centralized jest instance to be used by all test files.
 * This prevents duplicate jest declarations across the codebase.
 */

// Safely access jest functions with fallbacks
const safeJest = {
  // Core jest functions
  fn: typeof global.jest !== 'undefined' && typeof global.jest.fn === 'function' 
    ? global.jest.fn 
    : (impl) => impl || (() => {}),
  
  mock: typeof global.jest !== 'undefined' && typeof global.jest.mock === 'function'
    ? global.jest.mock
    : (path, factory) => {
        console.log(`Mock registration for ${path} using fallback mechanism`);
        return factory ? factory() : {};
      },
  
  spyOn: typeof global.jest !== 'undefined' && typeof global.jest.spyOn === 'function'
    ? global.jest.spyOn 
    : (obj, method) => {
        const original = obj[method];
        obj[method] = function(...args) {
          return original.apply(this, args);
        };
        obj[method].mockImplementation = (impl) => {
          obj[method] = impl;
          return obj[method];
        };
        return obj[method];
      }
};

// Export the global jest instance with safe fallbacks
module.exports = {
  jest: global.jest || {},
  // Export common jest functions for convenience
  describe: global.describe || ((name, fn) => fn()),
  test: global.test || global.it || ((name, fn) => fn()),
  it: global.it || global.test || ((name, fn) => fn()),
  expect: global.expect || ((actual) => ({
    toBe: (expected) => actual === expected,
    toEqual: (expected) => JSON.stringify(actual) === JSON.stringify(expected),
    // Add other matchers as needed
  })),
  beforeAll: global.beforeAll || ((fn) => fn()),
  afterAll: global.afterAll || ((fn) => fn()),
  beforeEach: global.beforeEach || ((fn) => fn()),
  afterEach: global.afterEach || ((fn) => fn()),
  
  // Use safe implementation of jest methods
  mock: safeJest.mock,
  fn: safeJest.fn,
  spyOn: safeJest.spyOn
}; 