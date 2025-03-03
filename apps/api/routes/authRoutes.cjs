const express = require('express');
const router = express.Router();
const AuthenticationService = require('../services/auth/AuthenticationService.cjs');
const logger = require('../utils/logger.cjs');
const { isPublicRoute } = require('../middleware/authMiddleware.cjs');

// Create specialized logger
const authLogger = logger.child({
    context: 'auth',
    service: 'auth-routes'
});

// Remove the router-level Auth0 middleware since it's now at the app level

// Public routes first (no auth required)
router.post('/login', async (req, res, next) => {
    try {
        const authService = AuthenticationService;
        if (!authService.isReady()) {
            throw new Error('Authentication service not ready');
        }

        const result = await authService.login(req.body);
        res.json(result);
    } catch (error) {
        authLogger.error('Login failed:', error);
        next(error);
    }
});

// GET route for Auth0 login - handle redirect_uri if provided
router.get('/login', (req, res) => {
    try {
        // Log incoming request details for debugging
        authLogger.info('Login request received', {
            query: req.query,
            headers: {
                origin: req.headers.origin,
                referer: req.headers.referer
            }
        });

        // Extract redirect_uri from query params - CRITICAL for the flow
        const redirectUri = req.query.redirect_uri || 
                           req.headers.referer || 
                           'http://localhost:8080/simple_auth_test.html';
        
        // Create a state object with the redirect URI and nonce
        const stateObj = {
            nonce: Date.now(),
            redirectUri: redirectUri
        };
        
        // Serialize and encode the state object
        const stateParam = Buffer.from(JSON.stringify(stateObj)).toString('base64');
        
        authLogger.info('Redirecting to Auth0 login', {
            redirectUri,
            stateParam: stateParam.substring(0, 20) + '...' // Log partial state for debug
        });
        
        // Redirect to Auth0 login screen with proper parameters
        req.oidc.login({
            returnTo: redirectUri, // Override the default returnTo with our redirectUri
            state: stateParam,
            authorizationParams: {
                prompt: 'login', // Always show login
                audience: process.env.AUTH0_AUDIENCE || 'https://api.lineleap.com',
                // No response_type override needed - the SDK handles this
            }
        })(req, res);
    } catch (error) {
        authLogger.error('Login redirect failed:', error);
        res.status(500).json({
            error: 'Login redirect failed',
            message: error.message
        });
    }
});

// GET route for Auth0 callback - handles redirects from Auth0 Universal Login
router.get('/callback', async (req, res, next) => {
    try {
        const authService = AuthenticationService;
        if (!authService.isReady()) {
            throw new Error('Authentication service not ready');
        }

        // Log callback information with more details
        authLogger.info('Auth0 callback received', {
            hasCode: !!req.query.code,
            hasState: !!req.query.state,
            stateLength: req.query.state ? req.query.state.length : 0,
            code: req.query.code ? req.query.code.substring(0, 10) + '...' : 'none'
        });

        // Extract redirect_uri from state parameter - with more robust error handling
        let redirectUri = 'http://localhost:8080/simple_auth_test.html'; // Default fallback
        
        if (req.query.state) {
            try {
                // Decode the base64-encoded state parameter
                const decodedState = Buffer.from(req.query.state, 'base64').toString();
                
                authLogger.debug('Decoded state:', { decodedState: decodedState.substring(0, 30) + '...' });
                
                const stateObj = JSON.parse(decodedState);
                
                if (stateObj && stateObj.redirectUri) {
                    redirectUri = stateObj.redirectUri;
                    authLogger.info(`Retrieved redirect_uri from state: ${redirectUri}`);
                } else {
                    authLogger.warn('State object missing redirectUri:', { stateObj });
                }
            } catch (err) {
                authLogger.warn('Failed to parse state parameter:', { error: err.message, state: req.query.state.substring(0, 30) + '...' });
                // Continue with default redirect_uri
            }
        } else {
            authLogger.warn('No state parameter received in callback');
        }

        // Exchange the authorization code for tokens
        authLogger.info('Exchanging code for tokens');
        const result = await authService.handleCallback(req);
        
        // Construct redirect URL with token information
        const redirectUrl = new URL(redirectUri);
        
        // Add token info to the URL hash fragment for immediate client use
        if (result && result.tokens && result.tokens.access_token) {
            const tokenFragment = `access_token=${encodeURIComponent(result.tokens.access_token)}` +
                                 `&expires_in=${result.tokens.expires_in || 7200}` +
                                 `&token_type=Bearer`;
            
            redirectUrl.hash = tokenFragment;
            
            // Log success but redact sensitive information
            authLogger.info(`Redirecting to client with tokens`, {
                redirectUrl: redirectUrl.toString().replace(/access_token=[^&]+/, 'access_token=REDACTED'),
                tokenLength: result.tokens.access_token.length
            });
        } else {
            // If no tokens available, add error information
            redirectUrl.searchParams.append('error', 'no_tokens');
            redirectUrl.searchParams.append('error_description', 'No tokens were returned from Auth0');
            authLogger.warn('No tokens returned from Auth0');
        }
        
        // Redirect back to the client application
        return res.redirect(redirectUrl.toString());
    } catch (error) {
        authLogger.error('Callback handling failed:', error);
        
        // Attempt to redirect to the test page with error information
        try {
            const redirectUri = 'http://localhost:8080/simple_auth_test.html';
            const redirectUrl = new URL(redirectUri);
            
            redirectUrl.searchParams.append('error', 'callback_error');
            redirectUrl.searchParams.append('error_description', error.message);
            
            return res.redirect(redirectUrl.toString());
        } catch (redirectError) {
            // If even the redirect fails, pass to error handler
            next(error);
        }
    }
});

// POST route for callback - kept for backward compatibility
router.post('/callback', async (req, res, next) => {
    try {
        const authService = AuthenticationService;
        if (!authService.isReady()) {
            throw new Error('Authentication service not ready');
        }

        const result = await authService.handleCallback(req);
        res.json(result);
    } catch (error) {
        authLogger.error('Callback handling failed:', error);
        next(error);
    }
});

// Health check endpoint (public)
router.get('/health', async (req, res) => {
    try {
        const authService = AuthenticationService;
        if (!authService.isReady()) {
            throw new Error('Authentication service not ready');
        }

        const health = await authService.getHealth();
        res.json(health);
    } catch (error) {
        authLogger.error('Health check failed:', error);
        res.status(503).json({
            status: 'unhealthy',
            error: error.message
        });
    }
});

// Token exchange endpoint - exchanges authorization code for tokens
router.post('/token', async (req, res) => {
    try {
        const authService = AuthenticationService;
        if (!authService.isReady()) {
            throw new Error('Authentication service not ready');
        }

        const { code } = req.body;
        if (!code) {
            throw new Error('Authorization code is required');
        }

        authLogger.info('Exchanging authorization code for tokens');
        
        // Create a mock request object with the code in the query params
        // This allows us to reuse the handleCallback method
        const mockReq = {
            query: { code },
            headers: req.headers,
            cookies: req.cookies
        };
        
        const result = await authService.handleCallback(mockReq);
        res.json(result);
    } catch (error) {
        authLogger.error('Token exchange failed:', error);
        res.status(400).json({
            error: 'token_exchange_failed',
            error_description: error.message
        });
    }
});

// Add auth middleware for protected routes
router.use((req, res, next) => {
    // Define local public paths without the /api/auth prefix
    const LOCAL_PUBLIC_PATHS = ['/login', '/callback', '/health'];
    
    // Check if the path is in our local public paths
    if (LOCAL_PUBLIC_PATHS.some(p => req.path === p || req.path.startsWith(p))) {
        return next();
    }
    
    // Otherwise, use the authentication service
    return AuthenticationService.authenticate(req, res, next);
});

module.exports = router; 