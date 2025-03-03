import Foundation

public protocol PaymentServiceProtocol {
    func processPayment(for tier: PricingTier) async throws -> PaymentResult
    func validatePayment(_ payment: PaymentResult) async throws -> Bool
    func fetchPricingTiers(for venueId: String) async throws -> [PricingTier]
} 