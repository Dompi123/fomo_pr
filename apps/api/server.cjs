// Add module alias registration at the start
require('module-alias/register');

// Load environment configuration first
const { config } = require('./config/environment.cjs');
const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const timeout = require('connect-timeout');
const rateLimit = require('express-rate-limit');
const cookieParser = require('cookie-parser');
const { errorHandler } = require('./middleware/errorMiddleware.cjs');
const { securityHeaders } = require('./middleware/securityMiddleware.cjs');
const { configureRoutes } = require('./config/routes.cjs');
const { requireAuth } = require('./middleware/authMiddleware.cjs');
const { monitoringMiddleware } = require('./middleware/monitoring.cjs');
const wsMonitor = require('./utils/websocketMonitor.cjs');
const eventEmitter = require('./utils/eventEmitter.cjs');
const optimizationManager = require('./utils/optimizationManager.cjs');
const monitoringDashboard = require('./utils/monitoringDashboard.cjs');
const PaymentProcessor = require('./services/payment/PaymentProcessor.cjs');
const PaymentEventEmitter = require('./services/payment/PaymentEventEmitter.cjs');
const PaymentMetrics = require('./services/payment/PaymentMetrics.cjs');
const TransactionManager = require('./services/payment/TransactionManager.cjs');
const connectDB = require('./config/database.cjs').connectDB;
const cacheService = require('./services/cacheService.cjs');
const logger = require('./utils/logger.cjs');
const AuthenticationService = require('./services/auth/AuthenticationService.cjs');
const FeatureManager = require('./services/payment/FeatureManager.cjs');

// Create specialized app logger
const appLogger = logger.child({
    context: 'app',
    service: 'express-app'
});

const app = express();

// Apply middleware
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));
app.use(cors({
    origin: config.corsOrigins || ['http://localhost:3000', 'http://localhost:8080'],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    exposedHeaders: ['Authorization', 'X-New-Token'],
    credentials: true
}));

// Add cookie parser middleware before auth middleware
app.use(cookieParser());

// Add other middleware with proper error handling
try {
    app.use(helmet());
    app.use(compression());
    app.use(timeout('30s'));
    
    // Use securityHeaders directly as middleware
    app.use(securityHeaders);
    
    if (typeof monitoringMiddleware === 'function') {
        app.use(monitoringMiddleware);
    }
} catch (err) {
    appLogger.error('Error setting up middleware:', err);
    // Continue with reduced functionality
}

// Apply rate limiting
const limiter = rateLimit({
    windowMs: 1 * 60 * 1000, // 1 minute
    max: 100, // limit each IP to 100 requests per windowMs
    standardHeaders: true,
    legacyHeaders: false,
    message: 'Too many requests from this IP, please try again after a minute'
});
app.use(limiter);

// Apply Auth0 middleware at the application level for Universal Login
app.use((req, res, next) => {
    if (!AuthenticationService.isReady()) {
        return next();
    }
    
    // Apply Auth0 middleware for login and callback routes
    if (req.path.startsWith('/api/auth/login') || req.path.startsWith('/api/auth/callback')) {
        return AuthenticationService.auth0Client(req, res, next);
    }
    
    next();
});

// Initialize core services
let servicesInitialized = false;

async function initializeServices() {
    if (servicesInitialized) return;

    try {
        // 1. Initialize event system first
        await eventEmitter.initialize();
        appLogger.info('Event system initialized');

        // 2. Initialize cache service before other services that may depend on it
        await cacheService.initialize();
        appLogger.info('Cache service initialized');

        // 3. Connect to database
        await connectDB();
        appLogger.info('Database connection initialized');
        
        // 4. Initialize feature manager
        await FeatureManager.initialize();
        appLogger.info('Feature manager initialized');

        // 5. Initialize authentication service
        await AuthenticationService.initialize();
        appLogger.info('Authentication service initialized');

        // 6. Skip WebSocket monitoring in development mode
        appLogger.info('WebSocket monitoring skipped in development mode');

        // 7. Initialize payment processor
        try {
            await PaymentProcessor.initialize();
            appLogger.info('Payment processor initialized');
        } catch (paymentError) {
            appLogger.warn('Payment processor failed to initialize, continuing anyway:', paymentError.message);
        }

        // 8. Setup event listeners
        try {
            await PaymentEventEmitter.setupEventListeners();
            appLogger.info('Event listeners setup completed');
        } catch (eventError) {
            appLogger.warn('Event listeners setup failed, continuing anyway:', eventError.message);
        }

        // 9. Skip monitoring dashboard in development mode
        appLogger.info('Monitoring dashboard skipped in development mode');

        servicesInitialized = true;
    } catch (error) {
        appLogger.error('Failed to initialize services:', error);
        // Continue anyway in development mode
        if (process.env.NODE_ENV === 'development') {
            appLogger.warn('Continuing server startup despite initialization errors in development mode');
            servicesInitialized = true;
        } else {
            throw error;
        }
    }
}

// Configure routes
async function startServer() {
    try {
        await initializeServices();
        
        // Configure all routes
        configureRoutes(app);
        appLogger.info('Route configuration completed');
        
        // Add a root route handler for better UX
        app.get('/', (req, res) => {
            const html = `
                <h1>API Server is running!</h1>
                <p>The API server is running at http://localhost:${PORT}</p>
                <p>Try accessing these endpoints:</p>
                <ul>
                    <li><a href="http://localhost:${PORT}/api/health">Health Check</a></li>
                    <li><a href="http://localhost:${PORT}/api/status">Status</a></li>
                </ul>
                <div style="margin-top: 20px; padding: 15px; border: 1px solid #ddd; background-color: #f9f9f9;">
                    <h3>Auth0 Testing</h3>
                    <p>To test the Auth0 integration, you have several options:</p>
                    <ul>
                        <li><a href="http://localhost:${PORT}/simple_auth_test.html"><strong>Simple Auth0 Test</strong></a> - Recommended test page with direct Auth0 implementation</li>
                        <li><a href="http://localhost:${PORT}/ultra_minimal_auth.html"><strong>Ultra Minimal Auth0 Test</strong></a> - Absolute bare-bones implementation (fallback option)</li>
                        <li><a href="http://localhost:${PORT}/api/auth/login"><strong>API Server Auth0 Login</strong></a> - Login through API server middleware (may have issues)</li>
                    </ul>
                </div>
            `;
            res.send(html);
        });
        
        // Error handler - must be last
        app.use(errorHandler);
        
        const server = http.createServer(app);
        
        // Start the server
        const PORT = process.env.PORT || 3001;
        server.listen(PORT, () => {
            appLogger.info(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
        });
        
        // Handle unhandled promise rejections
        process.on('unhandledRejection', (err) => {
            appLogger.error('Unhandled Rejection:', err);
        });
        
        // Clean shutdown
        process.on('SIGTERM', async () => {
            appLogger.info('SIGTERM signal received. Shutting down gracefully');
            server.close(() => {
                appLogger.info('Server closed');
                process.exit(0);
            });
        });
        
        return server;
    } catch (error) {
        appLogger.error('Failed to start server:', error);
        if (process.env.NODE_ENV === 'development') {
            appLogger.warn('Attempting to start server in development mode despite errors');
            const server = http.createServer(app);
            const PORT = process.env.PORT || 3001;
            server.listen(PORT, () => {
                appLogger.info(`Server running in ${process.env.NODE_ENV} mode on port ${PORT} (with errors)`);
            });
            return server;
        } else {
            process.exit(1);
        }
    }
}

// Start the server
module.exports = startServer(); 