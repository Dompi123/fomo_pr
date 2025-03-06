import Foundation
import SwiftUI

// MARK: - Card Model
public struct Card: Identifiable, Hashable, Codable {
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Payment Status
public enum PaymentStatus: String, Codable {
    case pending
    case processing
    case success
    case failed
    case refunded
    case cancelled
}

// MARK: - Payment Result
public struct PaymentResult: Identifiable, Codable {
    public let id: String
    public let transactionId: String
    public let amount: Decimal
    public let status: PaymentStatus
    public let timestamp: Date
    public let errorMessage: String?
    
    public init(
        id: String = UUID().uuidString,
        transactionId: String,
        amount: Decimal,
        status: PaymentStatus,
        timestamp: Date = Date(),
        errorMessage: String? = nil
    ) {
        self.id = id
        self.transactionId = transactionId
        self.amount = amount
        self.status = status
        self.timestamp = timestamp
        self.errorMessage = errorMessage
    }
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

// MARK: - API Client
public class APIClient {
    public static let shared = APIClient()
    
    private init() {}
    
    public func request<T: Decodable>(endpoint: String, method: String = "GET", body: Encodable? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        // Mock implementation for preview mode
        // In a real implementation, this would make actual network requests
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(EmptyResponse() as! T))
        }
    }
    
    // Empty response for when we don't care about the response body
    private struct EmptyResponse: Decodable {}
} 