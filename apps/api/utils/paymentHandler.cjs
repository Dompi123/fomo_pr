/**
 * Payment Handler
 * 
 * Handles payment processing and metrics tracking.
 * This is a mock implementation for testing purposes.
 */

const logger = require('./logger.cjs');
const VenueAwareBreaker = require('./circuitBreaker.cjs');
const stripe = require('../config/stripeConfig.cjs');
const crypto = require('crypto');

// Store metrics by venue
const paymentMetrics = new Map();

// Cache previously processed payments
const paymentCache = new Map();

// Maximum retries for payment attempts
const MAX_RETRIES = 2;

// Circuit breaker for payment processing
const circuitBreaker = new VenueAwareBreaker({
  name: 'payment-processor',
  failureThreshold: 3,
  resetTimeout: 30000,
  maxRetries: 2
});

/**
 * Generate an idempotency key for a payment intent
 * @param {Object} intent - The payment intent
 * @returns {string} The idempotency key
 */
function generateIdempotencyKey(intent) {
  // Create a hash based on venue ID and intent details
  const venuePrefix = intent.venueId.substring(0, 3).toUpperCase();
  const hashInput = JSON.stringify({
    amount: intent.amount,
    currency: intent.currency,
    venueId: intent.venueId,
    metadata: intent.metadata
  });
  
  const hash = crypto.createHash('md5')
    .update(hashInput)
    .digest('hex')
    .substring(0, 8);
  
  return `${venuePrefix}-${hash}`;
}

/**
 * Check for existing payment with the same idempotency key
 * @param {Object} intent - The payment intent
 * @param {string} idempotencyKey - The idempotency key
 * @returns {Promise<Object|null>} The existing payment or null
 */
async function checkExistingPayment(intent, idempotencyKey) {
  // Check local cache first
  if (paymentCache.has(idempotencyKey)) {
    return paymentCache.get(idempotencyKey);
  }
  
  // Check Stripe for existing payment
  try {
    const existingPayments = await stripe.paymentIntents.list({
      customer: intent.customerId,
      limit: 10
    });
    
    // Find payment with matching metadata
    const existingPayment = existingPayments.data.find(p => 
      p.metadata?.idempotencyKey === idempotencyKey);
    
    if (existingPayment) {
      // Cache the payment
      const result = {
        id: existingPayment.id,
        status: existingPayment.status,
        amount: existingPayment.amount,
        currency: existingPayment.currency,
        venueId: intent.venueId,
        customerId: intent.customerId,
        createdAt: new Date(existingPayment.created * 1000)
      };
      
      paymentCache.set(idempotencyKey, result);
      return result;
    }
  } catch (error) {
    logger.warn(`Error checking existing payments: ${error.message}`);
  }
  
  return null;
}

/**
 * Process a payment intent
 * @param {Object} intent - The payment intent to process
 * @returns {Promise<Object>} The processed payment
 */
async function processPayment(intent) {
  if (!intent || !intent.venueId) {
    throw new Error('Invalid payment intent: missing venueId');
  }

  const venueId = intent.venueId;
  const idempotencyKey = generateIdempotencyKey(intent);
  
  // Check for existing payment with the same idempotency key
  const existingPayment = await checkExistingPayment(intent, idempotencyKey);
  if (existingPayment) {
    logger.info(`Returning cached payment for idempotency key ${idempotencyKey}`);
    return existingPayment;
  }
  
  // Track payment attempts
  if (!paymentMetrics.has(venueId)) {
    paymentMetrics.set(venueId, {
      totalPayments: 0,
      successfulPayments: 0,
      failedPayments: 0,
      totalAmount: 0,
      lastPaymentTime: null,
      attempts: {}
    });
  }
  
  const metrics = paymentMetrics.get(venueId);
  if (!metrics.attempts[idempotencyKey]) {
    metrics.attempts[idempotencyKey] = {
      count: 0,
      errors: []
    };
  }
  
  const attempts = metrics.attempts[idempotencyKey];
  attempts.count++;
  
  // Check if max retries exceeded
  if (attempts.count > MAX_RETRIES) {
    const error = new Error('Payment failed: maximum retry attempts exceeded');
    error.code = 'max_retries_exceeded';
    throw error;
  }
  
  try {
    // Use circuit breaker to handle payment processing
    const result = await circuitBreaker.execute(async () => {
      // Create payment through Stripe
      const paymentOptions = {
        amount: intent.amount,
        currency: intent.currency,
        customer: intent.customerId,
        metadata: {
          ...intent.metadata,
          idempotencyKey,
          venueId: intent.venueId
        }
      };
      
      logger.info(`Processing payment for venue ${venueId}`, { 
        amount: intent.amount,
        currency: intent.currency,
        idempotencyKey
      });
      
      const payment = await stripe.paymentIntents.create(paymentOptions, {
        idempotencyKey
      });
      
      // Track metrics
      updateMetrics(venueId, intent);
      
      const result = {
        id: payment.id,
        status: payment.status,
        amount: payment.amount,
        currency: payment.currency,
        venueId: intent.venueId,
        customerId: intent.customerId,
        createdAt: new Date()
      };
      
      // Cache the result
      paymentCache.set(idempotencyKey, result);
      
      return result;
    });
    
    return result;
  } catch (error) {
    logger.error(`Payment processing failed for venue ${venueId}`, {
      error: error.message,
      venueId
    });
    
    // Track failed payment and error
    updateMetrics(venueId, intent, true);
    if (metrics.attempts[idempotencyKey]) {
      metrics.attempts[idempotencyKey].errors.push({
        message: error.message,
        code: error.code,
        time: new Date()
      });
    }
    
    // If circuit breaker is open, throw appropriate error
    if (circuitBreaker.isOpen()) {
      const circuitError = new Error('Circuit open');
      circuitError.code = 'circuit_breaker_open';
      throw circuitError;
    }
    
    // Preserve the original error
    throw error;
  }
}

/**
 * Update payment metrics for a venue
 * @param {string} venueId - The venue ID
 * @param {Object} intent - The payment intent
 * @param {boolean} failed - Whether the payment failed
 */
function updateMetrics(venueId, intent, failed = false) {
  if (!paymentMetrics.has(venueId)) {
    paymentMetrics.set(venueId, {
      totalPayments: 0,
      successfulPayments: 0,
      failedPayments: 0,
      totalAmount: 0,
      lastPaymentTime: null,
      attempts: {}
    });
  }
  
  const metrics = paymentMetrics.get(venueId);
  metrics.totalPayments++;
  
  if (failed) {
    metrics.failedPayments++;
  } else {
    metrics.successfulPayments++;
    metrics.totalAmount += intent.amount || 0;
  }
  
  metrics.lastPaymentTime = new Date();
}

/**
 * Get payment metrics for a venue
 * @param {string} venueId - The venue ID
 * @returns {Object} The payment metrics
 */
function getPaymentMetrics(venueId) {
  if (!paymentMetrics.has(venueId)) {
    return {
      totalPayments: 0,
      successfulPayments: 0,
      failedPayments: 0,
      totalAmount: 0,
      lastPaymentTime: null,
      successRate: 100, // Default to 100% if no payments
      attempts: {}
    };
  }
  
  const metrics = paymentMetrics.get(venueId);
  const successRate = metrics.totalPayments > 0
    ? (metrics.successfulPayments / metrics.totalPayments) * 100
    : 100;
  
  return {
    ...metrics,
    successRate
  };
}

/**
 * Reset all payment metrics (for testing)
 */
function reset() {
  paymentMetrics.clear();
  paymentCache.clear();
  circuitBreaker.reset();
}

// Export the module
const paymentHandler = {
  processPayment,
  getPaymentMetrics,
  reset
};

// Expose internals for testing only in test environment
if (process.env.NODE_ENV === 'test') {
  paymentHandler.__test__ = {
    circuitBreaker,
    generateIdempotencyKey,
    checkExistingPayment
  };
}

module.exports = paymentHandler;