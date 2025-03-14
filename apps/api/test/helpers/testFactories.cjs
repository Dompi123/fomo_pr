/**
 * Test Factories
 * 
 * Helper functions to create valid test data for models.
 * These factories generate objects with all required fields populated with
 * sensible defaults, while allowing custom overrides.
 */

const mongoose = require('mongoose');

/**
 * Deep merge two objects
 * @param {Object} target - The target object
 * @param {Object} source - The source object
 * @returns {Object} The merged object
 */
function deepMerge(target, source) {
  const result = { ...target };
  
  if (!source) {
    return result;
  }
  
  Object.keys(source).forEach(key => {
    if (typeof source[key] === 'object' && source[key] !== null && 
        !Array.isArray(source[key]) && typeof target[key] === 'object' && 
        target[key] !== null && !Array.isArray(target[key])) {
      // Recursively merge nested objects
      result[key] = deepMerge(target[key], source[key]);
    } else if (Array.isArray(source[key]) && Array.isArray(target[key])) {
      // Merge arrays with special handling if elements are objects
      result[key] = target[key].map((item, index) => {
        if (index < source[key].length && typeof item === 'object' && 
            typeof source[key][index] === 'object') {
          return deepMerge(item, source[key][index]);
        }
        return source[key][index] || item;
      });
      
      // Add any additional items from source array
      if (source[key].length > target[key].length) {
        result[key] = result[key].concat(
          source[key].slice(target[key].length)
        );
      }
    } else {
      // Simple property assignment
      result[key] = source[key];
    }
  });
  
  return result;
}

/**
 * Creates valid test data for a Venue
 * @param {Object} overrides - Custom field values to override defaults
 * @returns {Object} A valid Venue object that will pass schema validation
 */
function createTestVenueData(overrides = {}) {
  // Create a comprehensive default venue with all required fields
  const defaultVenue = {
    name: 'Test Venue',
    type: 'Nightclub',
    music: 'Hip Hop',
    image: 'https://example.com/image.jpg',
    address: {
      street: '123 Test Street',
      city: 'Test City',
      state: 'Test State',
      zipCode: '12345',
      country: 'Test Country'
    },
    location: {
      address: '123 Test Street',
      city: 'Test City',
      province: 'Test Province',
      postalCode: '12345'
    },
    operatingHours: {
      monday: { open: '17:00', close: '02:00' },
      tuesday: { open: '17:00', close: '02:00' },
      wednesday: { open: '17:00', close: '02:00' },
      thursday: { open: '17:00', close: '02:00' },
      friday: { open: '16:00', close: '03:00' },
      saturday: { open: '16:00', close: '03:00' },
      sunday: { open: '16:00', close: '00:00' }
    },
    contactEmail: 'venue@example.com',
    contactPhone: '555-123-4567',
    capacity: 500,
    currentCapacity: 0,
    ownerId: new mongoose.Types.ObjectId(),
    managers: [],
    status: 'active',
    openingDate: new Date(),
    createdAt: new Date(),
    updatedAt: new Date(),
    description: 'A test venue for testing purposes',
    promoters: [],
    features: ['VIP Section', 'Dance Floor', 'Full Bar'],
    reviews: [],
    rating: 4.5,
    passes: [
      {
        name: 'VIP Pass',
        type: 'VIP',
        price: 5000, // $50.00
        isAvailable: true,
        maxDaily: 100,
        description: 'VIP access to the venue',
        instructions: 'Show this pass to the staff'
      },
      {
        name: 'Line Skip Pass',
        type: 'LineSkip',
        price: 2000, // $20.00
        isAvailable: true,
        maxDaily: 200,
        description: 'Skip the line at the venue',
        instructions: 'Show this pass at the entrance'
      }
    ],
    pricing: {
      coverCharge: 1000, // $10.00
      minimumSpend: 5000, // $50.00
      specialOffers: []
    },
    amenities: {
      smokingArea: true,
      parking: false,
      foodService: true,
      accessibleEntrance: true
    },
    settings: {
      allowsReservations: true,
      requiresIDVerification: true,
      ageRestriction: 21,
      dressCode: 'Casual Elegant'
    }
  };
  
  // Use deep merge to handle nested structures
  return deepMerge(defaultVenue, overrides);
}

/**
 * Creates valid test data for a User
 * @param {Object} overrides - Custom field values to override defaults
 * @returns {Object} A valid User object that will pass schema validation
 */
function createTestUserData(overrides = {}) {
  // Create a comprehensive default user with all required fields
  const userId = new mongoose.Types.ObjectId();
  const defaultUser = {
    _id: userId,
    name: 'Test User',
    email: `test-${Date.now()}@example.com`,
    password: 'Password123!', // Note: This will be hashed by the model
    role: 'customer',
    firstName: 'Test',
    lastName: 'User',
    phoneNumber: '555-123-4567',
    dateOfBirth: new Date('1990-01-01'),
    authProvider: 'local',
    authProviderUserId: null,
    lastLoginAt: new Date(),
    isVerified: true,
    verifiedBy: 'system',
    status: 'active',
    createdAt: new Date(),
    updatedAt: new Date(),
    profileImage: 'https://example.com/profile.jpg',
    preferences: {
      notifications: {
        email: true,
        push: true,
        sms: false,
        orderUpdates: true,
        promotions: true,
        events: true
      },
      favoriteVenues: [],
      theme: 'dark',
      language: 'en'
    },
    friends: [],
    managedVenues: [],
    likedVenues: [],
    passes: [],
    transactionHistory: [],
    purchaseHistory: [],
    deviceTokens: [],
    activityHistory: [],
    friendRequests: []
  };
  
  // Deep merge with overrides
  return deepMerge(defaultUser, overrides);
}

/**
 * Creates valid test data for a Pass
 * @param {Object} overrides - Custom field values to override defaults
 * @returns {Object} A valid Pass object that will pass schema validation
 */
function createTestPassData(overrides = {}) {
  const passId = new mongoose.Types.ObjectId();
  const defaultPass = {
    _id: passId,
    userId: new mongoose.Types.ObjectId(),
    venueId: new mongoose.Types.ObjectId(),
    type: 'VIP',
    name: 'VIP Pass',
    purchaseDate: new Date(),
    expirationDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
    status: 'active',
    price: 5000, // $50.00
    paymentIntentId: `pi_test${Date.now()}${Math.random().toString(36).substring(2, 7)}`,
    idempotencyKey: `idem_${Date.now()}${Math.random().toString(36).substring(2, 7)}`,
    purchaseAmount: 5000, // $50.00
    redemptionCode: `PASS-${Math.random().toString(36).substring(2, 10).toUpperCase()}`,
    isRedeemed: false,
    redeemedAt: null,
    metadata: {
      purchaseIP: '192.168.1.1',
      userAgent: 'Mozilla/5.0',
      platform: 'web'
    },
    passIssueDate: new Date(),
    passValidationData: {
      signature: 'test-signature',
      validationHash: 'test-hash',
      securityToken: 'test-token'
    },
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  // Deep merge with overrides
  return deepMerge(defaultPass, overrides);
}

/**
 * Creates valid test data for an OrderLock
 * @param {Object} overrides - Custom field values to override defaults
 * @returns {Object} A valid OrderLock object that will pass schema validation
 */
function createTestOrderLockData(overrides = {}) {
  const defaultMetadata = {
    userId: new mongoose.Types.ObjectId(),
    venueId: new mongoose.Types.ObjectId(),
    amount: 5000,
    passType: 'VIP',
    email: 'test@example.com',
    name: 'Test User'
  };
  
  // Handle metadata separately to ensure deep merging
  let mergedMetadata = { ...defaultMetadata };
  if (overrides && overrides.metadata) {
    mergedMetadata = { ...mergedMetadata, ...overrides.metadata };
    // Remove from overrides to prevent duplication
    const { metadata, ...restOverrides } = overrides;
    overrides = restOverrides;
  }
  
  const defaultLock = {
    idempotencyKey: `lock_${Date.now()}${Math.random().toString(36).substring(2, 7)}`,
    status: 'pending',
    createdAt: new Date(),
    updatedAt: new Date(),
    expiresAt: new Date(Date.now() + 15 * 60 * 1000), // 15 minutes from now
    metadata: mergedMetadata
  };
  
  // Merge with overrides
  return deepMerge(defaultLock, overrides);
}

/**
 * Creates valid test data for an Order
 * @param {Object} overrides - Custom field values to override defaults
 * @returns {Object} A valid Order object that will pass schema validation
 */
function createTestOrderData(overrides = {}) {
  const orderId = new mongoose.Types.ObjectId();
  const userId = new mongoose.Types.ObjectId();
  const venueId = new mongoose.Types.ObjectId();
  
  const defaultOrder = {
    _id: orderId,
    userId: userId,
    venueId: venueId,
    orderNumber: `ORD-${Date.now().toString(36).toUpperCase()}`,
    items: [
      {
        type: 'pass',
        passType: 'VIP',
        name: 'VIP Pass',
        quantity: 1,
        unitPrice: 5000,
        totalPrice: 5000
      }
    ],
    subTotal: 5000,
    tax: 500,
    serviceFee: 250,
    totalAmount: 5750,
    paymentStatus: 'paid',
    orderStatus: 'completed',
    paymentIntentId: `pi_test${Date.now()}${Math.random().toString(36).substring(2, 7)}`,
    paymentMethodId: `pm_test${Math.random().toString(36).substring(2, 10)}`,
    receiptUrl: `https://example.com/receipts/${orderId}`,
    createdAt: new Date(),
    updatedAt: new Date(),
    metadata: {
      source: 'mobile',
      ipAddress: '192.168.1.1',
      userAgent: 'Mozilla/5.0'
    }
  };
  
  // Deep merge with overrides
  return deepMerge(defaultOrder, overrides);
}

/**
 * Creates valid test data for a Payment
 * @param {Object} overrides - Custom field values to override defaults
 * @returns {Object} A valid Payment object that will pass schema validation
 */
function createTestPaymentData(overrides = {}) {
  const paymentId = new mongoose.Types.ObjectId();
  const userId = new mongoose.Types.ObjectId();
  const venueId = new mongoose.Types.ObjectId();
  const orderId = new mongoose.Types.ObjectId();
  
  const defaultPayment = {
    _id: paymentId,
    userId: userId,
    venueId: venueId,
    orderId: orderId,
    amount: 5750,
    currency: 'usd',
    paymentMethod: 'card',
    paymentMethodDetails: {
      type: 'card',
      card: {
        brand: 'visa',
        last4: '4242',
        expiryMonth: 12,
        expiryYear: 2025
      }
    },
    status: 'succeeded',
    paymentIntentId: `pi_test${Date.now()}${Math.random().toString(36).substring(2, 7)}`,
    chargeId: `ch_test${Math.random().toString(36).substring(2, 10)}`,
    balanceTransactionId: `txn_test${Math.random().toString(36).substring(2, 10)}`,
    receiptUrl: `https://example.com/receipts/${paymentId}`,
    refunded: false,
    refundedAmount: 0,
    createdAt: new Date(),
    updatedAt: new Date(),
    idempotencyKey: `idem_${Date.now()}${Math.random().toString(36).substring(2, 7)}`,
    metadata: {
      orderType: 'pass',
      source: 'mobile'
    }
  };
  
  // Deep merge with overrides
  return deepMerge(defaultPayment, overrides);
}

/**
 * Utility function to generate a random email address
 * @returns {string} A random email address
 */
function randomEmail() {
  return `test-${Date.now()}-${Math.random().toString(36).substring(2, 7)}@example.com`;
}

/**
 * Utility function to generate a random string
 * @param {number} length - The length of the string
 * @returns {string} A random string
 */
function randomString(length = 10) {
  return Math.random().toString(36).substring(2, 2 + length);
}

// Export all factory functions
module.exports = {
  createTestVenueData,
  createTestUserData, 
  createTestPassData,
  createTestOrderLockData,
  createTestOrderData,
  createTestPaymentData,
  randomEmail,
  randomString,
  // Utility functions
  deepMerge
}; 