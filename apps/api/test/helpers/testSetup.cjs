const mongoose = require('mongoose');
const User = require('../../models/User.cjs');
const Venue = require('../../models/Venue.cjs');
const OrderMetrics = require('../../models/OrderMetrics.cjs');
const { connectDB } = require('../../config/database.cjs');
const featureManager = require('../../services/payment/FeatureManager.cjs');

/**
 * Create a test user with specified role
 * @param {Object} options - User creation options
 * @param {String} options.role - User role (default: 'customer')
 * @param {String} options.email - User email (default: random)
 * @returns {Promise<Object>} Created user document
 */
async function createTestUser(options = {}) {
  const defaultOptions = {
    role: 'customer',
    email: `test-${Date.now()}@example.com`,
    name: 'Test User'
  };
  
  const userOptions = { ...defaultOptions, ...options };
  
  const user = new User({
    name: userOptions.name,
    email: userOptions.email,
    role: userOptions.role,
    auth0Id: `auth0|${Date.now()}`
  });
  
  // Add generateAuthToken method for testing
  user.generateAuthToken = () => 'test-auth-token';
  
  await user.save();
  return user;
}

/**
 * Create a test venue
 * @param {Object} options - Venue creation options
 * @returns {Promise<Object>} Created venue document
 */
async function createTestVenue(options = {}) {
  const defaultOptions = {
    name: 'Test Venue',
    location: {
      address: '123 Test St',
      city: 'Test City',
      state: 'TS',
      zipCode: '12345'
    }
  };
  
  const venueOptions = { ...defaultOptions, ...options };
  
  const venue = new Venue(venueOptions);
  await venue.save();
  return venue;
}

/**
 * Create test OrderMetrics documents
 * @param {Object} options - Options for creating metrics
 * @param {String} options.verifiedBy - Who verified the order ('staff', 'system', 'customer')
 * @param {String} options.eventType - Type of event
 * @param {Object} options.venueId - Venue ID
 * @param {Object} options.orderId - Order ID
 * @returns {Promise<Object>} Created OrderMetrics document
 */
async function createTestOrderMetrics(options = {}) {
  const defaultOptions = {
    verifiedBy: 'system',
    eventType: 'status_change',
    orderType: 'drink',
    processingTime: 1000,
    metadata: {}
  };
  
  const metricsOptions = { ...defaultOptions, ...options };
  
  if (!metricsOptions.venueId) {
    const venue = await createTestVenue();
    metricsOptions.venueId = venue._id;
  }
  
  if (!metricsOptions.orderId) {
    metricsOptions.orderId = new mongoose.Types.ObjectId();
  }
  
  const metrics = new OrderMetrics(metricsOptions);
  await metrics.save();
  return metrics;
}

/**
 * Set feature flag for testing
 * @param {String} featureName - Name of the feature flag
 * @param {Boolean} enabled - Whether the feature should be enabled
 */
async function setFeatureFlag(featureName, enabled) {
  await featureManager.setFeatureState(featureName, enabled);
}

/**
 * Clean up test data
 */
async function cleanupTestData() {
  await User.deleteMany({ email: /^test-.*@example.com$/ });
  await Venue.deleteMany({ name: 'Test Venue' });
  await OrderMetrics.deleteMany({ 
    $or: [
      { orderId: { $in: await OrderMetrics.find().distinct('orderId') } },
      { venueId: { $in: await Venue.find({ name: 'Test Venue' }).distinct('_id') } }
    ]
  });
}

/**
 * Connect to test database
 */
async function connectToTestDatabase() {
  await connectDB();
}

module.exports = {
  createTestUser,
  createTestVenue,
  createTestOrderMetrics,
  setFeatureFlag,
  cleanupTestData,
  connectToTestDatabase
}; 