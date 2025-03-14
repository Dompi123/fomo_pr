/**
 * Circuit Breaker Mock
 * 
 * This file provides a mock implementation of the VenueAwareBreaker for tests.
 */

// Create the instance factory
function createInstance(config = {}) {
  return {
    config,
    state: 'closed',
    failureCount: 0,
    successCount: 0,
    callCount: 0,
    lastVenueId: null,
    
    // Handle both signature variants
    execute: jest.fn().mockImplementation(async function(venueIdOrFn, fn) {
      // Track metrics for testing
      this.callCount++;
      
      // Handle overloaded method signature
      let actualFn;
      let venueId;
      
      if (typeof venueIdOrFn === 'function' && !fn) {
        actualFn = venueIdOrFn;
        venueId = this.venueId || config.venueId;
      } else {
        venueId = venueIdOrFn;
        actualFn = fn;
      }
      
      this.lastVenueId = venueId;
      
      try {
        const result = await actualFn();
        this.successCount++;
        return result;
      } catch (error) {
        this.failureCount++;
        throw error;
      }
    }),
    
    trip: jest.fn().mockImplementation(function() {
      this.state = 'open';
    }),
    
    reset: jest.fn().mockImplementation(function() {
      this.state = 'closed';
      this.failureCount = 0;
      this.successCount = 0;
      this.callCount = 0;
    }),
    
    isOpen: jest.fn().mockImplementation(function() {
      return this.state === 'open';
    })
  };
}

// Create a constructor function that can be used with 'new'
function MockVenueAwareBreaker(config) {
  if (!(this instanceof MockVenueAwareBreaker)) {
    return new MockVenueAwareBreaker(config);
  }
  
  const instance = createInstance(config);
  
  // Copy all properties from the instance to this
  Object.assign(this, instance);
  
  // Make sure the methods are bound correctly
  this.execute = instance.execute.bind(this);
  this.trip = instance.trip.bind(this);
  this.reset = instance.reset.bind(this);
  this.isOpen = instance.isOpen.bind(this);
}

// Add static methods
MockVenueAwareBreaker.create = jest.fn().mockImplementation(async (config = {}) => {
  return new MockVenueAwareBreaker(config);
});

MockVenueAwareBreaker.resetInstance = jest.fn().mockImplementation(() => null);

// Make it a Jest mock function as well
jest.mock('../utils/circuitBreaker.cjs', () => MockVenueAwareBreaker, { virtual: true });

// Export the mock function
module.exports = MockVenueAwareBreaker; 