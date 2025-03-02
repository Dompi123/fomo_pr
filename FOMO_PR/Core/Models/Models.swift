import Foundation

// MARK: - Venue Models
public struct Venue: Identifiable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let address: String
    public let isOpen: Bool
    public let capacity: Int
    public let currentOccupancy: Int
    public let waitTime: Int
    public let rating: Double
    public let tags: [String]
    
    public init(id: String, name: String, description: String, address: String, isOpen: Bool, capacity: Int, currentOccupancy: Int, waitTime: Int, rating: Double, tags: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.isOpen = isOpen
        self.capacity = capacity
        self.currentOccupancy = currentOccupancy
        self.waitTime = waitTime
        self.rating = rating
        self.tags = tags
    }
}

// MARK: - Drink Models
public struct Drink: Identifiable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Decimal
    public let category: String
    public let isAvailable: Bool
    
    public init(id: String, name: String, description: String, price: Decimal, category: String, isAvailable: Bool) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.category = category
        self.isAvailable = isAvailable
    }
}

// MARK: - Pass Models
public struct Pass: Identifiable, Codable {
    public let id: String
    public let venueId: String
    public let tierId: String
    public let purchaseDate: Date
    public let expirationDate: Date
    public let status: PassStatus
    
    public init(id: String, venueId: String, tierId: String, purchaseDate: Date, expirationDate: Date, status: PassStatus) {
        self.id = id
        self.venueId = venueId
        self.tierId = tierId
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.status = status
    }
}

public enum PassStatus: String, Codable {
    case active
    case expired
    case cancelled
}

// MARK: - Profile Models
public struct Profile: Identifiable, Codable {
    public let id: String
    public let name: String
    public let email: String
    public let phone: String?
    public let preferences: Preferences
    
    public init(id: String, name: String, email: String, phone: String?, preferences: Preferences) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.preferences = preferences
    }
}

public struct Preferences: Codable {
    public var notificationsEnabled: Bool
    public var emailUpdatesEnabled: Bool
    public var favoriteVenues: [String]
    
    public init(notificationsEnabled: Bool, emailUpdatesEnabled: Bool, favoriteVenues: [String]) {
        self.notificationsEnabled = notificationsEnabled
        self.emailUpdatesEnabled = emailUpdatesEnabled
        self.favoriteVenues = favoriteVenues
    }
}

// MARK: - Order Models
public struct DrinkOrder: Identifiable, Codable {
    public let id: String
    public let items: [DrinkOrderItem]
    public let total: Double
    public let status: OrderStatus
    
    public init(id: String, items: [DrinkOrderItem], total: Double, status: OrderStatus) {
        self.id = id
        self.items = items
        self.total = total
        self.status = status
    }
}

public struct DrinkOrderItem: Identifiable, Codable {
    public let id: String
    public let drink: Drink
    public let quantity: Int
    
    public init(drink: Drink, quantity: Int) {
        self.id = UUID().uuidString
        self.drink = drink
        self.quantity = quantity
    }
}

public enum OrderStatus: String, Codable {
    case pending
    case preparing
    case ready
    case completed
    case cancelled
}

// MARK: - Payment Models
public struct PaymentResult: Codable {
    public let transactionId: String
    public let status: PaymentStatus
    public let amount: Double
    public let currency: String
    public let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case status
        case amount
        case currency
        case timestamp
    }
}

public enum PaymentStatus: String, Codable {
    case pending
    case processing
    case completed
    case failed
    case refunded
}

// MARK: - Preview Extensions
#if DEBUG
public extension Venue {
    static let preview = Venue(
        id: "preview-venue",
        name: "Preview Venue",
        description: "A preview venue for testing",
        address: "123 Preview St",
        isOpen: true,
        capacity: 100,
        currentOccupancy: 50,
        waitTime: 15,
        rating: 4.5,
        tags: ["Preview", "Test"]
    )
}

public extension Drink {
    static let preview = Drink(
        id: "preview-drink",
        name: "Preview Drink",
        description: "A preview drink for testing",
        price: 9.99,
        category: "Preview",
        isAvailable: true
    )
}

public extension Pass {
    static let preview = Pass(
        id: "preview-pass",
        venueId: "preview-venue",
        userId: "preview-user",
        type: .standard,
        status: .active,
        expiresAt: Date().addingTimeInterval(86400)
    )
}

public extension Profile {
    static let preview = Profile(
        id: "preview-profile",
        name: "Preview User",
        email: "preview@example.com",
        phone: "+1234567890",
        preferences: ProfilePreferences(
            notificationsEnabled: true,
            emailUpdatesEnabled: true,
            favoriteVenues: ["preview-venue"]
        )
    )
}
#endif

public struct Card: Codable {
    public let number: String
    public let expiry: String
    public let cvc: String
    
    public init(number: String, expiry: String, cvc: String) {
        self.number = number
        self.expiry = expiry
        self.cvc = cvc
    }
}

public struct DrinkItem: Codable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Decimal
    
    public init(id: String, name: String, description: String, price: Decimal) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
    }
}

public struct Order: Codable {
    public let id: String
    public let venueId: String
    public let items: [DrinkItem]
    public let total: Decimal
    public let status: OrderStatus
    
    public init(id: String, venueId: String, items: [DrinkItem], total: Decimal, status: OrderStatus) {
        self.id = id
        self.venueId = venueId
        self.items = items
        self.total = total
        self.status = status
    }
}

public struct PricingTier: Codable {
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
}

public struct PaymentResult: Codable {
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
}

public enum PaymentStatus: String, Codable {
    case success
    case failed
    case pending
    case refunded
} 