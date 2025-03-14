/**
 * Auth Utilities Tests
 * 
 * Tests for authentication and authorization utilities
 */

const { verifyAuth0Token } = require('../../../utils/auth.cjs');
const jwt = require('jsonwebtoken');
const {
  createTestSetup,
  createTestTeardown,
  createMockResetter,
  authTestHelper,
  createMockRequest,
  createMockResponse,
  createMockNext,
  runMiddleware
} = require('../../helpers/testSetup.cjs');

// Setup test environment
const testSetup = createTestSetup({
  database: false, // No need for database in these tests
  applyModuleMocks: false
});

const testTeardown = createTestTeardown({
  database: false
});

const resetMocks = createMockResetter();

describe('Auth Utilities', () => {
  beforeAll(async () => {
    await testSetup();
  });
  
  afterAll(async () => {
    await testTeardown();
  });
  
  beforeEach(() => {
    resetMocks();
  });
  
  describe('Auth0 Token Validation', () => {
    test('rejects invalid token format', async () => {
      await expect(verifyAuth0Token('invalid.token.here'))
        .rejects
        .toThrow('Invalid token format: missing key ID (kid)');
    });

    test('rejects missing claims', async () => {
      // Create a token without required claims
      const invalidToken = jwt.sign({ foo: 'bar' }, 'secret');
      await expect(verifyAuth0Token(invalidToken))
        .rejects
        .toThrow('Invalid token format: missing key ID (kid)');
    });

    test('rejects null token', async () => {
      await expect(verifyAuth0Token(null))
        .rejects
        .toThrow('Token is required');
    });

    test('rejects undefined token', async () => {
      await expect(verifyAuth0Token(undefined))
        .rejects
        .toThrow('Token is required');
    });
  });
  
  describe('JWT Token Helper', () => {
    test('should generate a valid JWT token', () => {
      // Create a test user
      const testUser = {
        _id: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
        role: 'user'
      };
      
      // Generate a token
      const token = authTestHelper.generateAuthToken(testUser);
      
      // Verify the token
      const decoded = authTestHelper.verifyAuthToken(token);
      
      // Check that the token contains the expected claims
      expect(decoded).toHaveProperty('sub', testUser._id);
      expect(decoded).toHaveProperty('email', testUser.email);
      expect(decoded).toHaveProperty('role', testUser.role);
    });
    
    test('should generate an invalid signature token', () => {
      // Create a test user
      const testUser = {
        _id: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
        role: 'user'
      };
      
      // Generate a token with invalid signature
      const token = authTestHelper.generateInvalidSignatureToken(testUser);
      
      // Verify the token should fail
      expect(() => {
        authTestHelper.verifyAuthToken(token);
      }).toThrow();
    });
    
    test('should generate an expired token', () => {
      // Create a test user
      const testUser = {
        _id: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
        role: 'user'
      };
      
      // Generate an expired token
      const token = authTestHelper.generateExpiredToken(testUser);
      
      // Verify the token should fail
      expect(() => {
        authTestHelper.verifyAuthToken(token);
      }).toThrow(/expired/i);
    });
  });
  
  describe('Auth Middleware Testing', () => {
    test('should test middleware with authenticated user', async () => {
      // Create a mock auth middleware
      const authMiddleware = (req, res, next) => {
        if (!req.headers.authorization) {
          return res.status(401).json({ error: 'No token provided' });
        }
        
        const token = req.headers.authorization.split(' ')[1];
        
        try {
          const decoded = authTestHelper.verifyAuthToken(token);
          req.user = {
            id: decoded.sub,
            email: decoded.email,
            role: decoded.role
          };
          next();
        } catch (error) {
          res.status(401).json({ error: 'Invalid token' });
        }
      };
      
      // Create a test user
      const testUser = {
        _id: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
        role: 'user'
      };
      
      // Generate a token
      const token = authTestHelper.generateAuthToken(testUser);
      
      // Run the middleware with mock request/response
      const result = await runMiddleware(authMiddleware, {
        req: {
          headers: {
            authorization: `Bearer ${token}`
          }
        }
      });
      
      // Check that the middleware passed and attached the user
      expect(result.wasNext).toBe(true);
      expect(result.wasError).toBe(false);
      expect(result.req.user).toEqual(expect.objectContaining({
        id: testUser._id,
        email: testUser.email,
        role: testUser.role
      }));
    });
    
    test('should reject request with invalid token', async () => {
      // Create a mock auth middleware
      const authMiddleware = (req, res, next) => {
        if (!req.headers.authorization) {
          return res.status(401).json({ error: 'No token provided' });
        }
        
        const token = req.headers.authorization.split(' ')[1];
        
        try {
          const decoded = authTestHelper.verifyAuthToken(token);
          req.user = {
            id: decoded.sub,
            email: decoded.email,
            role: decoded.role
          };
          next();
        } catch (error) {
          res.status(401).json({ error: 'Invalid token' });
        }
      };
      
      // Run the middleware with an invalid token
      const result = await runMiddleware(authMiddleware, {
        req: {
          headers: {
            authorization: 'Bearer invalid.token.here'
          }
        }
      });
      
      // Check that the middleware rejected the request
      expect(result.wasNext).toBe(false);
      expect(result.res._statusCode).toBe(401);
      expect(result.res._data).toEqual({ error: 'Invalid token' });
    });
  });
}); 