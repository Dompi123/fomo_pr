const mongoose = require('mongoose');

const orderMetricsSchema = new mongoose.Schema({
    orderId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Order',
        required: true
    },
    venueId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Venue',
        required: true
    },
    verifiedBy: {
        type: String,
        enum: ['staff', 'system', 'customer'],
        default: 'system'
    },
    eventType: {
        type: String,
        enum: ['creation', 'status_change', 'verification', 'completion'],
        required: true
    },
    orderType: {
        type: String,
        enum: ['drink', 'pass'],
        required: true
    },
    timestamp: {
        type: Date,
        default: Date.now
    },
    processingTime: {
        type: Number,  // in milliseconds
        required: true
    },
    revenue: {
        amount: Number,
        currency: { type: String, default: 'USD' },
        subtotal: Number,
        serviceFee: Number,
        tipAmount: Number,
        total: Number
    },
    items: [{
        name: String,
        quantity: Number,
        price: Number
    }],
    metadata: {
        fromStatus: String,
        toStatus: String,
        itemCount: Number,
        verificationAttempts: Number,
        error: String,
        drinkTypes: [{
            category: String,
            count: Number,
            revenue: Number
        }],
        passTier: {
            name: String,
            price: Number
        },
        peakHourFactor: Number,
        specialEvent: String,
        avgPrice: Number,
        serviceFeePercent: Number,
        tipPercentage: Number,
        redemptionStatus: {
            isRedeemed: { type: Boolean, default: false },
            redeemedAt: Date,
            redeemedBy: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'User'
            }
        },
        uniqueCustomerId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User'
        },
        verificationMethod: String,
        updatedByRole: String
    }
});

// Indexes for efficient querying
orderMetricsSchema.index({ venueId: 1, timestamp: -1 });
orderMetricsSchema.index({ verifiedBy: 1, timestamp: -1 });
orderMetricsSchema.index({ orderId: 1, eventType: 1 });

module.exports = mongoose.model('OrderMetrics', orderMetricsSchema); 