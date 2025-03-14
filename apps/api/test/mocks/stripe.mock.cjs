/**
 * Stripe Mock Implementation
 * 
 * A comprehensive mock of the Stripe API for testing purposes.
 * Supports payment intents, refunds, and other Stripe functionality.
 */

// Check if Jest is available
const hasJest = typeof jest !== 'undefined';

// Create mock functions with fallbacks for non-Jest environments
const createMockFn = (name) => {
  if (hasJest) {
    return jest.fn().mockName(name);
  }
  
  // Fallback for non-Jest environments
  const fn = (...args) => fn.mock.calls[fn.mock.calls.push(args) - 1];
  fn.mock = { calls: [], results: [], instances: [] };
  fn.mockImplementation = (impl) => {
    fn.mockImpl = impl;
    return fn;
  };
  fn.mockReturnValue = (val) => {
    fn.mockImplementation(() => val);
    return fn;
  };
  fn.mockResolvedValue = (val) => {
    fn.mockImplementation(() => Promise.resolve(val));
    return fn;
  };
  fn.mockRejectedValue = (val) => {
    fn.mockImplementation(() => Promise.reject(val));
    return fn;
  };
  fn.mockReset = () => {
    fn.mock.calls = [];
    fn.mock.results = [];
    fn.mock.instances = [];
    return fn;
  };
  return fn;
};

// Configuration for the mock
const config = {
  paymentIntentSuccessRate: 100, // 100% success by default
  simulateNetworkLatency: false,
  latencyMs: 100,
  simulateNetworkErrors: false
};

// State storage for the mock
const state = {
  paymentIntents: new Map(),
  refunds: new Map(),
  paymentMethods: new Map()
};

// Helper function to log mock calls
function logMockCall(method, params) {
  console.log(`Mock called: ${method}`, params);
}

// Create the mock Stripe object
const mockStripe = {
  __config: config,
  __state: state,
  
  // Add test state for specific test scenarios
  __testState: {
    passLimit: 2,
    passCount: 0,
    refundAmount: 0,
    customerCount: 0
  },
  
  // Reset the mock state
  reset: createMockFn('stripe.reset').mockImplementation(() => {
    state.paymentIntents.clear();
    state.refunds.clear();
    state.paymentMethods.clear();
    
    // Reset configuration to defaults
    config.paymentIntentSuccessRate = 100;
    config.simulateNetworkLatency = false;
    config.latencyMs = 100;
    config.simulateNetworkErrors = false;
    
    // Reset test state
    mockStripe.__testState = {
      passLimit: 2,
      passCount: 0,
      refundAmount: 0,
      customerCount: 0
    };
  }),
  
  // Payment Intents
  paymentIntents: {
    create: createMockFn('stripe.paymentIntents.create').mockImplementation((params = {}) => {
      logMockCall('stripe.paymentIntents.create', params);
      
      // Handle invalid payment method
      if (params.payment_method === 'invalid_method') {
        const error = new Error('Invalid payment method');
        error.code = 'payment_method_invalid';
        error.type = 'StripeCardError';
        return Promise.reject(error);
      }
      
      // Check for unavailable pass type
      if (params.metadata && params.metadata.passType === 'LineSkip') {
        const error = new Error('Pass type not available');
        error.code = 'resource_missing';
        error.type = 'StripeInvalidRequestError';
        return Promise.reject(error);
      }
      
      // Random failure based on success rate
      if (Math.random() * 100 > config.paymentIntentSuccessRate) {
        const error = new Error('Payment failed');
        error.code = 'card_declined';
        error.type = 'StripeCardError';
        return Promise.reject(error);
      }
      
      // Generate a payment intent ID
      const id = `pi_${Date.now()}`;
      
      // Create the payment intent object
      const paymentIntent = {
        id,
        object: 'payment_intent',
        amount: params.amount || 0,
        currency: params.currency || 'cad',
        status: params.payment_method ? 'requires_payment_method' : 'succeeded',
        client_secret: `${id}_secret_${Math.random().toString(36).substring(2, 15)}`,
        created: Date.now(),
        metadata: params.metadata || {}
      };
      
      // Store in state
      state.paymentIntents.set(id, paymentIntent);
      
      // Simulate network delay
      if (config.simulateNetworkLatency) {
        return new Promise(resolve => setTimeout(() => resolve(paymentIntent), config.latencyMs));
      }
      
      // Return the payment intent
      return Promise.resolve(paymentIntent);
    })
  },
  
  // Refunds
  refunds: {
    create: createMockFn('stripe.refunds.create').mockImplementation((params = {}) => {
      logMockCall('stripe.refunds.create', params);
      
      // Get the payment intent if it exists
      const paymentIntent = params.payment_intent ? state.paymentIntents.get(params.payment_intent) : null;
      
      // Create the refund object
      const refund = {
        id: `re_${Date.now()}`,
        object: 'refund',
        amount: params.amount || (paymentIntent ? paymentIntent.amount : 0),
        payment_intent: params.payment_intent,
        status: 'succeeded',
        created: Date.now(),
        currency: 'cad'
      };
      
      // Store in state
      state.refunds.set(refund.id, refund);
      
      // Simulate network delay
      if (config.simulateNetworkLatency) {
        return new Promise(resolve => setTimeout(() => resolve(refund), config.latencyMs));
      }
      
      // Return the refund
      return Promise.resolve(refund);
    })
  }
};

// Export the mock
module.exports = { mockStripe }; 