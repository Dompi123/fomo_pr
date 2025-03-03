const jwt = require('jsonwebtoken');
const { User } = require('../models/User.cjs');
const { USER_ROLES } = require('./constants.cjs');
const featureManager = require('../services/payment/FeatureManager.cjs');

// Get user from socket
const getUserFromSocket = async (socket) => {
    try {
        const token = socket.handshake.auth.token;
        if (!token) return null;

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        return await User.findById(decoded.userId);
    } catch (err) {
        return null;
    }
};

// Check if user is staff member
const isStaffMember = async (socket, venueId) => {
    const user = await getUserFromSocket(socket);
    if (!user) return false;

    return user.hasRole([USER_ROLES.STAFF, USER_ROLES.OWNER]);
};

/**
 * Check if user has access to a venue (admin or venue owner)
 * @param {Object} user - User object
 * @param {String} venueId - Venue ID
 * @returns {Boolean} - Whether user has access to venue
 */
const isVenueStaff = (user, venueId) => {
    if (!user) return false;
    
    // Admin has access to all venues
    if (user.hasRole(USER_ROLES.ADMIN)) return true;
    
    // Check if user is owner of the venue
    if (user.hasRole(USER_ROLES.OWNER) && 
        user.managedVenues && 
        user.managedVenues.some(id => id.toString() === venueId.toString())) {
        return true;
    }
    
    // Check if user is staff
    if (user.hasRole(USER_ROLES.STAFF) && 
        user.assignedVenues && 
        user.assignedVenues.some(id => id.toString() === venueId.toString())) {
        return true;
    }
    
    return false;
};

module.exports = {
    getUserFromSocket,
    isStaffMember,
    isVenueStaff
}; 