/**
 * Jest Global Setup
 * 
 * This file runs once before all tests begin.
 * It loads the test environment configuration and sets up any global test requirements.
 */

const mongoose = require('mongoose');
const logger = require('../../utils/logger.cjs');
const { loadTestEnvironment } = require('../helpers/testEnvironment.cjs');
const dbConnectionManager = require('../../utils/dbConnectionManager.cjs');

// Load the test environment configuration
loadTestEnvironment();

// Cleanup function to ensure we don't have hanging connections
const cleanup = async () => {
  await dbConnectionManager.disconnect();
  logger.info('Database connections closed for test environment');
};

// Clear all collections in the test database
const clearDatabase = async () => {
  if (process.env.NODE_ENV !== 'test') {
    throw new Error('clearDatabase can only be run in test environment');
  }
  
  await dbConnectionManager.clearDatabase();
};

// Setup with environment loading and mongoose cleanup
module.exports = async () => {
  console.log('Starting global test setup...');
  
  // Ensure we're starting with clean connections
  await cleanup();
  
  // Set up global test state if needed
  global.__TEST_SETUP_COMPLETE__ = true;
  
  console.log('Global test setup complete');
};

// Export functions for use in tests
module.exports.teardown = cleanup;
module.exports.clearDatabase = clearDatabase; 