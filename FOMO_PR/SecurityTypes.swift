import Foundation
import SwiftUI

// MARK: - FOMOSecurity Namespace and TokenizationService
// This file provides a single source of truth for FOMOSecurity and TokenizationService types

// TokenizationService protocol
public protocol TokenizationService {
    func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String
    func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult
}

// FOMOSecurity namespace (renamed from Security to avoid collision with Apple's Security framework)
public enum FOMOSecurity {
    // LiveTokenizationService implementation
    public final class LiveTokenizationService: TokenizationService {
        public static let shared = LiveTokenizationService()
        
        public init() {}
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            return "mock_token"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            return PaymentResult(
                transactionId: "mock_transaction",
                amount: amount,
                status: .success
            )
        }
    }
    
    // MockTokenizationService implementation
    public final class MockTokenizationService: TokenizationService {
        public static let shared = MockTokenizationService()
        
        public init() {}
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            return "mock_token_test"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            return PaymentResult(
                transactionId: "mock_transaction_test",
                amount: amount,
                status: .success
            )
        }
    }
}

// MARK: - Helper Function
// This function can be called to verify that the FOMOSecurity types are available
public func verifySecurityTypes() {
    print("FOMOSecurity namespace is available!")
    print("LiveTokenizationService is available: \(FOMOSecurity.LiveTokenizationService.self)")
    print("MockTokenizationService is available: \(FOMOSecurity.MockTokenizationService.self)")
}
