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

// PaymentResult to match the TokenizationService protocol
public struct PaymentResult {
    public let transactionId: String
    public let amount: Decimal
    public let status: PaymentStatus
    
    public init(transactionId: String, amount: Decimal, status: PaymentStatus) {
        self.transactionId = transactionId
        self.amount = amount
        self.status = status
    }
}

// Payment status enum
public enum PaymentStatus {
    case success
    case failed(String)
    case pending
}

// Rename to FOMOPaymentResult to avoid ambiguity
public struct FOMOPaymentResult {
    public let id: String
    public let transactionId: String
    public let amount: Decimal
    public let status: FOMOPaymentStatus
    
    public init(id: String, transactionId: String, amount: Decimal, status: FOMOPaymentStatus) {
        self.id = id
        self.transactionId = transactionId
        self.amount = amount
        self.status = status
    }
    
    // Convert from PaymentResult
    public init(id: String, from paymentResult: PaymentResult) {
        self.id = id
        self.transactionId = paymentResult.transactionId
        self.amount = paymentResult.amount
        
        switch paymentResult.status {
        case .success:
            self.status = .success
        case .failure(let message):
            self.status = .failed(message)
        case .pending:
            self.status = .pending
        }
    }
    
    public enum FOMOPaymentStatus {
        case success
        case failed(String)
        case pending
    }
}

@MainActor
public class PaymentManager: ObservableObject {
    private let tokenizationService: Security.TokenizationService
    private let logger = Logger(subsystem: "com.fomo", category: "PaymentManager")
    
    public init(tokenizationService: Security.TokenizationService? = nil) async {
        if let service = tokenizationService {
            self.tokenizationService = service
        } else {
            self.tokenizationService = await Security.LiveTokenizationService()
        }
    }
    
    public static func create() async -> PaymentManager {
        let service = await Security.LiveTokenizationService()
        return await PaymentManager(tokenizationService: service)
    }
    
    public static func createMock() async -> PaymentManager {
        return await PaymentManager(tokenizationService: Security.MockTokenizationService())
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
            let fomoResult = FOMOPaymentResult(id: UUID().uuidString, from: result)
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
            return try await tokenizationService.validatePaymentMethod()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    public func fetchPricingTiers(for venueId: String) async throws -> [PricingTier] {
        do {
            return try await tokenizationService.fetchPricingTiers(for: venueId)
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
        let service = Security.MockTokenizationService()
        let manager = Task {
            await PaymentManager(tokenizationService: service)
        }
        return try! manager.value
    }
}
#endif 