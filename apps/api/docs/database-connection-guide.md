# MongoDB Connection Manager Guide

## Overview

This document explains the MongoDB Connection Manager implementation that was added to resolve database connection issues in tests and improve connection management throughout the application.

## Problem Solved

The application was experiencing the following error during test runs:

```
MongooseError: Can't call `openUri()` on an active connection with different connection strings
```

This occurred because:
1. The application was trying to connect to the standard MongoDB database
2. Tests were simultaneously trying to connect to an in-memory test database
3. Mongoose maintains a singleton connection, causing conflicts

## Solution Implemented

We've implemented a singleton MongoDB Connection Manager that:
- Centralizes all database connections through a single manager
- Supports both regular database connections and in-memory test connections
- Properly handles connection lifecycle (connect, disconnect, cleanup)
- Provides diagnostics and status information
- Implements proper error handling and recovery

## How to Use

### Application Code

The application code doesn't need any changes. The existing database access will work through the connection manager automatically.

```javascript
// This will continue to work as before
const connectDB = require('./config/database.cjs').connectDB;
await connectDB();
```

### Test Code

In test code, you should use the connection manager directly:

```javascript
const dbConnectionManager = require('../utils/dbConnectionManager.cjs');

// Connect to test database
await dbConnectionManager.connect();

// Run your tests...

// Clear database between tests
await dbConnectionManager.clearDatabase();

// Disconnect when done
await dbConnectionManager.disconnect();
```

### Environment Configuration

The connection manager uses the following environment variables:

- `NODE_ENV`: Set to 'test' for test environment
- `USE_MEMORY_DB`: Set to 'true' to use in-memory database for tests
- `MONGODB_URI`: The MongoDB connection string

For tests, use:

```
NODE_ENV=test
USE_MEMORY_DB=true
MONGODB_URI=mongodb://localhost:27017/fomo_test
```

## Implementation Details

### Files Modified

1. **New Files:**
   - `utils/dbConnectionManager.cjs` - The main connection manager implementation

2. **Modified Files:**
   - `config/database.cjs` - Updated to use the connection manager
   - `test/helpers/testSetup.cjs` - Updated to use the connection manager
   - `test/config/setupAfterEnv.cjs` - Updated to use the connection manager
   - `test/config/setup.cjs` - Updated to use the connection manager
   - `.env.test` - Added USE_MEMORY_DB flag

### Key Design Patterns

1. **Singleton Pattern:** The connection manager is implemented as a singleton to ensure only one active connection.

2. **State Management:** The manager tracks connection state (connecting, connected, disconnected) for better error handling.

3. **Environment Detection:** The manager automatically detects test environments and adapts accordingly.

4. **Diagnostic Tools:** Built-in diagnostics helps troubleshoot connection issues.

## Advanced Usage

### Getting Connection Diagnostics

```javascript
const dbConnectionManager = require('../utils/dbConnectionManager.cjs');
const diagnostics = dbConnectionManager.getDiagnostics();
console.log('Connection state:', diagnostics);
```

### Checking Connection State

```javascript
const dbConnectionManager = require('../utils/dbConnectionManager.cjs');
const state = dbConnectionManager.getConnectionState();
// Returns: 'connected', 'connecting', 'disconnected', or 'disconnecting'
```

## Troubleshooting

If you encounter connection issues:

1. Check that you're not calling `mongoose.connect()` directly anywhere in your code.
2. Verify your environment variables are set correctly.
3. Use `dbConnectionManager.getDiagnostics()` to troubleshoot connection status.
4. Ensure proper disconnection after tests complete.

## Migration Guidelines

If you're creating new tests:

1. Import and use the connection manager instead of connecting directly.
2. Ensure proper cleanup with `clearDatabase()` and `disconnect()`.
3. Set the appropriate environment variables.

This implementation follows best practices used by top engineering teams for managing database connections in Node.js applications with Mongoose. 