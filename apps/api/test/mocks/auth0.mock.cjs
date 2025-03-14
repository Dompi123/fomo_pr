/**
 * Auth0 Mock for Testing
 * 
 * This file provides mock implementations of Auth0 API functionality
 * for use in tests. It simulates Auth0's behavior without making actual API calls.
 */

// Mock users database
const mockUsers = new Map();

// Default test users
const defaultUsers = [
  {
    user_id: 'auth0|123456789',
    email: 'test@example.com',
    name: 'Test User',
    nickname: 'testuser',
    picture: 'https://example.com/avatar.png',
    email_verified: true,
    identities: [
      {
        connection: 'Username-Password-Authentication',
        provider: 'auth0',
        user_id: '123456789',
        isSocial: false
      }
    ],
    app_metadata: {
      roles: ['customer']
    },
    user_metadata: {
      preferences: {
        theme: 'dark'
      }
    },
    created_at: '2023-01-01T00:00:00.000Z',
    updated_at: '2023-01-01T00:00:00.000Z'
  },
  {
    user_id: 'auth0|987654321',
    email: 'admin@example.com',
    name: 'Admin User',
    nickname: 'adminuser',
    picture: 'https://example.com/admin-avatar.png',
    email_verified: true,
    identities: [
      {
        connection: 'Username-Password-Authentication',
        provider: 'auth0',
        user_id: '987654321',
        isSocial: false
      }
    ],
    app_metadata: {
      roles: ['admin', 'customer']
    },
    user_metadata: {
      preferences: {
        theme: 'light'
      }
    },
    created_at: '2023-01-01T00:00:00.000Z',
    updated_at: '2023-01-01T00:00:00.000Z'
  }
];

// Initialize mock users
defaultUsers.forEach(user => {
  mockUsers.set(user.user_id, user);
});

// Mock tokens
const mockTokens = new Map();

// Mock Auth0 Management API client
const ManagementClientMock = jest.fn().mockImplementation(() => ({
  // Users API
  users: {
    get: jest.fn().mockImplementation(async (params) => {
      const user = mockUsers.get(params.id);
      if (!user) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
      }
      return user;
    }),
    
    getAll: jest.fn().mockImplementation(async (params) => {
      let users = Array.from(mockUsers.values());
      
      // Apply filters if provided
      if (params.q) {
        const query = params.q.toLowerCase();
        users = users.filter(user => 
          user.email.toLowerCase().includes(query) || 
          user.name.toLowerCase().includes(query)
        );
      }
      
      if (params.search_engine === 'v3') {
        // Simulate Lucene query
        if (params.q && params.q.startsWith('app_metadata.roles:')) {
          const role = params.q.split(':')[1].trim();
          users = users.filter(user => 
            user.app_metadata?.roles?.includes(role)
          );
        }
      }
      
      // Apply pagination
      const page = params.page || 0;
      const perPage = params.per_page || 50;
      const start = page * perPage;
      const end = start + perPage;
      const paginatedUsers = users.slice(start, end);
      
      return paginatedUsers;
    }),
    
    create: jest.fn().mockImplementation(async (data) => {
      const userId = data.user_id || `auth0|${Date.now()}`;
      const newUser = {
        user_id: userId,
        email: data.email,
        name: data.name || data.email.split('@')[0],
        nickname: data.nickname || data.email.split('@')[0],
        picture: data.picture || 'https://example.com/default-avatar.png',
        email_verified: data.email_verified || false,
        identities: data.identities || [
          {
            connection: 'Username-Password-Authentication',
            provider: 'auth0',
            user_id: userId.split('|')[1],
            isSocial: false
          }
        ],
        app_metadata: data.app_metadata || {},
        user_metadata: data.user_metadata || {},
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
      
      mockUsers.set(userId, newUser);
      return newUser;
    }),
    
    update: jest.fn().mockImplementation(async (params, data) => {
      const user = mockUsers.get(params.id);
      if (!user) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
      }
      
      const updatedUser = {
        ...user,
        ...data,
        updated_at: new Date().toISOString()
      };
      
      mockUsers.set(params.id, updatedUser);
      return updatedUser;
    }),
    
    delete: jest.fn().mockImplementation(async (params) => {
      const exists = mockUsers.has(params.id);
      if (!exists) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
      }
      
      mockUsers.delete(params.id);
      return { deleted: true };
    })
  },
  
  // Roles API
  roles: {
    get: jest.fn().mockImplementation(async (params) => {
      return {
        id: params.id,
        name: params.id === 'rol_admin' ? 'admin' : 'customer',
        description: params.id === 'rol_admin' ? 'Administrator' : 'Customer'
      };
    }),
    
    getAll: jest.fn().mockImplementation(async () => {
      return [
        {
          id: 'rol_admin',
          name: 'admin',
          description: 'Administrator'
        },
        {
          id: 'rol_customer',
          name: 'customer',
          description: 'Customer'
        }
      ];
    }),
    
    create: jest.fn().mockImplementation(async (data) => {
      return {
        id: `rol_${data.name.toLowerCase()}`,
        name: data.name,
        description: data.description || ''
      };
    }),
    
    delete: jest.fn().mockImplementation(async (params) => {
      return { deleted: true };
    }),
    
    // User roles
    getUserRoles: jest.fn().mockImplementation(async (params) => {
      const user = mockUsers.get(params.id);
      if (!user) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
      }
      
      const roles = user.app_metadata?.roles || [];
      return roles.map(role => ({
        id: `rol_${role}`,
        name: role,
        description: role === 'admin' ? 'Administrator' : 'Customer'
      }));
    }),
    
    assignUsers: jest.fn().mockImplementation(async (params, users) => {
      const roleName = params.id === 'rol_admin' ? 'admin' : 'customer';
      
      users.forEach(userId => {
        const user = mockUsers.get(userId);
        if (user) {
          if (!user.app_metadata) {
            user.app_metadata = {};
          }
          if (!user.app_metadata.roles) {
            user.app_metadata.roles = [];
          }
          if (!user.app_metadata.roles.includes(roleName)) {
            user.app_metadata.roles.push(roleName);
          }
          user.updated_at = new Date().toISOString();
          mockUsers.set(userId, user);
        }
      });
      
      return { assigned: true };
    }),
    
    removeUsers: jest.fn().mockImplementation(async (params, users) => {
      const roleName = params.id === 'rol_admin' ? 'admin' : 'customer';
      
      users.forEach(userId => {
        const user = mockUsers.get(userId);
        if (user && user.app_metadata?.roles) {
          user.app_metadata.roles = user.app_metadata.roles.filter(r => r !== roleName);
          user.updated_at = new Date().toISOString();
          mockUsers.set(userId, user);
        }
      });
      
      return { removed: true };
    })
  }
}));

// Mock Auth0 Authentication API client
const AuthenticationClientMock = jest.fn().mockImplementation(() => ({
  // Database authentication
  database: {
    signUp: jest.fn().mockImplementation(async (data) => {
      const userId = `auth0|${Date.now()}`;
      const newUser = {
        user_id: userId,
        email: data.email,
        name: data.name || data.email.split('@')[0],
        nickname: data.nickname || data.email.split('@')[0],
        email_verified: false,
        identities: [
          {
            connection: 'Username-Password-Authentication',
            provider: 'auth0',
            user_id: userId.split('|')[1],
            isSocial: false
          }
        ],
        app_metadata: {
          roles: ['customer']
        },
        user_metadata: {},
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
      
      mockUsers.set(userId, newUser);
      return { _id: userId };
    }),
    
    signIn: jest.fn().mockImplementation(async (data) => {
      // Find user by email
      const user = Array.from(mockUsers.values()).find(u => u.email === data.email);
      
      if (!user) {
        const error = new Error('Wrong email or password');
        error.statusCode = 401;
        throw error;
      }
      
      // In a real implementation, we would verify the password here
      // For testing, we'll just assume it's correct
      
      const accessToken = `access_token_${Date.now()}`;
      const idToken = `id_token_${Date.now()}`;
      const refreshToken = `refresh_token_${Date.now()}`;
      
      mockTokens.set(accessToken, {
        user_id: user.user_id,
        exp: Math.floor(Date.now() / 1000) + 86400 // 24 hours
      });
      
      mockTokens.set(refreshToken, {
        user_id: user.user_id,
        exp: Math.floor(Date.now() / 1000) + 2592000 // 30 days
      });
      
      return {
        access_token: accessToken,
        id_token: idToken,
        refresh_token: refreshToken,
        token_type: 'Bearer',
        expires_in: 86400
      };
    })
  },
  
  // OAuth authentication
  oauth: {
    passwordGrant: jest.fn().mockImplementation(async (data) => {
      // Find user by email
      const user = Array.from(mockUsers.values()).find(u => u.email === data.username);
      
      if (!user) {
        const error = new Error('Wrong email or password');
        error.statusCode = 401;
        throw error;
      }
      
      // In a real implementation, we would verify the password here
      // For testing, we'll just assume it's correct
      
      const accessToken = `access_token_${Date.now()}`;
      const idToken = `id_token_${Date.now()}`;
      const refreshToken = `refresh_token_${Date.now()}`;
      
      mockTokens.set(accessToken, {
        user_id: user.user_id,
        exp: Math.floor(Date.now() / 1000) + 86400 // 24 hours
      });
      
      mockTokens.set(refreshToken, {
        user_id: user.user_id,
        exp: Math.floor(Date.now() / 1000) + 2592000 // 30 days
      });
      
      return {
        access_token: accessToken,
        id_token: idToken,
        refresh_token: refreshToken,
        token_type: 'Bearer',
        expires_in: 86400
      };
    }),
    
    refreshToken: jest.fn().mockImplementation(async (refreshToken) => {
      const tokenInfo = mockTokens.get(refreshToken);
      
      if (!tokenInfo || tokenInfo.exp < Math.floor(Date.now() / 1000)) {
        const error = new Error('Invalid or expired refresh token');
        error.statusCode = 401;
        throw error;
      }
      
      const user = mockUsers.get(tokenInfo.user_id);
      
      if (!user) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
      }
      
      const accessToken = `access_token_${Date.now()}`;
      const idToken = `id_token_${Date.now()}`;
      const newRefreshToken = `refresh_token_${Date.now()}`;
      
      mockTokens.set(accessToken, {
        user_id: user.user_id,
        exp: Math.floor(Date.now() / 1000) + 86400 // 24 hours
      });
      
      mockTokens.set(newRefreshToken, {
        user_id: user.user_id,
        exp: Math.floor(Date.now() / 1000) + 2592000 // 30 days
      });
      
      return {
        access_token: accessToken,
        id_token: idToken,
        refresh_token: newRefreshToken,
        token_type: 'Bearer',
        expires_in: 86400
      };
    })
  },
  
  // Token verification
  tokens: {
    getInfo: jest.fn().mockImplementation(async (accessToken) => {
      const tokenInfo = mockTokens.get(accessToken);
      
      if (!tokenInfo || tokenInfo.exp < Math.floor(Date.now() / 1000)) {
        const error = new Error('Invalid or expired token');
        error.statusCode = 401;
        throw error;
      }
      
      const user = mockUsers.get(tokenInfo.user_id);
      
      if (!user) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
      }
      
      return {
        user_id: user.user_id,
        email: user.email,
        name: user.name,
        nickname: user.nickname,
        picture: user.picture,
        app_metadata: user.app_metadata,
        user_metadata: user.user_metadata
      };
    })
  }
}));

// Mock JWT verification
const verifyJWTMock = jest.fn().mockImplementation((token) => {
  const tokenInfo = mockTokens.get(token);
  
  if (!tokenInfo || tokenInfo.exp < Math.floor(Date.now() / 1000)) {
    throw new Error('Invalid or expired token');
  }
  
  const user = mockUsers.get(tokenInfo.user_id);
  
  if (!user) {
    throw new Error('User not found');
  }
  
  return {
    sub: user.user_id,
    email: user.email,
    name: user.name,
    nickname: user.nickname,
    picture: user.picture,
    'https://fomo-app.com/roles': user.app_metadata?.roles || [],
    'https://fomo-app.com/user_metadata': user.user_metadata || {}
  };
});

// Utility functions for testing
const auth0TestUtils = {
  // Add a test user
  addTestUser: (userData) => {
    const userId = userData.user_id || `auth0|${Date.now()}`;
    const user = {
      user_id: userId,
      email: userData.email || `test-${Date.now()}@example.com`,
      name: userData.name || `Test User ${Date.now()}`,
      nickname: userData.nickname || `testuser-${Date.now()}`,
      picture: userData.picture || 'https://example.com/default-avatar.png',
      email_verified: userData.email_verified || false,
      identities: userData.identities || [
        {
          connection: 'Username-Password-Authentication',
          provider: 'auth0',
          user_id: userId.split('|')[1],
          isSocial: false
        }
      ],
      app_metadata: userData.app_metadata || {},
      user_metadata: userData.user_metadata || {},
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    mockUsers.set(userId, user);
    return user;
  },
  
  // Generate a valid token for a user
  generateToken: (userId) => {
    const user = mockUsers.get(userId);
    
    if (!user) {
      throw new Error('User not found');
    }
    
    const accessToken = `access_token_${Date.now()}`;
    
    mockTokens.set(accessToken, {
      user_id: user.user_id,
      exp: Math.floor(Date.now() / 1000) + 86400 // 24 hours
    });
    
    return accessToken;
  },
  
  // Reset the mock state
  resetMocks: () => {
    mockUsers.clear();
    mockTokens.clear();
    
    // Restore default users
    defaultUsers.forEach(user => {
      mockUsers.set(user.user_id, user);
    });
    
    // Reset all mock functions
    jest.clearAllMocks();
  }
};

module.exports = {
  ManagementClient: ManagementClientMock,
  AuthenticationClient: AuthenticationClientMock,
  verifyJWT: verifyJWTMock,
  testUtils: auth0TestUtils
}; 