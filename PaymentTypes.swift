import Foundation
import SwiftUI

// MARK: - Payment Types
public enum PaymentStatus: String, Equatable, Codable {
    case pending
    case completed
    case failed
    case refunded
}

// MARK: - Payment Result
public struct PaymentResult: Identifiable, Codable, Equatable {
    public let id: String
    public let transactionId: String
    public let status: PaymentStatus
    public let amount: Decimal
    public let timestamp: Date
    
    public init(id: String = UUID().uuidString,
                transactionId: String,
                status: PaymentStatus,
                amount: Decimal,
                timestamp: Date = Date()) {
        self.id = id
        self.transactionId = transactionId
        self.status = status
        self.amount = amount
        self.timestamp = timestamp
    }
}

// MARK: - Card Model
public struct Card: Identifiable, Codable, Equatable {
    public let id: String
    public let lastFour: String
    public let expiryMonth: Int
    public let expiryYear: Int
    public let cardholderName: String
    public let brand: String
    
    public init(
        id: String = UUID().uuidString,
        lastFour: String,
        expiryMonth: Int,
        expiryYear: Int,
        cardholderName: String,
        brand: String
    ) {
        self.id = id
        self.lastFour = lastFour
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cardholderName = cardholderName
        self.brand = brand
    }
}

// MARK: - API Client
public class APIClient {
    public static let shared = APIClient()
    
    private init() {}
    
    public func request<T: Decodable>(endpoint: String, method: String = "GET", body: Encodable? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        // Mock implementation for preview mode
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(EmptyResponse() as! T))
        }
    }
    
    // Empty response for when we don't care about the response body
    private struct EmptyResponse: Decodable {}
}

// MARK: - Security Namespace
public enum FOMOSecurity {
    // Tokenization Service
    public class LiveTokenizationService {
        public static let shared = LiveTokenizationService()
        
        public init() {}
        
        public func tokenize(card: Card) -> String {
            // In a real implementation, this would call a payment processor API
            // For preview/mock purposes, we just return a fake token
            return "tok_\(card.brand.lowercased())_\(card.lastFour)"
        }
    }
}

// MARK: - Pricing Tier
public enum PricingTier: String, CaseIterable, Identifiable, Codable {
    case free = "Free"
    case basic = "Basic"
    case premium = "Premium"
    case enterprise = "Enterprise"
    
    public var id: String { rawValue }
    
    public var monthlyPrice: Decimal {
        switch self {
        case .free:
            return 0
        case .basic:
            return 9.99
        case .premium:
            return 19.99
        case .enterprise:
            return 99.99
        }
    }
    
    public var features: [String] {
        switch self {
        case .free:
            return ["Basic venue information", "Limited searches per day"]
        case .basic:
            return ["All free features", "Unlimited searches", "Venue reviews"]
        case .premium:
            return ["All basic features", "Premium venues", "Priority support"]
        case .enterprise:
            return ["All premium features", "Custom integrations", "Dedicated account manager"]
        }
    }
} 