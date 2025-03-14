/**
 * Jest Global Teardown
 * 
 * This file runs once after all tests complete.
 * It's responsible for cleaning up any resources used during testing.
 */

const mongoose = require('mongoose');
const logger = require('../../utils/logger.cjs');

// Cleanup resources after all tests complete
module.exports = async () => {
  console.log('Starting global test teardown...');
  
  // Close database connections
  if (mongoose.connection.readyState !== 0) {
    try {
      await mongoose.connection.close();
      logger.info('Mongoose connection closed successfully');
    } catch (error) {
      logger.error('Error closing mongoose connection', error);
    }
  }
  
  // Close any other resources that need cleanup
  // e.g., Redis connections, file handles, etc.
  
  console.log('Global test teardown complete');
}; 