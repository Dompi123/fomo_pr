const webSocketMonitorMock = {
    getVenueMetrics: jest.fn().mockResolvedValue({
        connections: 30,
        messageRate: 20
    }),
    trackVenue: jest.fn().mockImplementation(async (venueId) => {
        // Default "normal" state
        let result = {
            state: 'normal',
            connections: 100,
            messageRate: 5
        };
        
        // If the venue ID indicates a specific load scenario, return appropriate data
        if (venueId.includes('downtown-2')) {
            result = { 
                state: 'warning',
                connections: 175,
                messageRate: 15
            };
        } else if (venueId.includes('downtown-3')) {
            result = {
                state: 'critical',
                connections: 250,
                messageRate: 30
            };
        }
        
        return result;
    }),
    getMessageRate: jest.fn(),
    getOrderVelocity: jest.fn(),
    measureLatency: jest.fn(),
    shouldOptimize: jest.fn(),
    getVenueHistory: jest.fn(),
    recordMetric: jest.fn()
};

// Reset helper
webSocketMonitorMock.reset = function() {
    Object.values(this)
        .filter(value => typeof value === 'function' && value.mockReset)
        .forEach(mock => mock.mockReset());
    
    // Reset default behaviors
    this.getVenueMetrics.mockResolvedValue({
        connections: 30,
        messageRate: 20
    });
    
    // Reset trackVenue mock implementation
    this.trackVenue.mockImplementation(async (venueId) => {
        // Default "normal" state
        let result = {
            state: 'normal',
            connections: 100,
            messageRate: 5
        };
        
        // If the venue ID indicates a specific load scenario, return appropriate data
        if (venueId.includes('downtown-2')) {
            result = { 
                state: 'warning',
                connections: 175,
                messageRate: 15
            };
        } else if (venueId.includes('downtown-3')) {
            result = {
                state: 'critical',
                connections: 250,
                messageRate: 30
            };
        }
        
        return result;
    });
};

module.exports = webSocketMonitorMock; 