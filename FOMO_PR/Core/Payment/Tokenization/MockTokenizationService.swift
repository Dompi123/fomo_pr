import Foundation
import OSLog
import SwiftUI

extension Security {
    public class MockTokenizationService: TokenizationService {
        private let logger = Logger(subsystem: "com.fomo", category: "MockTokenizationService")
        
        public init() {
            logger.debug("Initializing MockTokenizationService")
        }
        public func tokenize(_ card: Card) async throws -> String {
            logger.debug("Mock tokenize called")
            return "mock_token"
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            logger.debug("Mock processPayment called with amount: \(amount)")
            return PaymentResult(
                id: "mock_payment_\(UUID().uuidString)",
                transactionId: "mock_transaction",
                amount: amount,
                status: .success
            )
        public func validatePaymentMethod() async throws -> Bool {
            logger.debug("Mock validatePaymentMethod called")
            return true
        public func fetchPricingTiers(for venueId: String) async throws -> [PricingTier] {
            logger.debug("Mock fetchPricingTiers called for venue: \(venueId)")
            return []
    }
} 
