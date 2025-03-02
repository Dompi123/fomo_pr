import Foundation
import SwiftUI
import OSLog

// Define the required types that were previously imported from Models
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

// Rename to FOMOPaymentResult to avoid ambiguity
public struct FOMOPaymentResult {
    public let id: String
    public let transactionId: String
    public let amount: Decimal
    public let status: PaymentStatus
    
    public init(id: String, transactionId: String, amount: Decimal, status: PaymentStatus) {
        self.id = id
        self.transactionId = transactionId
        self.amount = amount
        self.status = status
    }
    
    public enum PaymentStatus {
        case success
        case failed(String)
        case pending
    }
}

@MainActor
public class PaymentManager: ObservableObject {
    private let tokenizationService: FOMOSecurity.LiveTokenizationService
    private let logger = Logger(subsystem: "com.fomo", category: "PaymentManager")
    
    public init(tokenizationService: FOMOSecurity.LiveTokenizationService? = nil) async {
        if let service = tokenizationService {
            self.tokenizationService = service
        } else {
            self.tokenizationService = FOMOSecurity.LiveTokenizationService.shared
        }
    }
    
    public static func create() async -> PaymentManager {
        let service = FOMOSecurity.LiveTokenizationService.shared
        return await PaymentManager(tokenizationService: service)
    }
    
    public static func createMock() async -> PaymentManager {
        return await PaymentManager(tokenizationService: FOMOSecurity.LiveTokenizationService.shared)
    }
    
    @Published public private(set) var isProcessing = false
    @Published public private(set) var lastPaymentResult: FOMOPaymentResult?
    @Published public private(set) var showError = false
    @Published public private(set) var errorMessage = ""
    
    public func processPayment(amount: Decimal, tier: PricingTier) async throws -> FOMOPaymentResult {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let result = try await tokenizationService.processPayment(amount: amount, tier: tier)
            let fomoResult = FOMOPaymentResult(
                id: UUID().uuidString,
                transactionId: result.transactionId,
                amount: amount,
                status: .success
            )
            lastPaymentResult = fomoResult
            return fomoResult
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    public func validatePaymentMethod() async throws -> Bool {
        do {
            // Simulate validation since the method doesn't exist in TokenizationService
            return true
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    public func fetchPricingTiers(for venueId: String) async throws -> [PricingTier] {
        do {
            // Simulate fetching pricing tiers
            return [
                PricingTier(id: "1", name: "Basic", price: 9.99, description: "Basic tier"),
                PricingTier(id: "2", name: "Premium", price: 19.99, description: "Premium tier"),
                PricingTier(id: "3", name: "VIP", price: 49.99, description: "VIP tier")
            ]
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            throw error
        }
    }
}

#if DEBUG
public extension PaymentManager {
    static var preview: PaymentManager {
        let service = FOMOSecurity.LiveTokenizationService.shared
        let manager = Task {
            await PaymentManager(tokenizationService: service)
        }
        return try! manager.value
    }
}
#endif 