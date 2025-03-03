import Foundation
import SwiftUI

// MARK: - PaymentManager
// This file provides a single implementation of PaymentManager that uses our Security types

public class PaymentManager {
    public static let shared = PaymentManager()
    
    private let tokenizationService: TokenizationService
    
    public init(tokenizationService: TokenizationService = Security.LiveTokenizationService.shared) {
        self.tokenizationService = tokenizationService
    }
    
    // MARK: - Payment Methods
    
    public func addCard(cardNumber: String, expiry: String, cvc: String) async throws -> Card {
        let token = try await tokenizationService.tokenize(cardNumber: cardNumber, expiry: expiry, cvc: cvc)
        
        // In a real app, you would send this token to your server
        // For now, we'll just create a mock card
        let last4 = String(cardNumber.suffix(4))
        let brand = determineBrand(from: cardNumber)
        
        // Parse expiry (MM/YY)
        let components = expiry.split(separator: "/")
        let month = Int(components.first ?? "12") ?? 12
        let year = Int(components.last ?? "25") ?? 25
        
        return Card(
            id: token,
            last4: last4,
            brand: brand,
            expiryMonth: month,
            expiryYear: 2000 + year,
            isDefault: true
        )
    }
    
    public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
        return try await tokenizationService.processPayment(amount: amount, tier: tier)
    }
    
    // MARK: - Helper Methods
    
    private func determineBrand(from cardNumber: String) -> Card.CardBrand {
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
