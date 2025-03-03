import Foundation
import OSLog
import SwiftUI

extension Security {
    public final class MockTokenizationService: TokenizationService {
        public static let shared = MockTokenizationService()
        
        private let logger = Logger(subsystem: "com.fomo", category: "MockTokenizationService")
        
        public init() {
            logger.debug("Initializing MockTokenizationService")
        }
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            logger.debug("Mock tokenize called")
            return "tok_mock_\(UUID().uuidString)"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            logger.debug("Mock processPayment called with amount: \(amount)")
            return PaymentResult(
                id: "test_payment_id",
                transactionId: "test_transaction_id",
                amount: amount,
                timestamp: Date(),
                status: .success
            )
        }
        
        public func validatePaymentMethod() async throws -> Bool {
            logger.debug("Mock validatePaymentMethod called")
            return true
        }
        
        public func fetchPricingTiers(for venueId: String) async throws -> [PricingTier] {
            logger.debug("Mock fetchPricingTiers called for venue: \(venueId)")
            return [
                PricingTier(id: "mock_tier_1", name: "Mock Tier 1", price: 9.99, description: "Mock tier 1"),
                PricingTier(id: "mock_tier_2", name: "Mock Tier 2", price: 19.99, description: "Mock tier 2")
            ]
        }
    }
} 
