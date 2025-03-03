const mongoose = require('mongoose');
const logger = require('../utils/logger.cjs');
const { config } = require('./environment.cjs');

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
    return CONNECTION_STATES[mongoose.connection.readyState] || 'unknown';
};

const connectDB = async () => {
    const options = {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 10000,
        socketTimeoutMS: 60000,
        family: 4,
        keepAlive: true,
        connectTimeoutMS: 30000,
        heartbeatFrequencyMS: 10000,
        retryWrites: true,
        retryReads: true,
        autoIndex: true
    };

    try {
        mongoose.connection.on('connected', () => {
            logger.info('Mongoose connected to MongoDB Atlas');
        });

        mongoose.connection.on('error', (err) => {
            logger.error('Mongoose connection error:', err);
        });

        mongoose.connection.on('disconnected', () => {
            logger.warn('Mongoose disconnected from MongoDB Atlas');
            
            if (process.env.NODE_ENV === 'production' && !mongoose.connection._closeCalled) {
                logger.info('Attempting to reconnect to MongoDB...');
                setTimeout(() => {
                    mongoose.connect(config.database.uri, options)
                        .catch(err => logger.error('Reconnection attempt failed:', err));
                }, 5000);
            }
        });

        process.on('SIGINT', async () => {
            await mongoose.connection.close();
            logger.info('Mongoose disconnected through app termination');
            process.exit(0);
        });

        const conn = await mongoose.connect(config.database.uri, options);
        logger.info(`MongoDB Connected: ${conn.connection.host}`);
        
        return conn;
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

