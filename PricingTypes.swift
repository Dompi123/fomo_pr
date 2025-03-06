import Foundation
import SwiftUI

#if PREVIEW_MODE && !SWIFT_PACKAGE
// Only define PricingTier in preview mode if it's not already defined in the main app
// This ensures we don't have duplicate definitions

// Import PricingTier from FOMOApp.swift instead of redefining it here
// The PricingTier struct is now defined in FOMOApp.swift

// Helper extension to get features for a tier
public extension PricingTier {
    static func features(for tier: PricingTier) -> [String] {
        switch tier.id {
        case "tier-123":
            return ["Entry to venue", "One welcome drink", "Access to main areas"]
        case "tier-456":
            return ["Priority entry", "Open bar for 2 hours", "Access to VIP areas", "Meet & greet with performers"]
        default:
            return ["Standard venue access"]
        }
    }
    
    #if DEBUG
    static var mockTier: PricingTier {
        PricingTier(
            id: "tier-123",
            name: "Standard Pass",
            price: 19.99,
            description: "Standard entry pass with basic benefits"
        )
    }
    
    static var mockTiers: [PricingTier] {
        [
            PricingTier(
                id: "tier-123",
                name: "Standard Pass",
                price: 19.99,
                description: "Standard entry pass with basic benefits"
            ),
            PricingTier(
                id: "tier-456",
                name: "VIP Pass",
                price: 49.99,
                description: "VIP entry pass with premium benefits"
            )
        ]
    }
    #endif
}

// Define PaymentResult and PaymentStatus types
public enum PaymentStatus: String, Codable {
    case pending
    case completed
    case failed
    case refunded
}

public struct PaymentResult: Identifiable, Codable {
    public let id: String
    public let status: PaymentStatus
    public let amount: Decimal
    public let timestamp: Date
    public let description: String
    
    public init(id: String, status: PaymentStatus, amount: Decimal, timestamp: Date = Date(), description: String) {
        self.id = id
        self.status = status
        self.amount = amount
        self.timestamp = timestamp
        self.description = description
    }
    
    #if DEBUG
    public static var mockPaymentResult: PaymentResult {
        PaymentResult(
            id: "payment-123",
            status: .completed,
            amount: 19.99,
            description: "Payment for Standard Pass"
        )
    }
    #endif
}
#endif

// Verify that pricing types are available
func verifyPricingTypes() {
    #if PREVIEW_MODE
    print("PricingTier is available in preview mode")
    print("Sample tier: \(PricingTier.mockTier)")
    print("PaymentResult is available in preview mode")
    print("Sample payment: \(PaymentResult.mockPaymentResult)")
    #else
    print("Using production Pricing module")
    #endif
} 