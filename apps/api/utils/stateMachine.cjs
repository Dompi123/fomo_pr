const OrderStateMachine = {
    placed: {
        allowedTransitions: ['verified'],
        validate: async (order) => {
            // Validate required fields present
            if (!order.items || !order.venueId || !order.userId) {
                throw new Error('Missing required fields');
            }
        }
    },
    verified: {
        allowedTransitions: ['completed'],
        validate: async (order) => {
            // Verify staff validation exists
            if (!order.verification?.verifiedAt) {
                throw new Error('Missing verification');
            }
        }
    },
    completed: {
        allowedTransitions: [],
        validate: async (order) => {
            // Ensure payment completed
            if (order.type === 'drink' && !order.tipAmount) {
                throw new Error('Missing tip amount');
            }
        }
    }
};
