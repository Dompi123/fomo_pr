import Foundation
import Models

#if DEBUG
extension Security {
    public final class MockTokenizationService: TokenizationService {
        public static let shared = MockTokenizationService()
        
        public init() {}
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            return "tok_mock_\(UUID().uuidString)"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            return PaymentResult(
                id: "test_payment_id",
                transactionId: "test_transaction_id",
                amount: amount,
                timestamp: Date(),
                status: .success
            )
        }
        
        public func validatePaymentMethod() async throws -> Bool {
            return true
        }
        
        public func fetchPricingTiers(for venueId: String) async throws -> [PricingTier] {
            return [
                PricingTier(id: "mock_tier_1", name: "Mock Tier 1", price: 9.99, description: "Mock tier 1"),
                PricingTier(id: "mock_tier_2", name: "Mock Tier 2", price: 19.99, description: "Mock tier 2")
            ]
        }
    }
}
#endif 