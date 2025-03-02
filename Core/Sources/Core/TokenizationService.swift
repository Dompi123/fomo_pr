import Foundation
import Models

// Define the TokenizationService protocol in the Core module
public protocol TokenizationService {
    func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String
    func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult
    func validatePaymentMethod() async throws -> Bool
    func fetchPricingTiers(for venueId: String) async throws -> [PricingTier]
}

// Define the PricingTier type if it's not already defined in Models
public struct PricingTier: Identifiable, Equatable, Codable {
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

// Log function to help with debugging
public func logTokenizationServiceAvailability() {
    print("TokenizationService protocol is available in Core module: \(TokenizationService.self)")
    print("PricingTier type is available in Core module: \(PricingTier.self)")
} 