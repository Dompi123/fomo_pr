/**
 * Drink Payments Module
 * 
 * Handles all drink-related payment functionality including:
 * - Drink total calculation (price, fees, taxes)
 * - Processing webhook events for drink purchases
 * - Validating drink purchase business rules
 */

const stripe = require('../config/stripeConfig.cjs');
const logger = require('../utils/logger.cjs');
const { createError, ERROR_CODES } = require('../utils/errors.cjs');
const Order = require('../models/Order.cjs');
const Venue = require('../models/Venue.cjs');
const User = require('../models/User.cjs');
const { updateMetrics } = require('./PaymentMetrics.cjs');

/**
 * Calculate the total amount for a drink purchase
 * @param {Object} config - The drink order configuration
 * @param {Array} config.items - The items in the order
 * @param {Object} [config.discounts] - Any applicable discounts
 * @param {Object} [config.tax] - Tax information
 * @returns {Object} Object containing final price and breakdown
 */
function calculateDrinkTotal(config) {
  if (!config || !config.items || !Array.isArray(config.items)) {
    throw new Error('Drink order configuration with items array is required');
  }
  
  // Calculate subtotal from items
  const subtotal = config.items.reduce((total, item) => {
    const itemPrice = item.price * (item.quantity || 1);
    return total + itemPrice;
  }, 0);
  
  // Calculate discounts
  const discountAmount = config.discounts ? 
    calculateDiscounts(subtotal, config.discounts) : 0;
  
  // Calculate tax
  const taxAmount = config.tax ? 
    calculateTax(subtotal - discountAmount, config.tax) : 0;
  
  // Calculate final total
  const final = subtotal - discountAmount + taxAmount;
  
  // Return price breakdown
  return {
    subtotal,
    discountAmount,
    taxAmount,
    final
  };
}

/**
 * Calculate applicable discounts
 * @private
 * @param {number} subtotal - The subtotal before discounts
 * @param {Object} discounts - Discount configuration
 * @returns {number} Total discount amount
 */
function calculateDiscounts(subtotal, discounts) {
  let totalDiscount = 0;
  
  if (discounts.percentOff) {
    totalDiscount += subtotal * (discounts.percentOff / 100);
  }
  
  if (discounts.amountOff) {
    totalDiscount += discounts.amountOff;
  }
  
  // Don't allow negative prices
  return Math.min(totalDiscount, subtotal);
}

/**
 * Calculate tax amount
 * @private
 * @param {number} amount - The amount to tax
 * @param {Object} taxConfig - Tax configuration
 * @returns {number} Tax amount
 */
function calculateTax(amount, taxConfig) {
  const taxRate = taxConfig.rate || 0;
  return amount * taxRate;
}

/**
 * Process a drink purchase webhook from Stripe
 * @param {string} rawBody - Raw request body
 * @param {string} signature - Stripe signature header
 * @param {Object} [session] - Database session for transactions
 */
async function handleDrinkWebhook(rawBody, signature, session) {
  let event;
  
  try {
    // Verify webhook signature
    event = stripe.webhooks.constructEvent(
      rawBody,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET
    );
    
    const paymentIntent = event.data.object;
    
    // Only process drink purchase events
    if (paymentIntent.metadata.type !== 'drink_purchase') {
      logger.info('Ignoring non-drink payment event', { 
        type: paymentIntent.metadata.type,
        id: paymentIntent.id
      });
      return;
    }
    
    // Handle based on event type
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handleSuccessfulDrinkPayment(paymentIntent, session);
        break;
        
      case 'payment_intent.payment_failed':
        await handleFailedDrinkPayment(paymentIntent, session);
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
      'Failed to process drink payment',
      { originalError: err.message }
    );
  }
}

/**
 * Handle a successful drink payment
 * @private
 * @param {Object} paymentIntent - Stripe payment intent
 * @param {Object} [session] - Database session for transactions
 */
async function handleSuccessfulDrinkPayment(paymentIntent, session) {
  try {
    const venueId = paymentIntent.metadata.venueId;
    const userId = paymentIntent.metadata.userId;
    const orderItems = JSON.parse(paymentIntent.metadata.items || '[]');
    
    // Validate venue
    const venue = await Venue.findById(venueId).session(session);
    if (!venue) {
      throw createError.notFound(
        ERROR_CODES.VENUE_NOT_FOUND,
        `Venue with ID ${venueId} not found`
      );
    }
    
    // Create order record
    await Order.create([{
      userId,
      venueId,
      items: orderItems.map(item => ({
        type: 'drink',
        drinkId: item.id,
        drinkName: item.name,
        quantity: item.quantity,
        price: item.price
      })),
      total: paymentIntent.amount / 100,
      status: 'completed',
      paymentIntentId: paymentIntent.id,
      createdAt: new Date()
    }], { session });
    
    // Update payment metrics
    await updateMetrics('drink_purchase', {
      amount: paymentIntent.amount,
      venueId,
      itemCount: orderItems.length
    }, session);
    
    logger.info('Drink purchase successful', {
      paymentIntentId: paymentIntent.id,
      userId,
      venueId,
      amount: paymentIntent.amount / 100
    });
  } catch (err) {
    logger.error('Failed to process successful drink payment', {
      paymentIntentId: paymentIntent.id,
      error: err.message
    });
    throw err;
  }
}

/**
 * Handle a failed drink payment
 * @private
 * @param {Object} paymentIntent - Stripe payment intent
 * @param {Object} [session] - Database session for transactions
 */
async function handleFailedDrinkPayment(paymentIntent, session) {
  logger.warn('Drink payment failed', {
    paymentIntentId: paymentIntent.id,
    error: paymentIntent.last_payment_error?.message
  });
  
  // Update metrics for failed payment
  await updateMetrics('drink_purchase_failed', {
    amount: paymentIntent.amount,
    venueId: paymentIntent.metadata.venueId,
    errorCode: paymentIntent.last_payment_error?.code
  }, session);
}

module.exports = {
  calculateDrinkTotal,
  handleDrinkWebhook
}; 