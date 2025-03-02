import Foundation

public protocol PaymentServiceProtocol {
    func processPayment(for tier: PricingTier) async throws -> FOMOPaymentResult
    func validatePayment(_ payment: FOMOPaymentResult) async throws -> Bool
    func fetchPricingTiers(for venueId: String) async throws -> [PricingTier]
} 