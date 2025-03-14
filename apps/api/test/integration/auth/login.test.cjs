/**
 * Simplified Login Test
 * 
 * This test focuses only on the login functionality to isolate any issues.
 */

const request = require('supertest');
const mongoose = require('mongoose');

console.log('Starting simplified login test setup');

// Mock Auth0 Authentication Client
jest.mock('auth0', () => {
  console.log('Setting up auth0 mock');
  return {
    AuthenticationClient: jest.fn().mockImplementation(() => ({
      oauth: {
        passwordGrant: jest.fn().mockImplementation(({ username, password }) => {
          console.log(`Mock passwordGrant called with: ${username}, ${password}`);
          if (username === 'test@example.com' && password === 'password123') {
            return Promise.resolve({
              access_token: 'test-access-token',
              refresh_token: 'test-refresh-token',
              expires_in: 86400
            });
          } else {
            return Promise.reject(new Error('Invalid credentials'));
          }
        })
      }
    }))
  };
});

// Mock TokenService
jest.mock('../../../utils/auth.cjs', () => {
  console.log('Setting up TokenService mock');
  return {
    verifyAuth0Token: jest.fn().mockImplementation((token) => {
      console.log(`Mock verifyAuth0Token called with: ${token}`);
      if (token === 'test-access-token') {
        return Promise.resolve({
          sub: 'auth0|12345',
          email: 'test@example.com',
          name: 'Test User'
        });
      } else {
        return Promise.reject(new Error('Invalid token'));
      }
    })
  };
});

// Mock authEvents
jest.mock('../../../utils/authEvents.cjs', () => {
  console.log('Setting up authEvents mock');
  return {
    authEvents: {
      emitLoginSuccess: jest.fn(),
      emitLoginFailed: jest.fn()
    }
  };
});

console.log('All mocks set up, about to import modules');

// Import after mocks are set up
const { app } = require('../../../app.cjs');
const AuthenticationService = require('../../../services/auth/AuthenticationService.cjs');
const { User } = require('../../../models/User.cjs');
const { connectToTestDatabase, cleanupTestData, createTestUser } = require('../../helpers/testSetup.cjs');

console.log('Modules imported successfully');

describe('Login Functionality', () => {
  let testUser;

  console.log('Starting Login Functionality describe block');

  beforeAll(async () => {
    console.log('Starting beforeAll setup');
    try {
      console.log('Connecting to test database...');
      await connectToTestDatabase();
      console.log('Connected to test database successfully');
      
      // Mock isReady method
      console.log('Mocking AuthenticationService.isReady');
      jest.spyOn(AuthenticationService, 'isReady').mockReturnValue(true);

      // Mock getOrCreateUser method
      console.log('Mocking AuthenticationService.getOrCreateUser');
      jest.spyOn(AuthenticationService, 'getOrCreateUser').mockImplementation((decoded) => {
        console.log(`Mock getOrCreateUser called with: ${JSON.stringify(decoded)}`);
        return Promise.resolve(testUser);
      });

      // Mock login attempts tracking methods
      console.log('Mocking login attempts tracking methods');
      jest.spyOn(AuthenticationService, 'getLoginAttempts').mockResolvedValue(0);
      jest.spyOn(AuthenticationService, 'incrementLoginAttempts').mockResolvedValue(1);
      jest.spyOn(AuthenticationService, 'resetLoginAttempts').mockResolvedValue(0);

      // Create test user
      console.log('Creating test user');
      testUser = await createTestUser({ 
        role: 'customer', 
        email: 'test@example.com',
        auth0Id: 'auth0|12345'
      });
      console.log('Test user created:', testUser._id.toString());
      
      console.log('beforeAll setup completed successfully');
    } catch (error) {
      console.error('Error in beforeAll setup:', error);
      throw error;
    }
  });

  afterAll(async () => {
    console.log('Starting afterAll cleanup');
    try {
      await cleanupTestData();
      await mongoose.connection.close();
      console.log('afterAll cleanup completed successfully');
    } catch (error) {
      console.error('Error in afterAll cleanup:', error);
    }
  });

  test('should successfully login user', async () => {
    console.log('Starting login user test');
    
    // Mock the login method
    jest.spyOn(AuthenticationService, 'login').mockResolvedValueOnce({
      user: testUser,
      tokens: {
        access_token: 'test-access-token',
        refresh_token: 'test-refresh-token',
        expires_in: 86400
      }
    });
    
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'password123'
      });
    
    console.log('Login response status:', response.status);
    console.log('Login response body:', JSON.stringify(response.body));
    
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('token');
    expect(response.body).toHaveProperty('user');
    
    console.log('Login user test completed');
  });
}); 