/**
 * Stripe Payment Service
 * 
 * This service provides an interface to the Stripe API for payment processing.
 */

const BaseService = require('../../utils/baseService.cjs');
const logger = require('../../utils/logger.cjs');
const { config } = require('../../config/environment.cjs');
const { createError, ERROR_CODES } = require('../../utils/errors.cjs');

// Maintain singleton for backward compatibility
let instance = null;

class StripeService extends BaseService {
    constructor() {
        // Return existing instance if already created
        if (instance) {
            return instance;
        }

        super('stripe-service');
        
        this.config = {
            apiKey: config.stripe?.apiKey || process.env.STRIPE_API_KEY,
            webhookSecret: config.stripe?.webhookSecret || process.env.STRIPE_WEBHOOK_SECRET,
            currency: 'usd',
            paymentMethods: ['card']
        };

        instance = this;
    }

    async _init() {
        try {
            // Initialize Stripe client
            this.stripe = require('stripe')(this.config.apiKey);
            
            this.ready = true;
            this.logger.info('Stripe service initialized successfully');
        } catch (error) {
            this.logger.error('Stripe service initialization failed:', error);
            throw error;
        }
    }

    /**
     * Create a payment intent
     * @param {Object} options Payment options
     * @returns {Promise<Object>} Stripe payment intent
     */
    async createPaymentIntent(options) {
        await this.ensureReady();
        
        try {
            const paymentIntent = await this.stripe.paymentIntents.create({
                amount: options.amount,
                currency: options.currency || this.config.currency,
                customer: options.customerId,
                metadata: options.metadata || {},
                receipt_email: options.email,
                description: options.description
            });
            
            return paymentIntent;
        } catch (error) {
            this.logger.error('Failed to create payment intent:', error);
            throw createError(ERROR_CODES.PAYMENT_FAILED, 'Failed to create payment intent', error);
        }
    }

    /**
     * Retrieve a payment intent
     * @param {string} paymentIntentId Payment intent ID
     * @returns {Promise<Object>} Stripe payment intent
     */
    async retrievePaymentIntent(paymentIntentId) {
        await this.ensureReady();
        
        try {
            return await this.stripe.paymentIntents.retrieve(paymentIntentId);
        } catch (error) {
            this.logger.error(`Failed to retrieve payment intent ${paymentIntentId}:`, error);
            throw createError(ERROR_CODES.PAYMENT_NOT_FOUND, 'Payment intent not found', error);
        }
    }

    /**
     * Create a customer
     * @param {Object} customerData Customer data
     * @returns {Promise<Object>} Stripe customer
     */
    async createCustomer(customerData) {
        await this.ensureReady();
        
        try {
            return await this.stripe.customers.create({
                email: customerData.email,
                name: customerData.name,
                metadata: customerData.metadata || {}
            });
        } catch (error) {
            this.logger.error('Failed to create customer:', error);
            throw createError(ERROR_CODES.CUSTOMER_CREATION_FAILED, 'Failed to create customer', error);
        }
    }

    /**
     * Process a webhook event
     * @param {string} payload Raw request body
     * @param {string} signature Stripe signature header
     * @returns {Object} Webhook event
     */
    processWebhook(payload, signature) {
        try {
            const event = this.stripe.webhooks.constructEvent(
                payload,
                signature,
                this.config.webhookSecret
            );
            
            this.logger.info(`Webhook received: ${event.type}`);
            return event;
        } catch (error) {
            this.logger.error('Webhook signature verification failed:', error);
            throw createError(ERROR_CODES.INVALID_WEBHOOK, 'Invalid webhook signature', error);
        }
    }
}

module.exports = new StripeService(); 