/**
 * Auth Test Helpers
 * 
 * This file provides utilities for simulating authenticated users in tests.
 * It includes tools for generating valid JWT tokens and creating authenticated
 * request objects for testing protected routes.
 */

const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const { createMockRequest } = require('./RequestResponseHelpers.cjs');

// Get the JWT secret from environment or use a default for tests
const JWT_SECRET = process.env.JWT_SECRET || 'test-jwt-secret';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '1h';

/**
 * Generate a valid JWT token for a user
 * 
 * @param {Object} user - The user object to create a token for
 * @param {string} [secret] - Optional custom secret to use
 * @param {Object} [options] - JWT sign options
 * @returns {string} The JWT token
 */
function generateAuthToken(user, secret = JWT_SECRET, options = {}) {
  const payload = {
    sub: user._id.toString(),
    email: user.email,
    role: user.role || 'user',
    // Add other needed claims
  };

  const token = jwt.sign(payload, secret, {
    expiresIn: options.expiresIn || JWT_EXPIRES_IN,
    ...options
  });

  return token;
}

/**
 * Generate a test user object with minimal properties
 * 
 * @param {Object} overrides - Properties to override on the test user
 * @returns {Object} A test user object
 */
function createTestUser(overrides = {}) {
  return {
    _id: new mongoose.Types.ObjectId(),
    email: `test-${Date.now()}@example.com`,
    role: 'user',
    firstName: 'Test',
    lastName: 'User',
    ...overrides
  };
}

/**
 * Create an admin test user
 * 
 * @param {Object} overrides - Properties to override on the admin user
 * @returns {Object} A test admin user object
 */
function createTestAdmin(overrides = {}) {
  return createTestUser({
    role: 'admin',
    ...overrides
  });
}

/**
 * Create an authenticated request with a user and token
 * 
 * @param {Object} options - Options for the authenticated request
 * @param {Object} options.user - The user object (created if not provided)
 * @param {Object} options.reqOptions - Options to pass to createMockRequest
 * @returns {Object} The mock request with authentication
 */
function createAuthenticatedRequest(options = {}) {
  const user = options.user || createTestUser();
  const token = generateAuthToken(user);
  
  // Create headers with the auth token
  const headers = {
    authorization: `Bearer ${token}`,
    ...(options.reqOptions?.headers || {})
  };
  
  // Create the request with the user already attached
  // This simulates the auth middleware having run
  return createMockRequest({
    ...(options.reqOptions || {}),
    headers,
    user
  });
}

/**
 * Create an authenticated request with admin privileges
 * 
 * @param {Object} options - Options for the admin request
 * @returns {Object} The mock request with admin authentication
 */
function createAdminRequest(options = {}) {
  const adminUser = createTestAdmin(options.user || {});
  return createAuthenticatedRequest({
    user: adminUser,
    reqOptions: options.reqOptions
  });
}

/**
 * Verify and decode a JWT token
 * 
 * @param {string} token - The token to verify
 * @param {string} [secret] - Optional custom secret to use
 * @returns {Object} The decoded token payload
 */
function verifyAuthToken(token, secret = JWT_SECRET) {
  return jwt.verify(token, secret);
}

/**
 * Simulate expired tokens for testing token expiration handling
 * 
 * @param {Object} user - The user to create an expired token for
 * @returns {string} An expired JWT token
 */
function generateExpiredToken(user) {
  // Create a token that expired 1 hour ago
  return generateAuthToken(user, JWT_SECRET, { 
    expiresIn: '-1h' 
  });
}

/**
 * Create a token with invalid signature for testing
 * 
 * @param {Object} user - The user to create a token for
 * @returns {string} A JWT token with invalid signature
 */
function generateInvalidSignatureToken(user) {
  // Use a different secret than the one used for verification
  return generateAuthToken(user, 'wrong-secret');
}

module.exports = {
  generateAuthToken,
  createTestUser,
  createTestAdmin,
  createAuthenticatedRequest,
  createAdminRequest,
  verifyAuthToken,
  generateExpiredToken,
  generateInvalidSignatureToken,
  JWT_SECRET
}; 