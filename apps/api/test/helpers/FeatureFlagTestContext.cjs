/**
 * Feature Flag Test Context
 * 
 * Provides a controlled environment for feature flags in tests.
 * This allows tests to temporarily enable or disable specific features
 * without affecting other tests or the global state.
 */

const FeatureManager = require('../../services/payment/FeatureManager.cjs');
const testServiceRegistry = require('./TestServiceRegistry.cjs');

class FeatureFlagTestContext {
  constructor() {
    this.originalFeatures = {};
    this.initialized = false;
    this.criticalFeatures = [
      'USE_CLIENT_SIDE_VERIFICATION',
      'ENABLE_NEW_PAYMENT_FLOW',
      'USE_AUTH_CACHING'
    ];
  }

  /**
   * Initialize and ensure critical features exist
   * This should be called in beforeAll hooks
   */
  async initialize() {
    if (this.initialized) {
      return;
    }

    // Store original features for later restoration
    try {
      // Get all current features
      const currentFeatures = await FeatureManager.getFeatureStates();
      this.originalFeatures = { ...currentFeatures };
      
      // Ensure critical features that tests depend on are registered
      await this._ensureCriticalFeaturesExist();
      
      this.initialized = true;
      console.log('[TEST] FeatureFlagTestContext initialized');
    } catch (error) {
      console.error('[TEST] Error initializing FeatureFlagTestContext:', error);
      throw new Error(`Failed to initialize feature flag test context: ${error.message}`);
    }
  }

  /**
   * Ensure critical features exist before tests run
   * This prevents race conditions where tests might run before features are registered
   */
  async _ensureCriticalFeaturesExist() {
    console.log('[TEST] Ensuring critical features exist...');
    
    // Register critical features if they don't exist
    for (const featureName of this.criticalFeatures) {
      try {
        const exists = await FeatureManager.featureExists(featureName);
        
        if (!exists) {
          console.log(`[TEST] Registering missing critical feature: ${featureName}`);
          
          // Configure the feature with appropriate test defaults
          let config = {
            enabled: false,
            rolloutPercentage: 0,
            description: `Test-registered ${featureName} feature flag`
          };
          
          // Customize specific flags as needed
          if (featureName === 'USE_CLIENT_SIDE_VERIFICATION') {
            config = {
              enabled: true, // Enable for tests to ensure consistent behavior
              rolloutPercentage: 100,
              description: 'Enable client-side verification for user roles',
              staffRoleEnabled: true,
              audienceSegments: ['test_users'],
              lastUpdated: new Date().toISOString()
            };
          }
          
          // Register the feature with detailed configuration
          await FeatureManager.registerFeature(featureName, config);
          console.log(`[TEST] Successfully registered feature: ${featureName}`);
        } else {
          console.log(`[TEST] Critical feature already exists: ${featureName}`);
        }
      } catch (error) {
        console.error(`[TEST] Error ensuring feature ${featureName} exists:`, error);
        // Continue with other features despite error
      }
    }
  }

  /**
   * Set a feature flag for testing
   */
  async setFeature(name, enabled, options = {}) {
    await this._ensureInitialized();
    
    console.log(`[TEST] Setting feature ${name} to ${enabled}`);
    await FeatureManager.setFeatureState(name, {
      enabled,
      ...options
    });
  }

  /**
   * Reset features to their original state
   * This should be called in afterAll hooks
   */
  async resetFeatures() {
    try {
      console.log('[TEST] Resetting feature flags to original state');
      
      // Get current features to identify any that were added during tests
      const currentFeatures = await FeatureManager.getFeatureStates();
      
      // Remove features that were added during tests (not in original state)
      const addedFeatures = Object.keys(currentFeatures).filter(
        key => !this.originalFeatures[key]
      );
      
      for (const feature of addedFeatures) {
        try {
          await FeatureManager.removeFeature(feature);
          console.log(`[TEST] Removed test-added feature: ${feature}`);
        } catch (error) {
          console.error(`[TEST] Error removing feature ${feature}:`, error);
        }
      }
      
      // Restore original features
      for (const [key, value] of Object.entries(this.originalFeatures)) {
        try {
          await FeatureManager.setFeatureState(key, value);
          console.log(`[TEST] Restored original feature: ${key}`);
        } catch (error) {
          console.error(`[TEST] Error restoring feature ${key}:`, error);
        }
      }
    } catch (error) {
      console.error('[TEST] Error resetting feature flags:', error);
    }
  }

  /**
   * Ensure the context is initialized
   */
  async _ensureInitialized() {
    if (!this.initialized) {
      await this.initialize();
    }
  }

  /**
   * Create a mock feature manager that uses this context
   * This can be used to replace the real feature manager in tests
   * 
   * @returns {Object} A mock feature manager
   */
  createMockFeatureManager() {
    const context = this;
    
    // Create mock that delegates to this context
    const mockFeatureManager = {
      isEnabled: jest.fn((feature, ctx) => context.isEnabled(feature, ctx)),
      setFeatureState: jest.fn((feature, state) => context.setFeatureState(feature, state)),
      getFeatureState: jest.fn(async (feature) => {
        await context._ensureInitialized();
        return context.featureManager.getFeatureState(feature);
      }),
      getFeatureStates: jest.fn(async () => {
        await context._ensureInitialized();
        return context.featureManager.getFeatureStates();
      }),
      registerFeature: jest.fn((feature, config) => {
        context._ensureInitialized();
        return context.featureManager.registerFeature(feature, config);
      })
    };
    
    // Register mock with the service registry
    testServiceRegistry.registerMock('feature-manager', mockFeatureManager);
    
    return mockFeatureManager;
  }

  /**
   * Create a test context with specified feature states
   * This is a convenience method for setting up a test environment
   * 
   * @param {Object} featureStates - Map of feature names to their desired states
   * @returns {Promise<FeatureFlagTestContext>} A configured test context
   */
  static async create(featureStates = {}) {
    const context = new FeatureFlagTestContext();
    await context.initialize();
    
    // Set specified feature states
    for (const [feature, state] of Object.entries(featureStates)) {
      if (typeof state === 'boolean') {
        // If state is a boolean, interpret as enabled/disabled
        state ? await context.setFeature(feature, true) : await context.setFeature(feature, false);
      } else {
        // Otherwise, use the provided state object
        await context.setFeature(feature, state.enabled, state);
      }
    }
    
    return context;
  }
}

// Export a singleton instance for consistent state across tests
const featureFlagTestContext = new FeatureFlagTestContext();

module.exports = featureFlagTestContext; 