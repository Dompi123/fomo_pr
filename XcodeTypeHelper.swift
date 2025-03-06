import Foundation
import SwiftUI
import FOMO_PR  // Add import for FOMO_PR module

// This file helps Xcode recognize all the types in the project
// It doesn't actually do anything, but it helps with the module recognition

// MARK: - Type Definitions
// These are just empty type definitions to help Xcode recognize the types

#if XCODE_HELPER && !SWIFT_PACKAGE
// Card type
public struct Card: Identifiable {
    public let id: String
    public let last4: String
    public let brand: FOMO_PR.CardBrand
    public let expiryMonth: Int
    public let expiryYear: Int
    public let isDefault: Bool
    
    public init(id: String, last4: String, brand: FOMO_PR.CardBrand, expiryMonth: Int, expiryYear: Int, isDefault: Bool = false) {
        self.id = id
        self.last4 = last4
        self.brand = brand
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.isDefault = isDefault
    }
    
    // This is just a reference to the actual CardBrand enum in FOMO_PR
    public enum CardBrand: String {
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
    
    public static func == (lhs: PaymentResult, rhs: PaymentResult) -> Bool {
        lhs.id == rhs.id
    }
}

// PaymentStatus type
public enum PaymentStatus: Equatable {
    case success
    case failure(String)
    case pending
    
    public static func == (lhs: PaymentStatus, rhs: PaymentStatus) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success),
             (.pending, .pending):
            return true
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
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
        lhs.id == rhs.id
    }
}

// Note: TokenizationService and Security namespace are now defined in SecurityTypes.swift
#endif

// MARK: - Helper Function
// This function can be called to verify that all types are available
public func verifyXcodeTypes() {
    print("Xcode type helper is available!")
}
