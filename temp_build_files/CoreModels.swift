import Foundation
import SwiftUI

// MARK: - Core Model Protocol
public protocol Model {
    var id: String { get }
}

// MARK: - DrinkItem Model
public struct DrinkItem: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let imageURL: URL?
    public let price: Decimal
    public let category: String
    public let isPopular: Bool
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        imageURL: URL? = nil,
        price: Double = 0.0,
        category: String = "",
        isPopular: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.price = Decimal(price)
        self.category = category
        self.isPopular = isPopular
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DrinkItem, rhs: DrinkItem) -> Bool {
        lhs.id == rhs.id
    }
    
    // Preview data
    public static var previewItems: [DrinkItem] = [
        DrinkItem(id: "1", name: "Mojito", description: "Classic mojito with mint and lime", price: 12.99, category: "Cocktails", isPopular: true),
        DrinkItem(id: "2", name: "Margarita", description: "Traditional margarita with salt rim", price: 10.99, category: "Cocktails", isPopular: true),
        DrinkItem(id: "3", name: "Old Fashioned", description: "Whiskey cocktail with bitters", price: 14.99, category: "Cocktails", isPopular: true)
    ]
}

// MARK: - PricingTier Model
public struct PricingTier: Identifiable, Equatable, Codable, Hashable {
    public let id: String
    public let name: String
    public let price: Decimal
    public let description: String
    public let features: [String]?
    public let isPopular: Bool
    
    public init(id: String = UUID().uuidString,
                name: String,
                price: Decimal,
                description: String,
                features: [String]? = nil,
                isPopular: Bool = false) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.features = features
        self.isPopular = isPopular
    }
    
    public static func == (lhs: PricingTier, rhs: PricingTier) -> Bool {
        lhs.id == rhs.id
    }
    
    // Preview data
    public static var previewTiers: [PricingTier] = [
        PricingTier(
            id: "basic",
            name: "Basic Pass",
            price: Decimal(19.99),
            description: "Standard venue access",
            features: ["General admission", "Access to main areas"],
            isPopular: false
        ),
        PricingTier(
            id: "premium",
            name: "Premium Pass",
            price: Decimal(39.99),
            description: "Priority entry and exclusive areas",
            features: ["Priority entry", "Access to all areas", "Complimentary drinks", "Meet & greet with artists"],
            isPopular: false
        ),
        PricingTier(
            id: "vip",
            name: "VIP Pass",
            price: Decimal(99.99),
            description: "All access pass with complimentary drinks",
            features: ["Priority entry", "Access to VIP lounge", "Free welcome drink"],
            isPopular: true
        )
    ]
}

// MARK: - Venue Model
public struct Venue: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let address: String
    public let imageURL: URL?
    public let latitude: Double
    public let longitude: Double
    public let isPremium: Bool
    public let rating: Double?
    public let categories: [String]?
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        address: String = "",
        imageURL: URL? = nil,
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        isPremium: Bool = false,
        rating: Double? = nil,
        categories: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.isPremium = isPremium
        self.rating = rating
        self.categories = categories
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Venue, rhs: Venue) -> Bool {
        lhs.id == rhs.id
    }
    
    // Preview data
    public static var previewVenues: [Venue] = [
        Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "Enjoy drinks with a stunning view of the city skyline.",
            address: "123 Main St, New York, NY 10001",
            imageURL: URL(string: "https://example.com/rooftop.jpg"),
            latitude: 40.7128,
            longitude: -74.0060,
            isPremium: true,
            rating: 4.8,
            categories: ["Nightclub", "Lounge", "Bar"]
        ),
        Venue(
            id: "venue2",
            name: "Underground Lounge",
            description: "A cozy speakeasy with craft cocktails and live jazz.",
            address: "456 Broadway, New York, NY 10012",
            imageURL: URL(string: "https://example.com/lounge.jpg"),
            latitude: 40.7193,
            longitude: -73.9951,
            isPremium: false,
            rating: 4.5,
            categories: ["Live Music", "Bar"]
        ),
        Venue(
            id: "venue3",
            name: "Beachside Brewery",
            description: "Craft beers with ocean views and outdoor seating.",
            address: "789 Ocean Dr, Miami, FL 33139",
            imageURL: URL(string: "https://example.com/brewery.jpg"),
            latitude: 25.7617,
            longitude: -80.1918,
            isPremium: true,
            rating: 4.2,
            categories: ["Beer", "Restaurant"]
        )
    ]
    
    public static var previewVenue: Venue {
        previewVenues[0]
    }
}

// MARK: - Review Data
public struct ReviewData: Codable {
    public let rating: Int
    public let comment: String
    public let userId: String
    
    public init(rating: Int, comment: String, userId: String = UUID().uuidString) {
        self.rating = rating
        self.comment = comment
        self.userId = userId
    }
}

// MARK: - Payment Models

public struct Card: Identifiable, Codable, Hashable {
    public let id: String
    public let lastFour: String
    public let expiryMonth: Int
    public let expiryYear: Int
    public let cardholderName: String
    public let brand: String
    
    public init(id: String = UUID().uuidString,
                lastFour: String,
                expiryMonth: Int,
                expiryYear: Int,
                cardholderName: String,
                brand: String) {
        self.id = id
        self.lastFour = lastFour
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cardholderName = cardholderName
        self.brand = brand
    }
    
    public var formattedExpiry: String {
        return "\(String(format: "%02d", expiryMonth))/\(String(expiryYear).suffix(2))"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Preview instance
    public static let preview = Card(
        id: "card-123",
        lastFour: "4242",
        expiryMonth: 12,
        expiryYear: 2025,
        cardholderName: "John Doe",
        brand: "visa"
    )
}

public enum PaymentStatus: String, Codable {
    case pending
    case processing
    case success
    case failed
    case refunded
    case cancelled
}

public struct PaymentResult: Identifiable, Codable, Hashable {
    public let id: String
    public let transactionId: String
    public let amount: Decimal
    public let status: PaymentStatus
    public let timestamp: Date
    public let errorMessage: String?
    
    public init(id: String = UUID().uuidString,
                transactionId: String,
                amount: Decimal,
                status: PaymentStatus,
                timestamp: Date = Date(),
                errorMessage: String? = nil) {
        self.id = id
        self.transactionId = transactionId
        self.amount = amount
        self.status = status
        self.timestamp = timestamp
        self.errorMessage = errorMessage
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: PaymentResult, rhs: PaymentResult) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Preview instance
    public static let preview = PaymentResult(
        id: "payment-123",
        transactionId: "txn-123456",
        amount: 49.99,
        status: .success
    )
}

// MARK: - API Client

public class APIClient {
    public static let shared = APIClient()
    
    private init() {}
    
    public func request<T: Decodable>(_ endpoint: String, method: String = "GET", body: Data? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        // Mock implementation for preview mode
        #if PREVIEW_MODE
        print("API Request: \(method) \(endpoint)")
        completion(.success(mockResponse() as! T))
        #else
        // Real implementation would go here
        fatalError("Not implemented for production")
        #endif
    }
    
    private func mockResponse() -> Any {
        // Return appropriate mock data based on the request
        return "Mock response"
    }
}

// MARK: - Security

public enum FOMOSecurity {
    public class LiveTokenizationService {
        public static let shared = LiveTokenizationService()
        
        private init() {}
        
        public func tokenizeCard(_ card: Card, completion: @escaping (Result<String, Error>) -> Void) {
            // Mock implementation for preview mode
            #if PREVIEW_MODE
            print("Tokenizing card: \(card.lastFour)")
            completion(.success("tok_\(UUID().uuidString)"))
            #else
            // Real implementation would go here
            fatalError("Not implemented for production")
            #endif
        }
    }
} 