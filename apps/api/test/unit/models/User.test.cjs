/**
 * @test User Model Unit Tests
 * 
 * These tests verify the User model functionality, including:
 * - Document creation and validation
 * - Password hashing and verification
 * - Business logic methods
 * - Field validations
 */

const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const { User } = require('../../../models/User.cjs');
const { connectToTestDatabase, cleanupTestData } = require('../../helpers/testSetup.cjs');

describe('User Model', () => {
  beforeAll(async () => {
    await connectToTestDatabase();
  });

  afterAll(async () => {
    await cleanupTestData();
    await mongoose.connection.close();
  });

  afterEach(async () => {
    await User.deleteMany({});
  });

  describe('Field Validations', () => {
    test('should create a valid user', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'Password123!',
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '555-123-4567',
        roles: ['customer'],
        authProvider: 'local',
        name: 'Test User'
      };

      const user = new User(userData);
      const savedUser = await user.save();

      expect(savedUser._id).toBeDefined();
      expect(savedUser.email).toBe(userData.email);
      expect(savedUser.firstName).toBe(userData.firstName);
      expect(savedUser.lastName).toBe(userData.lastName);
      expect(savedUser.phoneNumber).toBe(userData.phoneNumber);
      expect(savedUser.roles).toEqual(expect.arrayContaining(userData.roles));
      expect(savedUser.authProvider).toBe(userData.authProvider);
      expect(savedUser.name).toBe(userData.name);
      
      // Password should be hashed, not stored in plain text
      expect(savedUser.password).not.toBe(userData.password);
    });

    test('should require email field', async () => {
      const userData = {
        password: 'Password123!',
        firstName: 'Test',
        lastName: 'User',
        name: 'Test User'
      };

      const user = new User(userData);
      
      await expect(user.save()).rejects.toThrow();
    });

    test('should validate email format', async () => {
      const userData = {
        email: 'invalid-email',
        password: 'Password123!',
        firstName: 'Test',
        lastName: 'User',
        name: 'Test User'
      };

      const user = new User(userData);
      
      await expect(user.save()).rejects.toThrow();
    });

    test('should enforce password complexity if using local auth', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'weak',  // Too short, no numbers or special chars
        firstName: 'Test',
        lastName: 'User',
        authProvider: 'local',
        name: 'Test User'
      };

      const user = new User(userData);
      
      await expect(user.save()).rejects.toThrow();
    });

    test('should allow password to be optional for OAuth users', async () => {
      const userData = {
        email: 'oauth@example.com',
        name: 'OAuth User',
        firstName: 'OAuth',
        lastName: 'User',
        authProvider: 'google'
      };

      const user = new User(userData);
      const savedUser = await user.save();
      
      expect(savedUser._id).toBeDefined();
      expect(savedUser.password).toBeUndefined();
    });
  });

  describe('Password Management', () => {
    test('should hash password on save', async () => {
      const plainPassword = 'Password123!';
      const user = new User({
        email: 'test@example.com',
        password: plainPassword,
        firstName: 'Test',
        lastName: 'User',
        authProvider: 'local',
        name: 'Test User'
      });

      const savedUser = await user.save();
      
      // Password should be hashed (not plain text)
      expect(savedUser.password).not.toBe(plainPassword);
      expect(savedUser.password.startsWith('$2b$')).toBe(true); // bcrypt hash format
    });

    test('should verify correct password', async () => {
      const plainPassword = 'Password123!';
      const user = new User({
        email: 'test@example.com',
        password: plainPassword,
        firstName: 'Test',
        lastName: 'User',
        authProvider: 'local',
        name: 'Test User'
      });

      await user.save();
      
      const isValid = await user.verifyPassword(plainPassword);
      expect(isValid).toBe(true);
    });

    test('should reject incorrect password', async () => {
      const user = new User({
        email: 'test@example.com',
        password: 'Password123!',
        firstName: 'Test',
        lastName: 'User',
        authProvider: 'local',
        name: 'Test User'
      });

      await user.save();
      
      const isValid = await user.verifyPassword('WrongPassword123!');
      expect(isValid).toBe(false);
    });
  });

  describe('User Methods', () => {
    test('should get full name correctly', async () => {
      const user = new User({
        email: 'test@example.com',
        password: 'Password123!',
        firstName: 'John',
        lastName: 'Doe',
        authProvider: 'local',
        name: 'John Doe'
      });

      await user.save();
      
      expect(user.getFullName()).toBe('John Doe');
    });

    test('should handle missing name components gracefully', async () => {
      const user = new User({
        email: 'test@example.com',
        password: 'Password123!',
        firstName: 'John',
        // Missing lastName
        authProvider: 'local',
        name: 'John'
      });

      await user.save();
      
      expect(user.getFullName()).toBe('John');
    });

    test('should check if user has a specific role', async () => {
      // Mock the FeatureManager directly
      const FeatureManager = require('../../../services/payment/FeatureManager.cjs');
      
      // Save original methods
      const originalGetFeatureState = FeatureManager.getFeatureState;
      const originalIsEnabled = FeatureManager.isEnabled;
      
      // Mock the methods
      FeatureManager.getFeatureState = jest.fn().mockResolvedValue({
        enabled: true,
        description: 'Test feature flag',
        state: 'active'
      });
      
      FeatureManager.isEnabled = jest.fn().mockResolvedValue(true);
      
      try {
        const user = new User({
          email: 'admin@example.com',
          password: 'Password123!',
          firstName: 'Admin',
          lastName: 'User',
          roles: ['customer', 'admin'],
          authProvider: 'local',
          name: 'Admin User'
        });

        await user.save();
        
        expect(await user.hasRole('admin')).toBe(true);
        expect(await user.hasRole('customer')).toBe(true);
        expect(await user.hasRole('venue_manager')).toBe(false);
      } finally {
        // Restore original methods
        FeatureManager.getFeatureState = originalGetFeatureState;
        FeatureManager.isEnabled = originalIsEnabled;
      }
    });
  });

  describe('User Query Helpers', () => {
    test('should find active users with findActive', async () => {
      // Create active and inactive users
      await User.create([
        {
          email: 'active@example.com',
          password: 'Password123!',
          firstName: 'Active',
          lastName: 'User',
          status: 'active',
          authProvider: 'local',
          name: 'Active User'
        },
        {
          email: 'inactive@example.com',
          password: 'Password123!',
          firstName: 'Inactive',
          lastName: 'User',
          status: 'inactive',
          authProvider: 'local',
          name: 'Inactive User'
        }
      ]);

      const activeUsers = await User.findActive();
      
      expect(activeUsers.length).toBe(1);
      expect(activeUsers[0].email).toBe('active@example.com');
    });

    test('should find users by role', async () => {
      // Create users with different roles
      await User.create([
        {
          email: 'admin@example.com',
          password: 'Password123!',
          firstName: 'Admin',
          lastName: 'User',
          roles: ['admin'],
          authProvider: 'local',
          name: 'Admin User'
        },
        {
          email: 'customer@example.com',
          password: 'Password123!',
          firstName: 'Regular',
          lastName: 'Customer',
          roles: ['customer'],
          authProvider: 'local',
          name: 'Regular Customer'
        }
      ]);

      const admins = await User.findByRole('admin');
      
      expect(admins.length).toBe(1);
      expect(admins[0].email).toBe('admin@example.com');
    });
  });

  describe('Updated User Features', () => {
    test('should track last login time', async () => {
      const user = new User({
        email: 'test@example.com',
        password: 'Password123!',
        firstName: 'Test',
        lastName: 'User',
        authProvider: 'local',
        name: 'Test User'
      });

      await user.save();
      
      // Simulate login
      const loginTime = new Date();
      user.lastLoginAt = loginTime;
      await user.save();
      
      const updatedUser = await User.findOne({ email: 'test@example.com' });
      expect(updatedUser.lastLoginAt).toBeDefined();
      expect(updatedUser.lastLoginAt.getTime()).toBeCloseTo(loginTime.getTime(), -2); // Within 100ms
    });

    test('should handle preferred venues', async () => {
      const user = new User({
        email: 'test@example.com',
        password: 'Password123!',
        firstName: 'Test',
        lastName: 'User',
        authProvider: 'local',
        preferredVenues: [],
        name: 'Test User'
      });

      await user.save();
      
      // Add preferred venues
      const venueId1 = new mongoose.Types.ObjectId();
      const venueId2 = new mongoose.Types.ObjectId();
      
      user.preferredVenues.push(venueId1);
      user.preferredVenues.push(venueId2);
      await user.save();
      
      const updatedUser = await User.findOne({ email: 'test@example.com' });
      expect(updatedUser.preferredVenues.length).toBe(2);
      expect(updatedUser.preferredVenues[0].toString()).toBe(venueId1.toString());
      expect(updatedUser.preferredVenues[1].toString()).toBe(venueId2.toString());
    });

    test('should enforce unique email across all users', async () => {
      // Create first user
      await User.create({
        email: 'duplicate@example.com',
        password: 'Password123!',
        firstName: 'First',
        lastName: 'User',
        authProvider: 'local',
        name: 'First User'
      });
      
      // Try to create second user with same email
      const duplicateUser = new User({
        email: 'duplicate@example.com', // Same email
        password: 'DifferentPass456!',
        firstName: 'Second',
        lastName: 'User',
        authProvider: 'local',
        name: 'Second User'
      });
      
      await expect(duplicateUser.save()).rejects.toThrow();
    });
  });
}); 