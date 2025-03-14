const optimizationManagerMock = {
    // Add maps for tracking state
    optimizations: new Map(),
    messageQueues: new Map(),
    flushIntervals: new Map(),
    
    getSettings: jest.fn().mockResolvedValue({
        compressionEnabled: true,
        compressionLevel: 2
    }),
    handleBreakerOpen: jest.fn(),
    handleFailure: jest.fn(),
    handleServiceRecovery: jest.fn(),
    shouldOptimize: jest.fn().mockReturnValue(true),
    handleDatabaseLoad: jest.fn(),
    getOptimizations: jest.fn().mockReturnValue({
        compressionEnabled: true,
        compressionLevel: 2,
        poolMultiplier: 1.5
    }),
    getPoolMultiplier: jest.fn().mockReturnValue(1.5),
    cleanup: jest.fn().mockImplementation((venueId) => {
        optimizationManagerMock.messageQueues.delete(venueId);
        optimizationManagerMock.optimizations.delete(venueId);
        optimizationManagerMock.flushIntervals.delete(venueId);
    }),
    enableCompression: jest.fn().mockImplementation((venueId) => {
        if (!optimizationManagerMock.optimizations.has(venueId)) {
            optimizationManagerMock.optimizations.set(venueId, {});
        }
        const opts = optimizationManagerMock.optimizations.get(venueId);
        opts.compression = { enabled: true, level: 2 };
        return Promise.resolve();
    }),
    enableMessageBatching: jest.fn().mockImplementation((venueId) => {
        if (!optimizationManagerMock.optimizations.has(venueId)) {
            optimizationManagerMock.optimizations.set(venueId, {});
        }
        const opts = optimizationManagerMock.optimizations.get(venueId);
        opts.batching = { enabled: true, interval: 100 };
        
        if (!optimizationManagerMock.messageQueues.has(venueId)) {
            optimizationManagerMock.messageQueues.set(venueId, []);
        }
        return Promise.resolve();
    }),
    processMessage: jest.fn().mockResolvedValue({}),
    recordMetric: jest.fn()
};

// Reset all mocks helper
optimizationManagerMock.reset = () => {
    Object.values(optimizationManagerMock)
        .filter(value => typeof value === 'function' && value.mockReset)
        .forEach(mock => mock.mockReset());
    
    // Reset maps
    optimizationManagerMock.optimizations.clear();
    optimizationManagerMock.messageQueues.clear();
    optimizationManagerMock.flushIntervals.clear();
    
    // Reset default behaviors
    optimizationManagerMock.getSettings.mockResolvedValue({
        compressionEnabled: true,
        compressionLevel: 2
    });
    optimizationManagerMock.shouldOptimize.mockReturnValue(true);
    optimizationManagerMock.getOptimizations.mockReturnValue({
        compressionEnabled: true,
        compressionLevel: 2,
        poolMultiplier: 1.5
    });
    optimizationManagerMock.getPoolMultiplier.mockReturnValue(1.5);
    
    // Reset implementations
    optimizationManagerMock.cleanup.mockImplementation((venueId) => {
        optimizationManagerMock.messageQueues.delete(venueId);
        optimizationManagerMock.optimizations.delete(venueId);
        optimizationManagerMock.flushIntervals.delete(venueId);
    });
    
    optimizationManagerMock.enableCompression.mockImplementation((venueId) => {
        if (!optimizationManagerMock.optimizations.has(venueId)) {
            optimizationManagerMock.optimizations.set(venueId, {});
        }
        const opts = optimizationManagerMock.optimizations.get(venueId);
        opts.compression = { enabled: true, level: 2 };
        return Promise.resolve();
    });
    
    optimizationManagerMock.enableMessageBatching.mockImplementation((venueId) => {
        if (!optimizationManagerMock.optimizations.has(venueId)) {
            optimizationManagerMock.optimizations.set(venueId, {});
        }
        const opts = optimizationManagerMock.optimizations.get(venueId);
        opts.batching = { enabled: true, interval: 100 };
        
        if (!optimizationManagerMock.messageQueues.has(venueId)) {
            optimizationManagerMock.messageQueues.set(venueId, []);
        }
        return Promise.resolve();
    });
    
    optimizationManagerMock.processMessage.mockResolvedValue({});
};

module.exports = optimizationManagerMock; 