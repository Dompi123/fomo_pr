/**
 * Feature Manager for Payment System
 * 
 * Handles feature flags specific to the payment processing system.
 * Allows toggling features on/off at runtime.
 */

const BaseService = require('../utils/baseService.cjs');
const logger = require('../utils/logger.cjs');

class FeatureManager extends BaseService {
    constructor() {
        super('feature-manager');
        this.features = new Map();
        this.logger = logger.child({
            context: 'feature-manager',
            service: 'payment-features'
        });
        
        // Initialize with default features
        this.initialize();
    }
    
    /**
     * Initialize default features
     */
    initialize() {
        // Register core features with default values
        this.registerFeature('USE_CLIENT_SIDE_VERIFICATION', {
            enabled: false,
            description: 'Enables client-side verification for bartender roles',
            updatedAt: new Date()
        });
        
        this.registerFeature('ADVANCED_PAYMENT_METRICS', {
            enabled: true,
            description: 'Enables detailed payment metrics tracking',
            updatedAt: new Date()
        });
        
        this.registerFeature('PAYMENT_RETRY_POLICY', {
            enabled: true,
            description: 'Enables automatic retry of failed payments',
            updatedAt: new Date()
        });
        
        this.logger.info('Feature manager initialized with default features');
    }
    
    /**
     * Register a new feature
     * @param {string} feature - The feature name
     * @param {Object} config - The feature configuration
     */
    registerFeature(feature, config) {
        if (!feature) {
            this.logger.warn('Attempted to register feature with empty name');
            return;
        }
        
        this.features.set(feature, {
            ...config,
            updatedAt: new Date()
        });
        
        this.logger.info(`Feature ${feature} registered`, {
            enabled: config.enabled
        });
    }
    
    /**
     * Check if a feature is enabled
     * @param {string} feature - The feature name
     * @returns {boolean} Whether the feature is enabled
     */
    isEnabled(feature) {
        const config = this.features.get(feature);
        
        if (!config) {
            this.logger.warn(`Feature ${feature} not found, registering with default values`);
            this.registerFeature(feature, {
                enabled: false,
                description: 'Auto-created feature',
                updatedAt: new Date()
            });
            return false;
        }
        
        return !!config.enabled;
    }
    
    /**
     * Enable a feature
     * @param {string} feature - The feature name
     */
    enableFeature(feature) {
        this.setFeatureState(feature, true);
    }
    
    /**
     * Disable a feature
     * @param {string} feature - The feature name
     */
    disableFeature(feature) {
        this.setFeatureState(feature, false);
    }
    
    /**
     * Set the state of a feature
     * @param {string} feature - The feature name
     * @param {boolean} enabled - Whether the feature should be enabled
     */
    setFeatureState(feature, enabled) {
        const config = this.features.get(feature);
        
        if (!config) {
            this.logger.warn(`Feature ${feature} not found, registering with default state`);
            this.registerFeature(feature, {
                enabled,
                description: 'Auto-created during state change',
                updatedAt: new Date()
            });
            return;
        }
        
        this.features.set(feature, {
            ...config,
            enabled,
            updatedAt: new Date()
        });
        
        this.logger.info(`Feature ${feature} ${enabled ? 'enabled' : 'disabled'}`);
    }
    
    /**
     * Get the configuration for a feature
     * @param {string} feature - The feature name
     * @returns {Object|null} The feature configuration or null if not found
     */
    getFeatureConfig(feature) {
        const config = this.features.get(feature);
        
        if (!config) {
            this.logger.warn(`Feature ${feature} config requested but not found`);
            return null;
        }
        
        return { ...config };
    }
    
    /**
     * Get all feature configurations
     * @returns {Object} Map of all feature configurations
     */
    getAllFeatures() {
        const result = {};
        
        for (const [feature, config] of this.features.entries()) {
            result[feature] = { ...config };
        }
        
        return result;
    }
}

// Create and export singleton instance
const featureManager = new FeatureManager();
module.exports = featureManager; 