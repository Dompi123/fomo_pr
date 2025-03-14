/**
 * @test Venue Management Integration Tests
 * 
 * These tests verify venue management operations, including:
 * - Creating and updating venues
 * - Managing venue capacity
 * - Handling venue operating hours
 * - Venue permissions and access control
 */

const request = require('supertest');
const mongoose = require('mongoose');
const { app } = require('../../../app.cjs');
const Venue = require('../../../models/Venue.cjs');
const { User } = require('../../../models/User.cjs');
const { 
  connectToTestDatabase, 
  cleanupTestData, 
  createTestUser,
  createTestVenue,
  createTestAdmin
} = require('../../helpers/testSetup.cjs');

describe('Venue Management', () => {
  let testUser;
  let adminUser;
  let testVenue;
  let userToken;
  let adminToken;

  beforeAll(async () => {
    await connectToTestDatabase();
    
    // Create test users
    testUser = await createTestUser({ role: 'customer' });
    adminUser = await createTestAdmin();
    
    // Create test tokens
    userToken = 'user-test-token';
    adminToken = 'admin-test-token';
    
    // Mock authentication middleware
    jest.spyOn(app, 'use').mockImplementation((middleware) => {
      if (typeof middleware === 'function') {
        app.all('*', (req, res, next) => {
          if (req.headers.authorization === `Bearer ${userToken}`) {
            req.user = testUser;
            next();
          } else if (req.headers.authorization === `Bearer ${adminToken}`) {
            req.user = adminUser;
            next();
          } else {
            res.status(401).json({ error: 'Unauthorized' });
          }
        });
      }
    });
  });

  afterAll(async () => {
    await cleanupTestData();
    await mongoose.connection.close();
    jest.restoreAllMocks();
  });

  afterEach(async () => {
    await Venue.deleteMany({});
  });

  describe('Venue Creation', () => {
    test('admins should be able to create venues', async () => {
      const venueData = {
        name: 'Test Club',
        address: {
          street: '123 Party Ave',
          city: 'Nightlife City',
          state: 'CA',
          zipCode: '90210',
          country: 'USA'
        },
        description: 'The hottest club in town',
        capacity: 500,
        contactEmail: 'club@example.com',
        contactPhone: '555-123-4567',
        openingHours: {
          monday: { open: '18:00', close: '02:00' },
          tuesday: { open: '18:00', close: '02:00' },
          wednesday: { open: '18:00', close: '02:00' },
          thursday: { open: '18:00', close: '02:00' },
          friday: { open: '18:00', close: '04:00' },
          saturday: { open: '18:00', close: '04:00' },
          sunday: { open: '18:00', close: '02:00' }
        }
      };

      const response = await request(app)
        .post('/api/venues')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(venueData);

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('_id');
      expect(response.body.name).toBe(venueData.name);
      expect(response.body.capacity).toBe(venueData.capacity);
      
      // Verify venue was created in database
      const venue = await Venue.findById(response.body._id);
      expect(venue).not.toBeNull();
      expect(venue.name).toBe(venueData.name);
    });

    test('regular users should not be able to create venues', async () => {
      const venueData = {
        name: 'Unauthorized Club',
        capacity: 200
      };

      const response = await request(app)
        .post('/api/venues')
        .set('Authorization', `Bearer ${userToken}`)
        .send(venueData);

      expect(response.status).toBe(403);
      
      // Verify venue was not created
      const venuesCount = await Venue.countDocuments();
      expect(venuesCount).toBe(0);
    });
  });

  describe('Venue Updates', () => {
    beforeEach(async () => {
      // Create a test venue for update tests
      testVenue = await createTestVenue();
    });

    test('admins should be able to update venues', async () => {
      const updateData = {
        name: 'Updated Club Name',
        capacity: 750,
        description: 'Newly renovated nightclub'
      };

      const response = await request(app)
        .put(`/api/venues/${testVenue._id}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(updateData);

      expect(response.status).toBe(200);
      expect(response.body.name).toBe(updateData.name);
      expect(response.body.capacity).toBe(updateData.capacity);
      
      // Verify update in database
      const updatedVenue = await Venue.findById(testVenue._id);
      expect(updatedVenue.name).toBe(updateData.name);
      expect(updatedVenue.capacity).toBe(updateData.capacity);
    });

    test('venue managers should be able to update their venues', async () => {
      // Create a venue manager user
      const venueManager = await createTestUser({
        role: 'venue_manager',
        managedVenues: [testVenue._id]
      });
      
      // Create a manager token
      const managerToken = 'manager-test-token';
      
      // Update auth mock to recognize manager
      app.all('*', (req, res, next) => {
        if (req.headers.authorization === `Bearer ${managerToken}`) {
          req.user = venueManager;
          next();
        } else {
          next();
        }
      });

      const updateData = {
        description: 'Manager updated description',
        contactEmail: 'new-manager@example.com'
      };

      const response = await request(app)
        .put(`/api/venues/${testVenue._id}`)
        .set('Authorization', `Bearer ${managerToken}`)
        .send(updateData);

      expect(response.status).toBe(200);
      expect(response.body.description).toBe(updateData.description);
      
      // Verify update in database
      const updatedVenue = await Venue.findById(testVenue._id);
      expect(updatedVenue.description).toBe(updateData.description);
    });

    test('regular users should not be able to update venues', async () => {
      const updateData = {
        name: 'Unauthorized Update'
      };

      const response = await request(app)
        .put(`/api/venues/${testVenue._id}`)
        .set('Authorization', `Bearer ${userToken}`)
        .send(updateData);

      expect(response.status).toBe(403);
      
      // Verify venue was not updated
      const unchangedVenue = await Venue.findById(testVenue._id);
      expect(unchangedVenue.name).toBe(testVenue.name);
    });
  });

  describe('Venue Capacity Management', () => {
    beforeEach(async () => {
      // Create a test venue for capacity tests
      testVenue = await createTestVenue({ capacity: 500, currentCapacity: 0 });
    });

    test('should update current capacity', async () => {
      const updateData = {
        currentCapacity: 250
      };

      const response = await request(app)
        .put(`/api/venues/${testVenue._id}/capacity`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(updateData);

      expect(response.status).toBe(200);
      expect(response.body.currentCapacity).toBe(updateData.currentCapacity);
      
      // Verify update in database
      const updatedVenue = await Venue.findById(testVenue._id);
      expect(updatedVenue.currentCapacity).toBe(updateData.currentCapacity);
    });

    test('should not allow capacity to exceed maximum', async () => {
      const updateData = {
        currentCapacity: 600 // Exceeds the maximum of 500
      };

      const response = await request(app)
        .put(`/api/venues/${testVenue._id}/capacity`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(updateData);

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      
      // Verify capacity was not updated
      const unchangedVenue = await Venue.findById(testVenue._id);
      expect(unchangedVenue.currentCapacity).toBe(testVenue.currentCapacity);
    });
  });

  describe('Operating Hours Management', () => {
    beforeEach(async () => {
      // Create a test venue for hours tests
      testVenue = await createTestVenue();
    });

    test('should update operating hours', async () => {
      const updateData = {
        openingHours: {
          friday: { open: '20:00', close: '06:00' },
          saturday: { open: '20:00', close: '06:00' }
        }
      };

      const response = await request(app)
        .put(`/api/venues/${testVenue._id}/hours`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(updateData);

      expect(response.status).toBe(200);
      expect(response.body.openingHours.friday.open).toBe(updateData.openingHours.friday.open);
      expect(response.body.openingHours.friday.close).toBe(updateData.openingHours.friday.close);
      
      // Verify hours were updated in database
      const updatedVenue = await Venue.findById(testVenue._id);
      expect(updatedVenue.openingHours.friday.open).toBe(updateData.openingHours.friday.open);
      expect(updatedVenue.openingHours.friday.close).toBe(updateData.openingHours.friday.close);
    });

    test('should validate operating hour format', async () => {
      const updateData = {
        openingHours: {
          friday: { open: 'invalid-time', close: '06:00' }
        }
      };

      const response = await request(app)
        .put(`/api/venues/${testVenue._id}/hours`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(updateData);

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      
      // Verify hours were not updated
      const unchangedVenue = await Venue.findById(testVenue._id);
      expect(unchangedVenue.openingHours.friday.open).toBe(testVenue.openingHours.friday.open);
    });
  });
}); 