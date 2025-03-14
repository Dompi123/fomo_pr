const BaseService = require('../../utils/baseService.cjs');
const logger = require('../../utils/logger.cjs');

class FeatureManager extends BaseService {
    constructor() {
        super('payment-feature-manager');
        this.features = new Map();
        this.logger = logger.child({
            context: 'payment',
            service: 'feature-manager'
        });
    }

    async _init() {
        // Initialize default features
        await this.initializeFeatures();
        this.logger.info('Feature manager initialized');
    }

    async initializeFeatures() {
        const defaultFeatures = {
            USE_NEW_PAYMENT_PROCESSOR: {
                enabled: process.env.NODE_ENV === 'development',
                rolloutPercentage: process.env.NODE_ENV === 'development' ? 100 : 0,
                description: 'Use new payment processor implementation'
            },
            USE_NEW_LOCK_MANAGER: {
                enabled: false,
                rolloutPercentage: 0,
                description: 'Use new distributed lock manager'
            },
            USE_NEW_METRICS: {
                enabled: true,
                rolloutPercentage: 100,
                description: 'Use enhanced metrics collection'
            },
            USE_CIRCUIT_BREAKER: {
                enabled: true,
                rolloutPercentage: 100,
                description: 'Enable circuit breaker for external services'
            },
            USE_WEBSOCKET_COMPRESSION: {
                enabled: true,
                rolloutPercentage: 50,
                description: 'Enable WebSocket compression for high-traffic venues'
            },
            USE_PAYMENT_BATCHING: {
                enabled: false,
                rolloutPercentage: 0,
                description: 'Enable payment request batching'
            },
            USE_CLIENT_SIDE_VERIFICATION: {
                enabled: false,
                rolloutPercentage: 0,
                description: 'Enable client-side verification for user roles'
            },
            USE_ENHANCED_MONITORING: {
                enabled: true,
                rolloutPercentage: 100,
                description: 'Enable enhanced system monitoring'
            },
            USE_NEW_AUTH: {
                enabled: process.env.NODE_ENV === 'development',
                rolloutPercentage: process.env.NODE_ENV === 'development' ? 100 : 0,
                description: 'Use new authentication service',
                state: 'active',
                config: {
                    allowLegacyFallback: true,
                    enforceNewForV2: true,
                    venueOverrides: {}
                }
            }
        };

        // Initialize features with defaults and track state
        for (const [key, value] of Object.entries(defaultFeatures)) {
            const featureState = {
                ...value,
                lastUpdated: new Date().toISOString(),
                state: value.enabled ? 'active' : 'inactive',
                metrics: {
                    usageCount: 0,
                    lastUsed: null,
                    errors: 0
                }
            };
            
            this.features.set(key, featureState);
            
            // Log feature initialization
            this.logger.info(`Feature ${key} initialized`, {
                enabled: value.enabled,
                rolloutPercentage: value.rolloutPercentage,
                state: featureState.state
            });
        }

        const enabledFeatures = Array.from(this.features.entries())
            .filter(([_, f]) => f.enabled)
            .map(([k]) => k);

        this.logger.info('Features initialized', {
            featureCount: this.features.size,
            enabledFeatures,
            enabledCount: enabledFeatures.length
        });
    }

    /**
     * Register a new feature dynamically
     * @param {string} feature - Feature name
     * @param {Object} config - Feature configuration
     * @returns {Object} - Created feature configuration
     */
    registerFeature(feature, config = {}) {
        if (this.features.has(feature)) {
            this.logger.warn(`Feature ${feature} already exists, use setFeatureState to modify`);
            return this.features.get(feature);
        }

        const featureConfig = {
            enabled: config.enabled ?? false,
            rolloutPercentage: config.rolloutPercentage ?? 0,
            description: config.description || `Dynamically registered feature: ${feature}`,
            lastUpdated: new Date().toISOString(),
            state: config.enabled ? 'active' : 'inactive',
            metrics: {
                usageCount: 0,
                lastUsed: null,
                errors: 0
            },
            isDynamic: true,
            ...config
        };

        this.features.set(feature, featureConfig);
        
        this.logger.info(`Feature ${feature} dynamically registered`, {
            feature,
            config: featureConfig
        });

        return featureConfig;
    }

    async isEnabled(feature, context = {}) {
        const featureConfig = this.features.get(feature);
        if (!featureConfig) {
            this.logger.warn(`Feature not found: ${feature}, returning false`, {
                feature,
                context,
                featureCount: this.features.size,
                availableFeatures: Array.from(this.features.keys())
            });
            
            // Try to register the missing feature with a default config
            // This ensures code depending on this feature doesn't break
            this.registerFeature(feature, {
                enabled: false,
                rolloutPercentage: 0,
                description: `Automatically registered missing feature: ${feature}`,
                isAutoRegistered: true
            });
            
            return false;
        }

        // Increment usage metrics
        this._updateFeatureUsageMetrics(feature);

        // Check if fully enabled
        if (featureConfig.enabled && featureConfig.rolloutPercentage === 100) {
            return true;
        }

        // Check gradual rollout
        if (featureConfig.enabled && featureConfig.rolloutPercentage > 0) {
            const inRollout = this.isInRolloutGroup(feature, context, featureConfig.rolloutPercentage);
            this.logger.debug('Rollout check', {
                feature,
                context,
                rolloutPercentage: featureConfig.rolloutPercentage,
                inRollout
            });
            return inRollout;
        }

        return false;
    }

    isInRolloutGroup(feature, context, percentage) {
        // Use consistent hashing for stable rollout groups
        const hash = this.hashString(`${feature}:${JSON.stringify(context)}`);
        return (hash % 100) < percentage;
    }

    hashString(str) {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash;
        }
        return Math.abs(hash);
    }

    async setFeatureState(feature, config) {
        const currentConfig = this.features.get(feature);
        
        // Create feature if it doesn't exist
        if (!currentConfig) {
            this.logger.warn(`Feature ${feature} not found, creating with provided config`);
            return this.registerFeature(feature, config);
        }

        const newConfig = {
            ...currentConfig,
            ...config,
            lastUpdated: new Date().toISOString(),
            state: config.enabled ? 'active' : 'inactive'
        };

        this.features.set(feature, newConfig);
        this.logger.info(`Feature ${feature} state updated`, {
            feature,
            oldConfig: currentConfig,
            newConfig
        });
        return true;
    }

    async getFeatureStates() {
        const states = {};
        for (const [key, value] of this.features.entries()) {
            states[key] = {
                enabled: value.enabled,
                description: value.description,
                rolloutPercentage: value.rolloutPercentage,
                state: value.state,
                lastUpdated: value.lastUpdated,
                isDynamic: value.isDynamic || false
            };
        }
        return states;
    }

    async getFeatureState(feature) {
        const config = this.features.get(feature);
        if (!config) {
            this.logger.warn(`Feature ${feature} not found, returning null`, {
                feature,
                availableFeatures: Array.from(this.features.keys())
            });
            
            // Return a safe default config rather than null
            return {
                enabled: false,
                rolloutPercentage: 0,
                description: `Feature not found: ${feature}`,
                state: 'inactive',
                isFallback: true
            };
        }
        return config;
    }

    async _cleanup() {
        this.features.clear();
        this.logger.info('Feature manager cleaned up');
    }

    getHealth() {
        const enabledFeatures = Array.from(this.features.values()).filter(f => f.enabled);
        return {
            status: 'healthy',
            features: Array.from(this.features.keys()),
            enabledCount: enabledFeatures.length,
            rolloutProgress: {
                total: this.features.size,
                enabled: enabledFeatures.length,
                percentage: (enabledFeatures.length / this.features.size) * 100
            }
        };
    }

    // Add helper method to update feature usage metrics
    _updateFeatureUsageMetrics(feature) {
        const featureConfig = this.features.get(feature);
        if (featureConfig && featureConfig.metrics) {
            featureConfig.metrics.usageCount += 1;
            featureConfig.metrics.lastUsed = new Date().toISOString();
        }
    }

    /**
     * Check if a feature exists in the feature manager
     * 
     * @param {string} feature - The name of the feature to check
     * @returns {Promise<boolean>} - True if the feature exists, false otherwise
     */
    async featureExists(feature) {
        return this.features.has(feature);
    }

    /**
     * Remove a feature from the feature manager
     * Primarily used in testing to clean up test-added features
     * 
     * @param {string} feature - The name of the feature to remove
     * @returns {Promise<boolean>} - True if the feature was removed, false if it didn't exist
     */
    async removeFeature(feature) {
        if (!this.features.has(feature)) {
            return false;
        }
        
        this.features.delete(feature);
        this.logger.info(`Feature ${feature} removed`);
        return true;
    }
}

module.exports = new FeatureManager(); 