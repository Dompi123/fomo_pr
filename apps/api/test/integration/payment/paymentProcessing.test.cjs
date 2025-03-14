/**
 * @test Payment Processing Integration Tests
 * 
 * These tests verify the payment processing system works correctly, including:
 * - Creating payment intents
 * - Processing payments
 * - Handling successful payments
 * - Error handling for failed payments
 * - Refund processing
 */

const request = require('supertest');
const mongoose = require('mongoose');
const { app } = require('../../../app.cjs');
const { User } = require('../../../models/User.cjs');
const Venue = require('../../../models/Venue.cjs');
const Pass = require('../../../models/Pass.cjs');
const PaymentProcessor = require('../../../services/payment/PaymentProcessor.cjs');
const { 
  connectToTestDatabase, 
  cleanupTestData, 
  createTestUser,
  createTestVenue,
  createTestSetup,
  createTestTeardown,
  createAuthenticatedUser,
  stripeMock,
  mockRegistry,
  resetAllMocks,
  createMockResetter
} = require('../../helpers/testSetup.cjs');

// Set up testing environment
const testSetup = createTestSetup({
  applyServiceMocks: true,
  mockConfig: {
    stripe: {
      shouldFailOnOperation: false
    }
  }
});

const testTeardown = createTestTeardown({
  cleanupData: true
});

// Reset mocks before each test
const resetMocks = createMockResetter();

describe('Payment Processing System', () => {
  let testUser;
  let testVenue;
  let authToken;
  
  beforeAll(async () => {
    await testSetup();
    
    // Create test data
    const authData = await createAuthenticatedUser();
    testUser = authData.user;
    authToken = authData.token;
    
    testVenue = await createTestVenue();
    
    // Configure stripe mock for tests
    stripeMock.__testState.resetState();
    stripeMock.paymentIntents.create.mockImplementation(() => ({
      id: 'pi_test123',
      client_secret: 'secret_test123',
      status: 'requires_payment_method'
    }));
    
    stripeMock.paymentIntents.retrieve.mockImplementation(() => ({
      id: 'pi_test123',
      status: 'succeeded',
      amount: 2000,
      metadata: {
        userId: testUser._id.toString(),
        venueId: testVenue._id.toString(),
        passType: 'fomo'
      }
    }));
    
    stripeMock.refunds.create.mockImplementation(() => ({
      id: 're_test123',
      status: 'succeeded',
      payment_intent: 'pi_test123',
      amount: 2000
    }));
    
    stripeMock.webhooks.constructEvent.mockImplementation(() => ({
      type: 'payment_intent.succeeded',
      data: {
        object: {
          id: 'pi_test123',
          status: 'succeeded',
          amount: 2000,
          metadata: {
            userId: testUser._id.toString(),
            venueId: testVenue._id.toString(),
            passType: 'fomo'
          }
        }
      }
    }));
    
    // Patch the app to add auth middleware for testing
    const originalUse = app.use;
    jest.spyOn(app, 'use').mockImplementation(function(path, ...handlers) {
      if (path === '/api/*' || path === '/api') {
        // Apply our test auth middleware instead of the real one
        originalUse.call(this, path, (req, res, next) => {
          if (req.headers.authorization === `Bearer ${authToken}`) {
            req.user = testUser;
            next();
          } else if (req.path.includes('/webhooks')) {
            // Skip auth for webhooks
            next();
          } else {
            res.status(401).json({ error: 'Unauthorized' });
          }
        });
      } else {
        originalUse.apply(this, arguments);
      }
    });
  });
  
  afterAll(async () => {
    await testTeardown();
    jest.restoreAllMocks();
  });
  
  beforeEach(() => {
    resetMocks();
  });

  describe('Payment Intent Creation', () => {
    test('should create a payment intent for pass purchase', async () => {
      const response = await request(app)
        .post('/api/payments/create-intent')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          venueId: testVenue._id.toString(),
          passType: 'fomo',
          quantity: 1
        });
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('clientSecret');
      expect(response.body).toHaveProperty('paymentIntentId', 'pi_test123');
      
      // Verify the payment intent was created with correct metadata
      expect(stripeMock.paymentIntents.create).toHaveBeenCalledWith(
        expect.objectContaining({
          metadata: expect.objectContaining({
            userId: testUser._id.toString(),
            venueId: testVenue._id.toString(),
            passType: 'fomo'
          })
        })
      );
    });
    
    test('should handle errors when creating payment intent', async () => {
      // Mock the Stripe error for this test only
      stripeMock.paymentIntents.create.mockRejectedValueOnce(
        new Error('Stripe error')
      );
      
      const response = await request(app)
        .post('/api/payments/create-intent')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          venueId: testVenue._id.toString(),
          passType: 'fomo',
          quantity: 1
        });
      
      expect(response.status).toBe(500);
      expect(response.body).toHaveProperty('error');
    });
  });
  
  describe('Payment Processing', () => {
    test('should process successful payment webhook', async () => {
      // Mock successful webhook payload
      const payload = JSON.stringify({
        id: 'evt_test123',
        type: 'payment_intent.succeeded',
        data: {
          object: {
            id: 'pi_test123',
            status: 'succeeded',
            amount: 2000,
            metadata: {
              userId: testUser._id.toString(),
              venueId: testVenue._id.toString(),
              passType: 'fomo'
            }
          }
        }
      });
      
      // Mock the PaymentProcessor to avoid external dependencies
      jest.spyOn(PaymentProcessor, 'handleSuccessfulPayment').mockResolvedValue({
        success: true,
        passId: 'pass_test123'
      });
      
      const response = await request(app)
        .post('/api/webhooks/stripe')
        .set('Stripe-Signature', 'test_signature')
        .send(payload);
      
      expect(response.status).toBe(200);
      
      // Verify the payment processor was called with correct data
      expect(PaymentProcessor.handleSuccessfulPayment).toHaveBeenCalledWith(
        expect.objectContaining({
          paymentIntentId: 'pi_test123',
          userId: testUser._id.toString(),
          venueId: testVenue._id.toString(),
          passType: 'fomo',
          amount: 2000
        })
      );
    });
    
    test('should handle failed payment webhook', async () => {
      // Mock failed webhook payload
      const payload = JSON.stringify({
        id: 'evt_test456',
        type: 'payment_intent.payment_failed',
        data: {
          object: {
            id: 'pi_test456',
            status: 'failed',
            last_payment_error: {
              message: 'Your card was declined'
            },
            metadata: {
              userId: testUser._id.toString(),
              venueId: testVenue._id.toString(),
              passType: 'fomo'
            }
          }
        }
      });
      
      // Mock the webhook verification and event construction for failed payment
      stripeMock.webhooks.constructEvent.mockReturnValueOnce({
        type: 'payment_intent.payment_failed',
        data: {
          object: {
            id: 'pi_test456',
            status: 'failed',
            last_payment_error: {
              message: 'Your card was declined'
            },
            metadata: {
              userId: testUser._id.toString(),
              venueId: testVenue._id.toString(),
              passType: 'fomo'
            }
          }
        }
      });
      
      // Mock the PaymentProcessor to avoid external dependencies
      jest.spyOn(PaymentProcessor, 'handleFailedPayment').mockResolvedValue({
        success: true,
        message: 'Payment failure recorded'
      });
      
      const response = await request(app)
        .post('/api/webhooks/stripe')
        .set('Stripe-Signature', 'test_signature')
        .send(payload);
      
      expect(response.status).toBe(200);
      
      // Verify the payment processor was called with correct data
      expect(PaymentProcessor.handleFailedPayment).toHaveBeenCalledWith(
        expect.objectContaining({
          paymentIntentId: 'pi_test456',
          userId: testUser._id.toString(),
          venueId: testVenue._id.toString(),
          error: 'Your card was declined'
        })
      );
    });
  });
  
  describe('Refund Processing', () => {
    test('should process refund request', async () => {
      // Mock PaymentProcessor for refund
      jest.spyOn(PaymentProcessor, 'processRefund').mockResolvedValue({
        success: true,
        refundId: 're_test123',
        amount: 2000
      });
      
      const response = await request(app)
        .post('/api/payments/refund')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          paymentIntentId: 'pi_test123',
          amount: 2000,
          reason: 'requested_by_customer'
        });
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('refundId', 're_test123');
      
      // Verify the payment processor was called with correct data
      expect(PaymentProcessor.processRefund).toHaveBeenCalledWith(
        expect.objectContaining({
          paymentIntentId: 'pi_test123',
          amount: 2000,
          reason: 'requested_by_customer',
          userId: testUser._id.toString()
        })
      );
    });
    
    test('should handle errors during refund processing', async () => {
      // Mock PaymentProcessor to throw error
      jest.spyOn(PaymentProcessor, 'processRefund').mockRejectedValue(
        new Error('Cannot refund already refunded payment')
      );
      
      const response = await request(app)
        .post('/api/payments/refund')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          paymentIntentId: 'pi_test123',
          amount: 2000,
          reason: 'requested_by_customer'
        });
      
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('Cannot refund already refunded payment');
    });
  });
}); 