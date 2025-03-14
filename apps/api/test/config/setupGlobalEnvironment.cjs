/**
 * Jest Global Setup
 * 
 * This file is run once before all tests to set up the global environment.
 * It's responsible for ensuring MongoDB is properly connected before any tests run.
 */

const { validateTestEnvironment } = require('../helpers/testEnvironment.cjs');
const dbConnectionManager = require('../../utils/dbConnectionManager.cjs');
const mongoose = require('mongoose');

/**
 * Setup function that runs before all tests
 */
module.exports = async function globalSetup() {
  try {
    console.log('\n[GLOBAL SETUP] Setting up test environment...');
    
    // Validate we're in the test environment
    validateTestEnvironment();
    
    // Display environment variables for debugging
    console.log('[GLOBAL SETUP] Environment:', process.env.NODE_ENV);
    console.log('[GLOBAL SETUP] Using memory DB:', process.env.USE_MEMORY_DB);
    const uri = process.env.MONGODB_URI || 'Not set';
    console.log(`[GLOBAL SETUP] MongoDB URI: ${uri.includes('mongodb+srv') ? '[Atlas URI]' : uri}`);
    
    // Mongoose settings for tests
    mongoose.set('strictQuery', true);
    
    console.log('[GLOBAL SETUP] Attempting to connect to MongoDB...');
    
    // Try to connect to the database
    try {
      await dbConnectionManager.connect();
      const state = dbConnectionManager.getConnectionState();
      console.log(`[GLOBAL SETUP] MongoDB connection state: ${JSON.stringify(state)}`);
      
      if (state.readyState !== 1) {
        console.error('[GLOBAL SETUP] Failed to establish MongoDB connection - incorrect state', state);
      } else {
        console.log('[GLOBAL SETUP] MongoDB connected successfully');
        
        // Verify we can perform basic operations
        try {
          // Create a test model with a simple schema
          const TestModel = mongoose.models.TestSetup || mongoose.model('TestSetup', new mongoose.Schema({
            name: String,
            testDate: { type: Date, default: Date.now }
          }));
          
          // Try to create and retrieve a document
          const testDoc = new TestModel({ name: 'test-setup-verification' });
          await testDoc.save();
          console.log('[GLOBAL SETUP] Successfully created test document');
          
          const foundDoc = await TestModel.findOne({ name: 'test-setup-verification' });
          if (foundDoc) {
            console.log('[GLOBAL SETUP] Successfully retrieved test document');
            await TestModel.deleteOne({ _id: foundDoc._id });
            console.log('[GLOBAL SETUP] Successfully deleted test document');
          } else {
            console.error('[GLOBAL SETUP] Failed to retrieve test document');
          }
        } catch (dbOpError) {
          console.error('[GLOBAL SETUP] Error performing database operations:', dbOpError);
        }
      }
    } catch (dbError) {
      console.error('[GLOBAL SETUP] Failed to connect to MongoDB:', dbError);
      console.error('[GLOBAL SETUP] Stack trace:', dbError.stack);
      
      // Attempt to get diagnostic information
      try {
        const diagnostics = dbConnectionManager.getDiagnostics();
        console.error('[GLOBAL SETUP] Connection diagnostics:', JSON.stringify(diagnostics, null, 2));
      } catch (diagError) {
        console.error('[GLOBAL SETUP] Failed to get diagnostics:', diagError);
      }
      
      // We don't throw here - let individual tests fail if they need the database
      console.error('[GLOBAL SETUP] WARNING: Tests requiring database access will likely fail');
    }
    
    console.log('[GLOBAL SETUP] Test environment setup complete');
  } catch (error) {
    console.error('[GLOBAL SETUP] Critical error in global setup:', error);
    console.error('[GLOBAL SETUP] Stack trace:', error.stack);
    throw error; // This will cause Jest to abort
  }
}; 