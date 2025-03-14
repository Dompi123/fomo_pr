/**
 * Jest Configuration for FOMO API Tests
 * 
 * This configuration ensures tests run in a dedicated test environment
 * with the correct setup and teardown processes.
 */

const path = require('path');
const apiRoot = path.resolve(__dirname, '../../');

module.exports = {
    // Set node environment for all tests
    testEnvironment: 'node',
    
    // Common file extensions used in the project
    moduleFileExtensions: ['js', 'cjs'],
    
    // Define where to find modules
    moduleDirectories: ['node_modules', apiRoot],
    
    // Set the root directory for tests
    rootDir: apiRoot,
    
    // Match these test files
    testMatch: [
        '**/test/unit/**/*.test.cjs',
        '**/test/integration/**/*.test.cjs',
        '**/test/e2e/**/*.test.cjs',
        '**/test/performance/**/*.test.cjs',
    ],
    
    // Ignore these directories when looking for tests
    testPathIgnorePatterns: [
        '/node_modules/',
        '/test-backup/',
        '/legacy/'
    ],
    
    // Ignore these when resolving modules
    modulePathIgnorePatterns: [
        '/test-backup-',
        '/legacy/'
    ],
    
    // Test setup and environment
    verbose: true,
    collectCoverage: false,
    coverageDirectory: path.join(apiRoot, 'test/coverage'),
    coverageReporters: ['text', 'lcov'],
    
    // Initialize and clean up the test environment
    globalSetup: path.join(__dirname, 'setup.cjs'),
    globalTeardown: path.join(__dirname, 'teardown.cjs'),
    setupFilesAfterEnv: [path.join(__dirname, 'setupAfterEnv.cjs')],
    
    // Display name for reports
    displayName: {
        name: 'FOMO API',
        color: 'blue'
    },
    
    // Environment variables for tests
    testEnvironmentOptions: {
        NODE_ENV: 'test'
    },
    
    // Performance and timeout settings
    testTimeout: 300000, // 5 minutes
    setupTimeout: 300000, // 5 minutes for setup
    
    // Default timeout for test functions
    // This applies to it(), test(), beforeEach(), afterEach(), beforeAll(), afterAll()
    testTimeout: 60000, // 60 seconds
    
    // Additional settings to improve test stability
    detectOpenHandles: true,
    forceExit: false, // Only set to true if absolutely necessary
    
    // Run in band for better memory management (avoids multiple instances)
    runInBand: true,
    
    // Only run failed tests when using --watch
    watchPathIgnorePatterns: ['/node_modules/', '/coverage/'],
    
    // Bail after a certain number of failures to avoid long runs of failing tests
    bail: 10
}; 