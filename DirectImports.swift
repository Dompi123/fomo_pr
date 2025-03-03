import Foundation
import SwiftUI

// This file directly imports all the types needed in your app
// without relying on module imports

// MARK: - Type Aliases
// These type aliases ensure that the types are available even if the module import fails

#if !SWIFT_PACKAGE
// These types are already defined in FOMOTypes.swift
// No need to redefine them here
#else
// When building with Swift Package Manager, we need to define empty types
// since the real types aren't available in SPM mode

// Card type
public struct Card: Identifiable {
    public let id: String
    public let last4: String
    public let brand: CardBrand
    public let expiryMonth: Int
    public let expiryYear: Int
    public let isDefault: Bool
    
    public init(id: String, last4: String, brand: CardBrand, expiryMonth: Int, expiryYear: Int, isDefault: Bool = false) {
        self.id = id
        self.last4 = last4
        self.brand = brand
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.isDefault = isDefault
    }
    
    public enum CardBrand: String, Codable {
        case visa
        case mastercard
        case amex
        case discover
        case unknown
    }
}

// APIClient type
public actor APIClient {
    public static let shared = APIClient()
    
    public init() {}
}

// TokenizationService protocol
public protocol TokenizationService {
    func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String
    func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult
}

// PaymentResult type
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

// PaymentStatus type
public enum PaymentStatus: Equatable {
    case success
    case failure(String)
    case pending
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
}

// FOMOSecurity namespace (renamed from Security to avoid conflicts)
public enum FOMOSecurity {
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
}
#endif

// MARK: - Direct Import Function
// This function can be called to verify that all types are directly available
public func verifyDirectImports() {
    print("Direct imports are available!")
    
    #if !SWIFT_PACKAGE
    // Verify that the types are available
    let _ = Card(id: "test", last4: "1234", brand: Card.CardBrand.visa, expiryMonth: 12, expiryYear: 2025)
    let _ = APIClient.shared
    // Commenting out FOMOSecurity reference as it's not available
    // let _ = FOMOSecurity.LiveTokenizationService.shared
    let _ = PaymentResult(transactionId: "test", amount: 10.0, status: PaymentStatus.success)
    let _ = PricingTier(id: "test", name: "Test", price: 10.0, description: "Test")
    #endif
} 