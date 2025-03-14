/**
 * Auth0 Service
 * 
 * This service provides an interface to the Auth0 Management API.
 */

const BaseService = require('../../utils/baseService.cjs');
const logger = require('../../utils/logger.cjs');
const { config } = require('../../config/environment.cjs');
const { createError, ERROR_CODES } = require('../../utils/errors.cjs');
const { ManagementClient, AuthenticationClient } = require('auth0');

// Maintain singleton for backward compatibility
let instance = null;

class Auth0Service extends BaseService {
    constructor() {
        // Return existing instance if already created
        if (instance) {
            return instance;
        }

        super('auth0-service');
        
        this.config = {
            domain: config.auth0?.domain || process.env.AUTH0_DOMAIN,
            clientId: config.auth0?.clientId || process.env.AUTH0_CLIENT_ID,
            clientSecret: config.auth0?.clientSecret || process.env.AUTH0_CLIENT_SECRET,
            audience: config.auth0?.audience || process.env.AUTH0_AUDIENCE,
            connection: 'Username-Password-Authentication'
        };

        instance = this;
    }

    async _init() {
        try {
            // Initialize Auth0 Management API client
            this.managementClient = new ManagementClient({
                domain: this.config.domain,
                clientId: this.config.clientId,
                clientSecret: this.config.clientSecret,
                audience: `https://${this.config.domain}/api/v2/`,
                scope: 'read:users update:users create:users'
            });
            
            // Initialize Auth0 Authentication API client
            this.authClient = new AuthenticationClient({
                domain: this.config.domain,
                clientId: this.config.clientId
            });
            
            this.ready = true;
            this.logger.info('Auth0 service initialized successfully');
        } catch (error) {
            this.logger.error('Auth0 service initialization failed:', error);
            throw error;
        }
    }

    /**
     * Get user by ID
     * @param {string} userId Auth0 user ID
     * @returns {Promise<Object>} User data
     */
    async getUserById(userId) {
        await this.ensureReady();
        
        try {
            return await this.managementClient.users.get({ id: userId });
        } catch (error) {
            this.logger.error(`Failed to get user ${userId}:`, error);
            throw createError(ERROR_CODES.USER_NOT_FOUND, 'User not found', error);
        }
    }

    /**
     * Get user by email
     * @param {string} email User email
     * @returns {Promise<Object>} User data
     */
    async getUserByEmail(email) {
        await this.ensureReady();
        
        try {
            const users = await this.managementClient.users.getAll({
                q: `email:"${email}"`,
                search_engine: 'v3'
            });
            
            if (users && users.length > 0) {
                return users[0];
            }
            
            return null;
        } catch (error) {
            this.logger.error(`Failed to get user by email ${email}:`, error);
            throw createError(ERROR_CODES.USER_NOT_FOUND, 'User not found', error);
        }
    }

    /**
     * Create a new user
     * @param {Object} userData User data
     * @returns {Promise<Object>} Created user
     */
    async createUser(userData) {
        await this.ensureReady();
        
        try {
            return await this.managementClient.users.create({
                email: userData.email,
                password: userData.password,
                name: userData.name,
                connection: this.config.connection,
                email_verified: userData.emailVerified || false,
                app_metadata: userData.appMetadata || {},
                user_metadata: userData.userMetadata || {}
            });
        } catch (error) {
            this.logger.error('Failed to create user:', error);
            throw createError(ERROR_CODES.USER_CREATION_FAILED, 'Failed to create user', error);
        }
    }

    /**
     * Update a user
     * @param {string} userId Auth0 user ID
     * @param {Object} updates User data updates
     * @returns {Promise<Object>} Updated user
     */
    async updateUser(userId, updates) {
        await this.ensureReady();
        
        try {
            return await this.managementClient.users.update({ id: userId }, updates);
        } catch (error) {
            this.logger.error(`Failed to update user ${userId}:`, error);
            throw createError(ERROR_CODES.USER_UPDATE_FAILED, 'Failed to update user', error);
        }
    }

    /**
     * Get user roles
     * @param {string} userId Auth0 user ID
     * @returns {Promise<Array>} User roles
     */
    async getUserRoles(userId) {
        await this.ensureReady();
        
        try {
            return await this.managementClient.users.getRoles({ id: userId });
        } catch (error) {
            this.logger.error(`Failed to get roles for user ${userId}:`, error);
            throw createError(ERROR_CODES.ROLES_RETRIEVAL_FAILED, 'Failed to get user roles', error);
        }
    }

    /**
     * Assign roles to a user
     * @param {string} userId Auth0 user ID
     * @param {Array<string>} roleIds Role IDs to assign
     * @returns {Promise<void>}
     */
    async assignRolesToUser(userId, roleIds) {
        await this.ensureReady();
        
        try {
            await this.managementClient.users.assignRoles({ id: userId }, { roles: roleIds });
        } catch (error) {
            this.logger.error(`Failed to assign roles to user ${userId}:`, error);
            throw createError(ERROR_CODES.ROLE_ASSIGNMENT_FAILED, 'Failed to assign roles', error);
        }
    }
}

module.exports = new Auth0Service(); 