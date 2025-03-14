const mongoose = require('mongoose');
const featureManager = require('../services/payment/FeatureManager.cjs');
const bcrypt = require('bcrypt');

// Get the appropriate role enum based on feature flag
const getRoleEnum = async () => {
  try {
    const isClientSideVerificationEnabled = await featureManager.isEnabled('USE_CLIENT_SIDE_VERIFICATION');
    
    if (isClientSideVerificationEnabled) {
      // When feature flag is enabled, use 'staff' instead of 'bartender'
      return ['customer', 'staff', 'owner', 'admin'];
    } else {
      // When feature flag is disabled, use 'bartender' instead of 'staff'
      return ['customer', 'bartender', 'owner', 'admin'];
    }
  } catch (error) {
    console.error('Error checking feature flag for role enum:', error);
    // Default to allowing both roles to prevent breaking changes
    return ['customer', 'staff', 'bartender', 'owner', 'admin'];
  }
};

// Email validation regex
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Password complexity regex (at least 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char)
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  firstName: String,
  lastName: String,
  phoneNumber: String,
  email: {
    type: String,
    required: true,
    unique: true,
    validate: {
      validator: function(v) {
        return emailRegex.test(v);
      },
      message: props => `${props.value} is not a valid email address!`
    }
  },
  password: {
    type: String,
    validate: {
      validator: function(v) {
        // Skip validation if using OAuth
        if (this.authProvider && this.authProvider !== 'local') {
          return true;
        }
        // Only validate if password is being set/modified
        if (v) {
          return passwordRegex.test(v);
        }
        return true;
      },
      message: props => 'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character'
    }
  },
  role: {
    type: String,
    enum: {
      values: ['customer', 'staff', 'bartender', 'owner', 'admin'],
      message: 'Invalid role: {VALUE}'
    },
    default: 'customer'
  },
  roles: {
    type: [String],
    default: ['customer']
  },
  status: {
    type: String,
    enum: ['active', 'inactive'],
    default: 'active'
  },
  authProvider: {
    type: String,
    enum: ['local', 'google', 'facebook', 'apple'],
    default: 'local'
  },
  auth0Id: {
    type: String,
    unique: true,
    sparse: true
  },
  lastLoginAt: Date,
  preferredVenues: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Venue'
  }],
  likedVenues: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Venue'
  }],
  friends: {
    type: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }],
    default: []
  },
  friendRequests: [{
    from: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'rejected'],
      default: 'pending'
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  // For venue owners
  managedVenues: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Venue'
  }],
  // For customers
  passes: [{
    type: {
      type: String,
      enum: ['cover', 'fomo'],
      required: true
    },
    venue: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Venue'
    },
    purchasedAt: Date,
    expiresAt: Date,
    status: {
      type: String,
      enum: ['active', 'used', 'expired']
    },
    amount: Number,
    passId: String
  }],
  purchaseHistory: [{
    venue: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Venue'
    },
    items: [{
      name: String,
      price: Number,
      quantity: Number
    }],
    total: Number,
    date: {
      type: Date,
      default: Date.now
    },
    paymentMethod: {
      type: String,
      enum: ['credit_card', 'apple_pay', 'google_pay', 'cash']
    }
  }],
  transactionHistory: [{
    type: {
      type: String,
      enum: ['purchase', 'refund', 'credit']
    },
    amount: Number,
    description: String,
    date: {
      type: Date,
      default: Date.now
    },
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed']
    },
    reference: String
  }],
  activityHistory: [{
    type: {
      type: String,
      enum: ['login', 'venue_visit', 'purchase', 'pass_use']
    },
    venue: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Venue'
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    details: mongoose.Schema.Types.Mixed
  }],
  profile: {
    name: String,
    email: String,
    picture: String
  },
  preferences: {
    notifications: {
      promotions: {
        type: Boolean,
        default: true
      },
      orderUpdates: {
        type: Boolean,
        default: true
      }
    },
    favoriteVenues: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Venue'
    }]
  },
  lastActive: Date,
  deviceTokens: [String]
}, {
  timestamps: true
});

// Add additional pre-save hook for explicit email and password validation
userSchema.pre('save', function(next) {
  // Validate email explicitly
  if (this.email && !emailRegex.test(this.email)) {
    const error = new Error(`${this.email} is not a valid email address!`);
    error.name = 'ValidationError';
    return next(error);
  }
  
  // Validate password explicitly for local auth
  if (this.isModified('password') && this.password && 
      (!this.authProvider || this.authProvider === 'local')) {
    if (!passwordRegex.test(this.password)) {
      const error = new Error('Password must be at least 8 characters long and include uppercase, lowercase, number, and special character');
      error.name = 'ValidationError';
      return next(error);
    }
  }
  
  next();
});

// Password hashing middleware
userSchema.pre('save', async function(next) {
  // Only hash the password if it's modified (or new)
  if (!this.isModified('password') || !this.password) return next();
  
  try {
    // Generate a salt
    const salt = await bcrypt.genSalt(10);
    // Hash the password along with the new salt
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Add pre-save hook to validate roles based on feature flag
userSchema.pre('save', async function(next) {
  try {
    // Get the feature flag status with more specific context
    const flagConfig = await featureManager.getFeatureState('USE_CLIENT_SIDE_VERIFICATION');
    console.log(`[USER] Pre-save validation - Flag config:`, 
      flagConfig ? JSON.stringify(flagConfig) : 'Flag not found');
    
    // Only perform validation if the flag exists and is properly configured
    if (flagConfig) {
      const isClientSideVerificationEnabled = flagConfig.enabled === true;
      console.log(`[USER] Pre-save validation - Flag enabled: ${isClientSideVerificationEnabled}`);
      
      // Validate role based on feature flag
      if (isClientSideVerificationEnabled && this.role === 'bartender') {
        const error = new Error('Bartender role is not allowed when USE_CLIENT_SIDE_VERIFICATION is enabled');
        error.name = 'ValidationError';
        return next(error);
      }
      
      if (!isClientSideVerificationEnabled && this.role === 'staff') {
        const error = new Error('Staff role is not allowed when USE_CLIENT_SIDE_VERIFICATION is disabled');
        error.name = 'ValidationError';
        return next(error);
      }
    } else {
      // If the flag doesn't exist, log a warning but don't block save
      console.warn(`[USER] Pre-save validation - Flag USE_CLIENT_SIDE_VERIFICATION not found, skipping role validation`);
    }
    
    next();
  } catch (error) {
    console.error('[USER] Error in pre-save validation:', error);
    // Don't fail validation on errors checking the feature flag
    next();
  }
});

// Password verification method
userSchema.methods.verifyPassword = async function(candidatePassword) {
  if (!this.password) return false;
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    console.error('Error verifying password:', error);
    return false;
  }
};

// Get full name method
userSchema.methods.getFullName = function() {
  if (this.firstName && this.lastName) {
    return `${this.firstName} ${this.lastName}`;
  } else if (this.firstName) {
    return this.firstName;
  } else if (this.lastName) {
    return this.lastName;
  } else {
    return this.name || '';
  }
};

// Add hasRole method to check if user has a specific role or one of multiple roles
userSchema.methods.hasRole = async function(roles) {
  console.log(`[USER] hasRole check - User: ${this.email}, Role: ${this.role}, Checking for: ${Array.isArray(roles) ? roles.join(',') : roles}`);
  
  try {
    // Get the feature flag status to inform role equivalence
    let isClientSideVerificationEnabled = false;
    try {
      const flagConfig = await featureManager.getFeatureState('USE_CLIENT_SIDE_VERIFICATION');
      isClientSideVerificationEnabled = flagConfig && flagConfig.enabled === true;
      console.log(`[USER] hasRole check - USE_CLIENT_SIDE_VERIFICATION enabled: ${isClientSideVerificationEnabled}`);
    } catch (flagError) {
      console.warn(`[USER] hasRole check - Error getting feature flag:`, flagError);
      // Assume false if error occurs
    }
    
    // Handle single role check (string input)
    if (!Array.isArray(roles)) {
      // Direct role match
      const hasDirectMatch = this.role === roles;
      
      // Check roles array
      const hasRoleInArray = this.roles && Array.isArray(this.roles) && this.roles.includes(roles);
      
      // Check equivalent roles based on feature flag
      const hasEquivalentRole = 
        (this.role === 'staff' && roles === 'bartender') || 
        (this.role === 'bartender' && roles === 'staff');
      
      const result = hasDirectMatch || hasRoleInArray || hasEquivalentRole;
      
      console.log(`[USER] hasRole result - Direct match: ${hasDirectMatch}, Role in array: ${hasRoleInArray}, Equivalent role: ${hasEquivalentRole}, Final result: ${result}`);
      return result;
    }
    
    // Handle array of roles (ANY-OF logic)
    // For array input, check if the user has ANY of the roles
    
    // Check if any of the provided roles match the user's role
    const hasDirectMatch = roles.includes(this.role);
    
    // Check if user's roles array includes any role in the input array
    // Fix: For staff role with client-side verification enabled, don't consider default 'customer' role
    let hasRoleInArray = false;
    if (this.roles && Array.isArray(this.roles)) {
      if (isClientSideVerificationEnabled && this.role === 'staff') {
        // For staff users with feature flag enabled, exclude the default 'customer' role
        // when checking against ['customer', 'owner'] or other combinations involving 'customer'
        const nonDefaultRoles = this.roles.filter(r => r !== 'customer');
        hasRoleInArray = roles.some(role => nonDefaultRoles.includes(role));
      } else {
        // Standard check for other roles - keep existing behavior
        hasRoleInArray = roles.some(role => this.roles.includes(role));
      }
    }
    
    // Check equivalent roles (staff/bartender)
    // Need to check if user is staff and array includes bartender OR
    // if user is bartender and array includes staff
    const hasEquivalentRole = 
      (this.role === 'staff' && roles.includes('bartender')) || 
      (this.role === 'bartender' && roles.includes('staff'));
    
    const result = hasDirectMatch || hasRoleInArray || hasEquivalentRole;
    
    console.log(`[USER] hasRole array result - Direct match: ${hasDirectMatch}, Role in array: ${hasRoleInArray}, Equivalent role: ${hasEquivalentRole}, Final result: ${result}`);
    return result;
  } catch (error) {
    console.error('[USER] Error in hasRole method:', error);
    // Fall back to direct comparison for safety
    const result = Array.isArray(roles) 
      ? roles.includes(this.role)  // Check if array includes user's role
      : this.role === roles;       // Direct comparison for single role
    return result;
  }
};

// Helper method to detect if a method is being awaited
// This helps maintain backward compatibility with code expecting promises
userSchema.methods._isBeingAwaited = function() {
  // This method is no longer used but kept for backward compatibility
  console.warn('[USER] Deprecated _isBeingAwaited method called');
  return true; // Always assume awaited to encourage proper async usage
};

// Static method to find active users
userSchema.statics.findActive = function() {
  return this.find({ status: 'active' });
};

// Static method to find users by role
userSchema.statics.findByRole = function(role) {
  return this.find({ roles: role });
};

// Export model
const User = mongoose.model('User', userSchema);

module.exports = { User, getRoleEnum };

