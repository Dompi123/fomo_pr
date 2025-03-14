/**
 * Test Authentication Helpers
 * 
 * This file contains authentication-related utilities specifically for testing.
 * These functions should ONLY be used in test files, never in production code.
 */

const jwt = require('jsonwebtoken');

/**
 * Generate a test authentication token for a user
 * @param {Object} user - User object to generate token for
 * @returns {String} JWT token for testing
 */
function generateAuthToken(user) {
  // Use a test secret key - never the production one
  const testSecret = 'test-jwt-secret';
  
  if (!user || !user._id) {
    throw new Error('Cannot generate token: Invalid user object');
  }
  
  // Create a proper JWT with minimal claims for testing
  const token = jwt.sign(
    { 
      sub: user._id.toString(),
      email: user.email,
      role: user.role || 'customer'
    },
    testSecret,
    { expiresIn: '1h' }
  );
  
  return token;
}

/**
 * Add auth token to a user object for testing
 * This doesn't modify the User model itself, just the specific instance for testing
 * @param {Object} user - User object to enhance with auth token generation
 * @returns {Object} The same user object with added generateAuthToken method
 */
function enhanceUserWithAuth(user) {
  if (!user) return user;
  
  // Add the generateAuthToken method only to this specific user instance
  user.generateAuthToken = function() {
    return generateAuthToken(this);
  };
  
  return user;
}

/**
 * Create auth headers for test requests
 * @param {Object} user - User to create auth headers for
 * @returns {Object} Headers object with Authorization
 */
function getAuthHeaders(user) {
  const token = generateAuthToken(user);
  return {
    Authorization: `Bearer ${token}`
  };
}

module.exports = {
  generateAuthToken,
  enhanceUserWithAuth,
  getAuthHeaders
}; 