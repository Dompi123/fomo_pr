/**
 * Database Connection Manager Test
 * 
 * Tests the functionality of our MongoDB connection manager.
 */

const dbConnectionManager = require('../../utils/dbConnectionManager.cjs');
const mongoose = require('mongoose');

describe('Database Connection Manager', () => {
  
  // Make sure we disconnect after all tests
  afterAll(async () => {
    await dbConnectionManager.disconnect();
  });
  
  // Clear the database after each test
  afterEach(async () => {
    try {
      if (dbConnectionManager.isConnected) {
        await dbConnectionManager.clearDatabase();
      }
    } catch (error) {
      console.error('Error cleaning up after test:', error);
    }
  });
  
  test('should connect to the database successfully', async () => {
    // Connect to the database
    const connection = await dbConnectionManager.connect();
    
    // Verify the connection is active
    expect(connection).toBeDefined();
    expect(mongoose.connection.readyState).toBe(1); // 1 = connected
    expect(dbConnectionManager.isConnected).toBe(true);
  });
  
  test('should provide connection diagnostics', async () => {
    // Ensure connection exists
    await dbConnectionManager.connect();
    
    // Get diagnostics
    const diagnostics = dbConnectionManager.getDiagnostics();
    
    // Verify basic diagnostic information
    expect(diagnostics).toBeDefined();
    expect(diagnostics.connectionState).toMatchObject({
      isConnected: true,
      readyState: 1,
      status: 'connected'
    });
    expect(diagnostics.environment.nodeEnv).toBe('test');
    expect(diagnostics.mongoose.version).toBe(mongoose.version);
    
    // Verify memory server info if using in-memory DB
    if (process.env.USE_MEMORY_DB === 'true') {
      expect(diagnostics.environment.useMemoryDb).toBe(true);
      expect(diagnostics.memoryDb).toBeDefined();
    }
  });
  
  test('should clear the database for testing', async () => {
    // Ensure connection exists
    await dbConnectionManager.connect();
    
    // Create a temporary collection
    const TestModel = mongoose.model('TestModel', new mongoose.Schema({ 
      name: String 
    }), 'test_items');
    
    // Add test data
    await TestModel.create({ name: 'Test Item 1' });
    await TestModel.create({ name: 'Test Item 2' });
    
    // Verify items were added
    let count = await TestModel.countDocuments();
    expect(count).toBe(2);
    
    // Clear the database
    await dbConnectionManager.clearDatabase();
    
    // Verify items were removed
    count = await TestModel.countDocuments();
    expect(count).toBe(0);
    
    // Clean up model to avoid model overwrite warnings
    delete mongoose.models['TestModel'];
  });
  
  test('should return same connection on multiple connect calls', async () => {
    // Connect first time
    const connection1 = await dbConnectionManager.connect();
    
    // Connect second time
    const connection2 = await dbConnectionManager.connect();
    
    // Both should be the same connection
    expect(connection1).toBe(connection2);
  });
}); 