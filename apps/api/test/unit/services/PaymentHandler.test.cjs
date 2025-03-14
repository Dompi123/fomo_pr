// First, create a mock constructor that can be instantiated with 'new'
function MockVenueAwareBreaker(config = {}) {
  // If this function is called with new, it will create a new instance
  if (!(this instanceof MockVenueAwareBreaker)) {
    return new MockVenueAwareBreaker(config);
  }
  
  // Set up instance methods
  this.execute = jest.fn(fn => fn());
  this.isOpen = jest.fn(() => false);
  this.reset = jest.fn();
  this.trip = jest.fn();
  
  // Store config
  this.config = config;
}

// Add static methods and properties
MockVenueAwareBreaker.VenueAwareBreaker = MockVenueAwareBreaker;
MockVenueAwareBreaker.BREAKER_STATES = {
  CLOSED: 'closed',
  OPEN: 'open',
  HALF_OPEN: 'half_open'
};

// Create a spy for later modification
const mockCircuitBreakerInterface = {
  execute: jest.fn(fn => fn()),
  isOpen: jest.fn(() => false),
  reset: jest.fn(),
  trip: jest.fn()
};

// Mock the circuit breaker module
jest.mock('../../../utils/circuitBreaker.cjs', () => {
  // This is a special trick: we replace the module with a function
  // that also has properties, allowing us to modify them in tests
  const mockFunction = function(config) {
    return Object.assign({}, mockCircuitBreakerInterface, {
      config: config
    });
  };
  
  // Add the VenueAwareBreaker class to the function
  mockFunction.VenueAwareBreaker = MockVenueAwareBreaker;
  mockFunction.BREAKER_STATES = MockVenueAwareBreaker.BREAKER_STATES;
  
  // Add instances methods to the function itself
  Object.keys(mockCircuitBreakerInterface).forEach(key => {
    mockFunction[key] = mockCircuitBreakerInterface[key];
  });
  
  return mockFunction;
});

// Create stripe mock
const stripeMock = {
  paymentIntents: {
    create: jest.fn(options => Promise.resolve({
      id: `pi_mock_${Date.now()}`,
      status: 'succeeded',
      amount: options.amount,
      currency: options.currency,
      metadata: options.metadata
    })),
    list: jest.fn(() => Promise.resolve({
      data: []
    }))
  }
};

// Mock the stripe module
jest.mock('../../../config/stripeConfig.cjs', () => stripeMock);

// Mock crypto for consistent idempotency keys
jest.mock('crypto', () => ({
  createHash: jest.fn(() => ({
    update: jest.fn(() => ({
      digest: jest.fn(() => ({
        substring: jest.fn(() => '12345678')
      }))
    }))
  }))
}));

// Import the module under test after mocking
const paymentHandler = require('../../../utils/paymentHandler.cjs');

describe('Payment Handler Tests', () => {
  const venueId = 'test-venue-123';
  
  beforeEach(() => {
    // Clear all mocks
    jest.clearAllMocks();
    
    // Reset payment handler state
    paymentHandler.reset();
    
    // Reset mock implementations for circuit breaker
    mockCircuitBreakerInterface.execute.mockImplementation(fn => fn());
    mockCircuitBreakerInterface.isOpen.mockReturnValue(false);
    
    // Reset stripe mock
    stripeMock.paymentIntents.list.mockResolvedValue({ data: [] });
  });
  
  describe('Idempotency Handling', () => {
    test('generates consistent idempotency keys', async () => {
      const intent = {
        amount: 1000,
        currency: 'usd',
        venueId: venueId,
        customerId: 'cus_123',
        metadata: { orderId: '12345' }
      };
      
      const key1 = paymentHandler.__test__.generateIdempotencyKey(intent);
      const key2 = paymentHandler.__test__.generateIdempotencyKey(intent);
      
      expect(key1).toBe(key2);
    });
    
    test('includes venue prefix in idempotency key', async () => {
      // Using a venueId that will produce 'VEN' prefix
      const intent = {
        amount: 1000,
        currency: 'usd',
        venueId: 'VENue_test_123', // Will produce VEN prefix
        customerId: 'cus_123',
        metadata: { orderId: '12345' }
      };
      
      const key = paymentHandler.__test__.generateIdempotencyKey(intent);
      expect(key).toContain('VEN-');
    });
    
    test('returns cached payment for duplicate requests', async () => {
      const intent = {
        amount: 1000,
        currency: 'usd',
        venueId: venueId,
        customerId: 'cus_123',
        metadata: { orderId: '12345' }
      };
      
      // First payment
      const payment1 = await paymentHandler.processPayment(intent);
      
      // Should reset call count to verify caching
      stripeMock.paymentIntents.create.mockClear();
      
      // Second payment with same intent
      const payment2 = await paymentHandler.processPayment(intent);
      
      expect(payment1).toBeTruthy();
      expect(payment2).toBeTruthy();
      expect(payment1.id).toBe(payment2.id);
      expect(stripeMock.paymentIntents.create).not.toHaveBeenCalled();
    });
  });
  
  describe('Circuit Breaker Integration', () => {
    test('uses circuit breaker during payment processing', async () => {
      const intent = {
        amount: 1000,
        currency: 'usd',
        venueId: venueId,
        customerId: 'cus_123',
        metadata: { orderId: '12345' }
      };
      
      // Reset the execute method call count
      mockCircuitBreakerInterface.execute.mockClear();
      
      await paymentHandler.processPayment(intent);
      
      expect(mockCircuitBreakerInterface.execute).toHaveBeenCalled();
    });
    
    test('throws circuit open error when breaker is open', async () => {
      const intent = {
        amount: 1000,
        currency: 'usd',
        venueId: venueId,
        customerId: 'cus_123',
        metadata: { orderId: '12345' }
      };
      
      // Make circuit breaker appear open by implementing our own validation
      mockCircuitBreakerInterface.isOpen.mockReturnValue(true);
      
      // Modify execute to throw the right error when isOpen is true
      mockCircuitBreakerInterface.execute.mockImplementation((fn) => {
        if (mockCircuitBreakerInterface.isOpen()) {
          const error = new Error('Circuit open');
          error.code = 'circuit_breaker_open';
          throw error;
        }
        return fn();
      });
      
      // Expect the payment to fail with circuit open error
      await expect(paymentHandler.processPayment(intent)).rejects.toThrow(/circuit/i);
    });
  });
  
  describe('Payment Attempt Tracking', () => {
    test('limits retry attempts', async () => {
      const intent = {
        amount: 1000,
        currency: 'usd',
        venueId: venueId,
        customerId: 'cus_123',
        metadata: { orderId: '12345' }
      };
      
      // Make execute always fail
      mockCircuitBreakerInterface.execute.mockImplementation(() => {
        throw new Error('Payment failed');
      });
      
      // First attempt
      await expect(paymentHandler.processPayment(intent)).rejects.toThrow('Payment failed');
      
      // Second attempt
      await expect(paymentHandler.processPayment(intent)).rejects.toThrow('Payment failed');
      
      // Third attempt
      await expect(paymentHandler.processPayment(intent)).rejects.toThrow('Payment failed');
      
      // Fourth attempt should hit max retries
      await expect(paymentHandler.processPayment(intent)).rejects.toThrow(/maximum retry attempts/i);
    });
    
    test('tracks payment metrics', async () => {
      const intent = {
        amount: 1000,
        currency: 'usd',
        venueId: venueId,
        customerId: 'cus_123',
        metadata: { orderId: '12345' }
      };
      
      // Process a successful payment
      await paymentHandler.processPayment(intent);
      
      // Check metrics
      const metrics = paymentHandler.getPaymentMetrics(venueId);
      expect(metrics).toBeDefined();
      expect(metrics.totalPayments).toBe(1);
      expect(metrics.successfulPayments).toBe(1);
      expect(metrics.failedPayments).toBe(0);
    });
  });
  
  describe('Error Handling', () => {
    test('handles Stripe errors gracefully', async () => {
      const intent = {
        amount: 1000,
        currency: 'usd',
        venueId: venueId,
        customerId: 'cus_123',
        metadata: { orderId: '12345' }
      };
      
      // Create a Stripe error
      const stripeError = new Error('Card declined');
      stripeError.type = 'card_error';
      stripeError.code = 'card_declined';
      
      // Make create throw the error
      stripeMock.paymentIntents.create.mockImplementation(() => {
        throw stripeError;
      });
      
      // Expect the payment to fail with the Stripe error
      await expect(paymentHandler.processPayment(intent)).rejects.toThrow(/declined/i);
      
      // Check metrics
      const metrics = paymentHandler.getPaymentMetrics(venueId);
      expect(metrics.failedPayments).toBe(1);
      expect(metrics.successfulPayments).toBe(0);
    });
    
    test('tracks error details', async () => {
      const intent = {
        amount: 1000,
        currency: 'usd',
        venueId: venueId,
        customerId: 'cus_123',
        metadata: { orderId: '12345' }
      };
      
      // Create a Stripe error
      const stripeError = new Error('Rate limit exceeded');
      stripeError.type = 'invalid_request_error';
      stripeError.code = 'rate_limit';
      
      // Make create throw the error
      stripeMock.paymentIntents.create.mockImplementation(() => {
        throw stripeError;
      });
      
      // Expect the payment to fail with the Stripe error
      await expect(paymentHandler.processPayment(intent)).rejects.toThrow(/rate limit/i);
      
      // Check metrics
      const metrics = paymentHandler.getPaymentMetrics(venueId);
      expect(metrics.failedPayments).toBe(1);
    });
  });
}); 