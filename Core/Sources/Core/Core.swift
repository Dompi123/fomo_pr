import Foundation
import Models
import Network

public enum Security {
    public class LiveTokenizationService {
        public static let shared = LiveTokenizationService()
        
        public init() {}
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            // In a real app, this would call a payment processor API
            // For now, we'll just return a mock token
            return "tok_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            // In a real app, this would call a payment processor API
            // For now, we'll just return a successful result
            return PaymentResult(
                success: true,
                transactionId: "txn_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))",
                amount: amount,
                date: Date()
            )
        }
    }
    
    public class MockTokenizationService {
        public static let shared = MockTokenizationService()
        
        public init() {}
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            return "tok_mock_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            return PaymentResult(
                success: true,
                transactionId: "txn_mock_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))",
                amount: amount,
                date: Date()
            )
        }
    }
}

public protocol TokenizationService {
    func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String
    func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult
}

extension Security.LiveTokenizationService: TokenizationService {}
extension Security.MockTokenizationService: TokenizationService {}

public struct PaymentResult {
    public let success: Bool
    public let transactionId: String
    public let amount: Decimal
    public let date: Date
    
    public init(success: Bool, transactionId: String, amount: Decimal, date: Date) {
        self.success = success
        self.transactionId = transactionId
        self.amount = amount
        self.date = date
    }
}
