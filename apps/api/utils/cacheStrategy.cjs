const { LRUCache } = require('lru-cache');
const logger = require('./logger.cjs');

class CacheStrategy {
    constructor() {
        this.localCache = new LRUCache({
            max: 10000,
            ttl: 60 * 60 * 1000 // 1 hour
        });
        this.isRedisHealthy = false;
        this.retryAttempts = 0;

        logger.info('Running with local cache only');
    }

    async get(key) {
        try {
            const value = this.localCache.get(key);
            return value === undefined ? null : value;
        } catch (error) {
            logger.error('Cache get error:', { error: error.message, key });
            return null;
        }
    }

    async set(key, value, ttl = null) {
        try {
            this.localCache.set(key, value, ttl ? { ttl: ttl * 1000 } : undefined);
            return true;
        } catch (error) {
            logger.error('Cache set error:', { error: error.message, key });
            return false;
        }
    }

    async delete(key) {
        try {
            this.localCache.delete(key);
            return true;
        } catch (error) {
            logger.error('Cache delete error:', { error: error.message, key });
            return false;
        }
    }

    getHealth() {
        return {
            status: 'healthy',
            mode: 'local',
            localCacheSize: this.localCache.size,
            redisConnected: false,
            retryAttempts: this.retryAttempts
        };
    }

    async cleanup() {
        this.localCache.clear();
        logger.info('Cache strategy cleaned up');
    }
}

// Export singleton instance
module.exports = new CacheStrategy(); 