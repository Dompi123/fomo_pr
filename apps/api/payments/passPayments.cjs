/**
 * Pass Payments Module
 * 
 * Handles all pass-related payment functionality including:
 * - Pass total calculation (base price, fees, taxes)
 * - Processing webhook events for pass purchases
 * - Validating pass purchase business rules
 */

const stripe = require('../config/stripeConfig.cjs');
const logger = require('../utils/logger.cjs');
const { createError, ERROR_CODES } = require('../utils/errors.cjs');
const Pass = require('../models/Pass.cjs');
const Order = require('../models/Order.cjs');
const Venue = require('../models/Venue.cjs');
const User = require('../models/User.cjs');
const { updateMetrics } = require('./PaymentMetrics.cjs');

/**
 * Calculate the total amount for a pass purchase
 * @param {Object} config - The pass configuration
 * @param {string} config.type - The type of pass (VIP, LineSkip, etc)
 * @param {number} config.price - The base price of the pass
 * @param {Object} [config.serviceFee] - Service fee configuration
 * @param {boolean} [config.serviceFee.enabled] - Whether service fee is enabled
 * @param {number} [config.serviceFee.amount] - The service fee amount
 * @param {number} [config.tax] - The tax amount
 * @returns {Object} Object containing final price and breakdown
 */
function calculatePassTotal(config) {
  if (!config) {
    throw new Error('Pass configuration is required');
  }
  
  // Extract configuration with defaults
  const basePrice = config.price || 0;
  const tax = config.tax || 0;
  
  // Calculate service fee if enabled
  let serviceFee = 0;
  if (config.serviceFee && config.serviceFee.enabled) {
    serviceFee = config.serviceFee.amount || 0;
  }
  
  // Calculate total
  const subtotal = basePrice;
  const final = subtotal + serviceFee + tax;
  
  // Return price breakdown
  return {
    basePrice,
    serviceFee,
    tax,
    subtotal,
    final
  };
}

/**
 * Validate pass purchase against business rules
 * @param {Object} options - Validation options
 * @param {string} options.venueId - The venue ID
 * @param {string} options.passType - The type of pass
 * @param {Object} [options.session] - Database session for transactions
 * @returns {Promise<Object>} Venue and pass information
 * @throws {Error} If validation fails
 */
async function validatePassPurchase({ venueId, passType, session }) {
  // Find venue and validate pass type
  const venue = await Venue.findById(venueId).session(session);
  if (!venue) {
    throw createError.notFound(
      ERROR_CODES.VENUE_NOT_FOUND,
      `Venue with ID ${venueId} not found`
    );
  }

  // Find pass configuration for this venue
  const passConfig = venue.passes?.find(p => p.type === passType);
  if (!passConfig) {
    throw createError.validation(
      ERROR_CODES.INVALID_PASS_TYPE,
      `Pass type ${passType} not available for venue ${venue.name}`
    );
  }

  // Check if pass is available
  if (passConfig.isAvailable === false) {
    throw createError.validation(
      ERROR_CODES.PASS_NOT_AVAILABLE,
      `Pass type ${passType} is not currently available`
    );
  }

  // Check daily limit if applicable
  if (passConfig.maxDaily) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const passCount = await Pass.countDocuments({
      venueId,
      type: passType,
      purchaseDate: { $gte: today }
    }).session(session);
    
    if (passCount >= passConfig.maxDaily) {
      throw createError.validation(
        ERROR_CODES.DAILY_LIMIT_REACHED,
        `Daily limit reached for ${passType} passes`
      );
    }
  }
  
  return { venue, passConfig };
}

/**
 * Create a pass after successful payment
 * @param {Object} options - Pass creation options
 * @param {Object} options.paymentIntent - Stripe payment intent
 * @param {Object} options.venue - Venue document
 * @param {Object} options.passConfig - Pass configuration
 * @param {string} options.userId - User ID
 * @param {Object} [options.session] - Database session for transactions
 * @returns {Promise<Object>} Created pass
 */
async function createPassAfterPayment({ paymentIntent, venue, passConfig, userId, session }) {
  // Create the pass
  const pass = await Pass.create([{
    userId,
    venueId: venue._id,
    type: passConfig.type,
    purchaseDate: new Date(),
    expiryDate: passConfig.expiryHours ? 
      new Date(Date.now() + passConfig.expiryHours * 60 * 60 * 1000) : 
      null,
    status: 'active',
    paymentIntentId: paymentIntent.id,
    amount: paymentIntent.amount / 100, // Convert from cents
    metadata: {
      serviceFee: passConfig.serviceFee?.enabled ? passConfig.serviceFee.amount : 0,
      tax: passConfig.tax || 0
    }
  }], { session });
  
  // Create order record
  await Order.create([{
    userId,
    venueId: venue._id,
    items: [{
      type: 'pass',
      passId: pass[0]._id,
      passType: passConfig.type,
      amount: paymentIntent.amount / 100
    }],
    total: paymentIntent.amount / 100,
    status: 'completed',
    paymentIntentId: paymentIntent.id,
    createdAt: new Date()
  }], { session });
  
  // Update payment metrics
  await updateMetrics('pass_purchase', {
    amount: paymentIntent.amount,
    venueId: venue._id.toString(),
    passType: passConfig.type
  }, session);
  
  return pass[0];
}

/**
 * Handle a failed payment intent
 * @param {Object} paymentIntent - Stripe payment intent
 * @param {Object} [session] - Database session for transactions
 */
async function handleFailedPayment(paymentIntent, session) {
  logger.warn('Payment failed', {
    paymentIntentId: paymentIntent.id,
    error: paymentIntent.last_payment_error?.message
  });
  
  // Update metrics for failed payment
  await updateMetrics('pass_purchase_failed', {
    amount: paymentIntent.amount,
    venueId: paymentIntent.metadata.venueId,
    passType: paymentIntent.metadata.passType,
    errorCode: paymentIntent.last_payment_error?.code
  }, session);
}

/**
 * Process a pass purchase webhook from Stripe
 * @param {string} rawBody - Raw request body
 * @param {string} signature - Stripe signature header
 * @param {Object} [session] - Database session for transactions
 */
async function handlePassWebhook(rawBody, signature, session) {
  let event;
  
  try {
    // Verify webhook signature
    event = stripe.webhooks.constructEvent(
      rawBody,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET
    );
    
    const paymentIntent = event.data.object;
    
    // Only process pass purchase events
    if (paymentIntent.metadata.type !== 'pass_purchase') {
      logger.info('Ignoring non-pass payment event', { 
        type: paymentIntent.metadata.type,
        id: paymentIntent.id
      });
      return;
    }
    
    // Handle based on event type
    switch (event.type) {
      case 'payment_intent.succeeded':
        try {
          // Validate venue and pass
          const { venue, passConfig } = await validatePassPurchase({
            venueId: paymentIntent.metadata.venueId,
            passType: paymentIntent.metadata.passType,
            session
          });
          
          // Create pass for user
          await createPassAfterPayment({
            paymentIntent,
            venue,
            passConfig,
            userId: paymentIntent.metadata.userId,
            session
          });
          
          logger.info('Pass purchase successful', {
            paymentIntentId: paymentIntent.id,
            userId: paymentIntent.metadata.userId,
            venueId: venue._id.toString(),
            passType: passConfig.type
          });
        } catch (err) {
          logger.error('Failed to process successful payment', {
            paymentIntentId: paymentIntent.id,
            error: err.message
          });
          throw err;
        }
        break;
        
      case 'payment_intent.payment_failed':
        await handleFailedPayment(paymentIntent, session);
        break;
        
      default:
        logger.info('Ignoring unhandled event type', { type: event.type });
        break;
    }
  } catch (err) {
    logger.error('Webhook processing error', { error: err.message });
    
    if (err.type === 'StripeSignatureVerificationError') {
      throw createError.validation(
        ERROR_CODES.INVALID_SIGNATURE,
        'Invalid webhook signature'
      );
    }
    
    throw createError.service(
      ERROR_CODES.PAYMENT_PROCESSING_ERROR,
      'Failed to process pass payment',
      { originalError: err.message }
    );
  }
}

module.exports = {
  calculatePassTotal,
  validatePassPurchase,
  handlePassWebhook
}; 