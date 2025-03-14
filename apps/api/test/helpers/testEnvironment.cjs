/**
 * Test Environment Helper
 * 
 * This module ensures that the correct environment variables are loaded
 * for testing. It verifies that we're using the test database and other
 * test-specific configurations.
 */

const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

/**
 * Load test environment variables
 * This function loads the .env.test file and verifies key settings
 */
function loadTestEnvironment() {
  // Determine the path to the .env.test file
  const envPath = path.resolve(process.cwd(), '.env.test');
  
  // Check if the file exists
  if (!fs.existsSync(envPath)) {
    console.error('Error: .env.test file not found!');
    console.error('Tests should use a dedicated test configuration.');
    process.exit(1);
  }
  
  // Load the environment variables
  const result = dotenv.config({ path: envPath });
  
  if (result.error) {
    console.error('Error loading .env.test file:', result.error);
    process.exit(1);
  }
  
  // Verify critical environment settings
  validateTestEnvironment();
  
  console.log('Test environment loaded successfully');
}

/**
 * Validate that we have the correct test settings
 */
function validateTestEnvironment() {
  // Check NODE_ENV
  if (process.env.NODE_ENV !== 'test') {
    console.warn('Warning: NODE_ENV is not set to "test"!');
    process.env.NODE_ENV = 'test';
  }
  
  // Verify we're using the test database
  if (!process.env.MONGODB_URI.includes('fomo_test')) {
    console.error('Error: Not using test database!');
    console.error('MONGODB_URI should contain "fomo_test" to avoid affecting development data.');
    console.error('Current MONGODB_URI:', process.env.MONGODB_URI);
    process.exit(1);
  }
  
  // Check other critical test settings
  if (process.env.PORT !== '3002') {
    console.warn(`Warning: Using port ${process.env.PORT} instead of 3002 for tests.`);
  }
  
  if (!process.env.INTERNAL_API_KEY.includes('test')) {
    console.warn('Warning: INTERNAL_API_KEY does not include "test", which may cause confusion.');
  }
  
  // Log database being used
  console.log(`Using test database: ${process.env.MONGODB_URI}`);
}

// Export functions for use in setup files
module.exports = {
  loadTestEnvironment,
  validateTestEnvironment
}; 