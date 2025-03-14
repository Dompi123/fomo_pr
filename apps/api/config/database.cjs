const mongoose = require('mongoose');
const logger = require('../utils/logger.cjs');
const { config } = require('./environment.cjs');
const dbConnectionManager = require('../utils/dbConnectionManager.cjs');

// Fix deprecation warning
mongoose.set('strictQuery', true);

// Connection state mapping
const CONNECTION_STATES = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting'
};

const getConnectionState = () => {
    return dbConnectionManager.getConnectionState();
};

const connectDB = async () => {
    try {
        const connection = await dbConnectionManager.connect();
        return connection;
    } catch (error) {
        logger.error('MongoDB connection error:', error);
        if (process.env.NODE_ENV === 'development') {
            logger.warn('Development mode: Continuing with degraded functionality');
            return null;
        }
        process.exit(1);
    }
};

module.exports = { 
    connectDB,
    getConnectionState,
    CONNECTION_STATES
};

