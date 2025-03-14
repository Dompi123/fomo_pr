/**
 * Jest Global Teardown
 * 
 * This file is run once after all tests to tear down the global environment.
 * It's responsible for cleaning up resources like database connections.
 */

const { validateTestEnvironment } = require('../helpers/testEnvironment.cjs');
const dbConnectionManager = require('../../utils/dbConnectionManager.cjs');
const mongoose = require('mongoose');

/**
 * Teardown function that runs after all tests
 */
module.exports = async function globalTeardown() {
  try {
    console.log('\n[GLOBAL TEARDOWN] Cleaning up test environment...');
    
    // Validate we're in the test environment
    validateTestEnvironment();
    
    // Check current connection state
    const connectionState = dbConnectionManager.getConnectionState();
    console.log(`[GLOBAL TEARDOWN] Current connection state: ${JSON.stringify(connectionState)}`);
    
    // Disconnect from MongoDB
    try {
      console.log('[GLOBAL TEARDOWN] Disconnecting from MongoDB...');
      await dbConnectionManager.disconnect();
      console.log('[GLOBAL TEARDOWN] Successfully disconnected from MongoDB');
    } catch (dbError) {
      console.error('[GLOBAL TEARDOWN] Error disconnecting from MongoDB:', dbError);
      console.error('[GLOBAL TEARDOWN] Stack trace:', dbError.stack);
      
      // Force disconnect as a fallback
      try {
        console.log('[GLOBAL TEARDOWN] Attempting force disconnect...');
        if (mongoose.connection.readyState !== 0) {
          await mongoose.connection.close(true); // Force close
          console.log('[GLOBAL TEARDOWN] Force disconnect successful');
        }
      } catch (forceError) {
        console.error('[GLOBAL TEARDOWN] Force disconnect failed:', forceError);
      }
    }
    
    // Check for any remaining connections that might be leaking
    const finalState = mongoose.connection.readyState;
    if (finalState !== 0) {
      console.error(`[GLOBAL TEARDOWN] Warning: MongoDB connection still in state ${finalState} after cleanup`);
    } else {
      console.log('[GLOBAL TEARDOWN] All MongoDB connections properly closed');
    }
    
    // Check if we have any models still registered
    const modelCount = Object.keys(mongoose.models).length;
    if (modelCount > 0) {
      console.log(`[GLOBAL TEARDOWN] Found ${modelCount} mongoose models still registered`);
      // Clear models to prevent future issues with model redefinition
      try {
        mongoose.models = {};
        mongoose.modelSchemas = {};
        console.log('[GLOBAL TEARDOWN] Cleared mongoose models');
      } catch (modelError) {
        console.error('[GLOBAL TEARDOWN] Failed to clear mongoose models:', modelError);
      }
    }
    
    console.log('[GLOBAL TEARDOWN] Test environment cleanup complete');
  } catch (error) {
    console.error('[GLOBAL TEARDOWN] Critical error in global teardown:', error);
    console.error('[GLOBAL TEARDOWN] Stack trace:', error.stack);
    // Don't throw here, as we want to complete the teardown process even if there are errors
  }
}; 