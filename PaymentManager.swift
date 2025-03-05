import Foundation
import SwiftUI

// MARK: - Payment Card Type
public struct PaymentCard: Identifiable, Codable {
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
        
        public var displayName: String {
            switch self {
            case .visa: return "Visa"
            case .mastercard: return "Mastercard"
            case .amex: return "American Express"
            case .discover: return "Discover"
            case .unknown: return "Card"
            }
        }
    }
    
    public var displayName: String {
        return "\(brand.displayName) •••• \(last4)"
    }
    
    public var expiryDisplay: String {
        return String(format: "%02d/%d", expiryMonth, expiryYear % 100)
    }
}

// MARK: - Payment Manager
// This file provides a single implementation of PaymentManager that uses our Security types

public class PaymentManager {
    public static let shared = PaymentManager()
    
    private let tokenizationService: TokenizationService
    
    public init(tokenizationService: TokenizationService = Security.LiveTokenizationService.shared) {
        self.tokenizationService = tokenizationService
    }
    
    // MARK: - Payment Methods
    
    public func addCard(cardNumber: String, expiry: String, cvc: String) async throws -> PaymentCard {
        let token = try await tokenizationService.tokenize(cardNumber: cardNumber, expiry: expiry, cvc: cvc)
        
        // In a real app, you would send this token to your server
        // For now, we'll just create a mock card
        let last4 = String(cardNumber.suffix(4))
        let brand = determineBrand(from: cardNumber)
        
        // Parse expiry (MM/YY)
        let components = expiry.split(separator: "/")
        let month = Int(components.first ?? "12") ?? 12
        let year = Int(components.last ?? "25") ?? 25
        
        return PaymentCard(
            id: token,
            last4: last4,
            brand: brand,
            expiryMonth: month,
            expiryYear: 2000 + year,
            isDefault: true
        )
    }
    
    public func processPayment(amount: Decimal, cardId: String) async throws -> PaymentResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Simulate success or failure
        let isSuccess = Bool.random()
        
        if isSuccess {
            return PaymentResult(
                id: "payment_\(UUID().uuidString)",
                amount: amount,
                status: .success,
                timestamp: Date()
            )
        } else {
            throw PaymentError.paymentFailed
        }
    }
    
    // MARK: - Helper Methods
    
    private func determineBrand(from cardNumber: String) -> PaymentCard.CardBrand {
        // Very simplified brand detection
        if cardNumber.hasPrefix("4") {
            return .visa
        } else if cardNumber.hasPrefix("5") {
            return .mastercard
        } else if cardNumber.hasPrefix("3") {
            return .amex
        } else if cardNumber.hasPrefix("6") {
            return .discover
        } else {
            return .unknown
        }
    }
}

// MARK: - Helper Function
// This function can be called to verify that the PaymentManager is available
public func verifyPaymentManager() {
    print("PaymentManager is available: \(PaymentManager.self)")
}

// MARK: - Payment Result
public struct PaymentResult: Identifiable {
    public let id: String
    public let amount: Decimal
    public let status: PaymentStatus
    public let timestamp: Date
    
    public enum PaymentStatus: String {
        case success
        case pending
        case failed
    }
}

// MARK: - Payment Error
public enum PaymentError: Error {
    case invalidCard
    case insufficientFunds
    case paymentFailed
    case networkError
    
    public var localizedDescription: String {
        switch self {
        case .invalidCard:
            return "The card information is invalid."
        case .insufficientFunds:
            return "The card has insufficient funds."
        case .paymentFailed:
            return "The payment could not be processed."
        case .networkError:
            return "A network error occurred. Please try again."
        }
    }
}
