import Foundation

// This file provides a local implementation of the Security namespace
public enum Security {
    public protocol TokenizationService {
        func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String
        func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult
    }
    
    public final class LiveTokenizationService: TokenizationService {
        public static let shared = LiveTokenizationService()
        
        public init() {}
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            // Simulate tokenization
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return "tok_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            // Simulate payment processing
            try await Task.sleep(nanoseconds: 1_500_000_000)
            return PaymentResult(
                transactionId: "txn_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))",
                amount: amount,
                status: .success
            )
        }
    }
    
    public final class MockTokenizationService: TokenizationService {
        public static let shared = MockTokenizationService()
        
        public init() {}
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            // Return a mock token immediately without delay
            return "mock_tok_\(UUID().uuidString.prefix(8))"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            // Return a mock payment result immediately without delay
            return PaymentResult(
                transactionId: "mock_txn_\(UUID().uuidString.prefix(8))",
                amount: amount,
                status: .success
            )
        }
    }
    
    public struct PaymentResult: Equatable {
        public let id: String
        public let transactionId: String
        public let amount: Decimal
        public let timestamp: Date
        public let status: PaymentStatus
        
        public init(id: String = UUID().uuidString,
                    transactionId: String,
                    amount: Decimal,
                    timestamp: Date = Date(),
                    status: PaymentStatus) {
            self.id = id
            self.transactionId = transactionId
            self.amount = amount
            self.timestamp = timestamp
            self.status = status
        }
    }
    
    public enum PaymentStatus: Equatable {
        case success
        case failure(String)
        case pending
    }
}

// PricingTier type
public struct PricingTier: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let price: Decimal
    public let description: String
    
    public init(id: String, name: String, price: Decimal, description: String) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
    }
    
    public static func == (lhs: PricingTier, rhs: PricingTier) -> Bool {
        return lhs.id == rhs.id
    }
} 