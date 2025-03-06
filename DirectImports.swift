import Foundation
import SwiftUI

// This file directly imports all the types needed in your app
// without relying on module imports

// MARK: - Type Aliases
// These type aliases ensure that the types are available even if the module import fails

#if !SWIFT_PACKAGE
// Import the CoreModels directly by including the file path
// Removing problematic import: import "FOMO_PR/Models/CoreModels.swift"

// Instead, we'll directly reference the types defined in CoreModels.swift
// PricingTier is defined in CoreModels.swift
#else
// When building with Swift Package Manager, we need to define empty types
// since the real types aren't available in SPM mode

// MARK: - Card Type
struct Card: Identifiable, Hashable {
    let id: String
    let number: String
    let expiryMonth: Int
    let expiryYear: Int
    let cvv: String
    let lastFour: String
    
    init(id: String = UUID().uuidString, 
         number: String, 
         expiryMonth: Int, 
         expiryYear: Int, 
         cvv: String) {
        self.id = id
        self.number = number
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cvv = cvv
        self.lastFour = String(number.suffix(4))
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - API Client
class APIClient {
    static let shared = APIClient()
    
    func fetch<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        // Mock implementation
        completion(.failure(NSError(domain: "APIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])))
    }
}

// MARK: - TokenizationService
protocol TokenizationService {
    func tokenize(card: Card) -> String
}

// MARK: - Payment Types
public enum PaymentStatus: String, Equatable {
    case pending
    case completed
    case failed
    case refunded
}

struct PaymentResult {
    let id: String
    let transactionId: String
    let status: PaymentStatus
    let amount: Decimal
    let timestamp: Date
    let errorMessage: String?
    
    init(
        id: String = UUID().uuidString,
        transactionId: String,
        status: PaymentStatus,
        amount: Decimal,
        timestamp: Date = Date(),
        errorMessage: String? = nil
    ) {
        self.id = id
        self.transactionId = transactionId
        self.status = status
        self.amount = amount
        self.timestamp = timestamp
        self.errorMessage = errorMessage
    }
}

// MARK: - Type Verification
func verifyDirectImports() {
    // Create a Card instance
    let card = Card(
        number: "4242424242424242",
        expiryMonth: 12,
        expiryYear: 2025,
        cvv: "123"
    )
    print("Card is available: \(card)")
    
    // Create an APIClient instance
    let apiClient = APIClient.shared
    print("APIClient is available: \(apiClient)")
    
    #if PREVIEW_MODE
    // In preview mode, use the FOMOSecurity namespace
    let tokenizationService = FOMOSecurity.LiveTokenizationService.shared
    print("TokenizationService is available: \(tokenizationService)")
    
    // Create a PaymentResult instance
    let paymentResult = PaymentResult(
        status: .completed,
        transactionId: "txn_123456",
        amount: 100.00,
        timestamp: Date()
    )
    print("PaymentResult is available: \(paymentResult)")
    #endif
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
public enum PaymentStatus: String, Equatable {
    case success
    case failure
    case pending
    case refunded
}

// PricingTier is now defined in FOMOApp.swift to avoid duplicate definitions

// FOMOSecurity namespace (renamed from Security to avoid conflicts)
public enum FOMOSecurity {
    public final class LiveTokenizationService: TokenizationService {
        public static let shared = LiveTokenizationService()
        
        public init() {}
        
        public func tokenize(card: Card) -> String {
            return "mock_token"
        }
    }
}
#endif 
