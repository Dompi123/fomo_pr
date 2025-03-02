import Foundation

// MARK: - Venue Models
public struct Venue: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let address: String
    public let description: String
    public let tags: [String]
    public let imageURL: URL?
    public let capacity: Int
    public let currentOccupancy: Int
    public let waitTime: Int
    public let isOpen: Bool
    public let openingHours: [String]
    
    public init(id: String, name: String, address: String, description: String, tags: [String], imageURL: URL?, capacity: Int, currentOccupancy: Int, waitTime: Int, isOpen: Bool, openingHours: [String]) {
        self.id = id
        self.name = name
        self.address = address
        self.description = description
        self.tags = tags
        self.imageURL = imageURL
        self.capacity = capacity
        self.currentOccupancy = currentOccupancy
        self.waitTime = waitTime
        self.isOpen = isOpen
        self.openingHours = openingHours
    }
    
    public static func == (lhs: Venue, rhs: Venue) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static let preview = Venue(
        id: "venue-1",
        name: "The Rooftop Bar",
        address: "123 Main St, San Francisco, CA",
        description: "A beautiful rooftop bar with amazing views of the city.",
        tags: ["Rooftop", "Cocktails", "Views"],
        imageURL: URL(string: "https://example.com/venue1.jpg"),
        capacity: 100,
        currentOccupancy: 65,
        waitTime: 15,
        isOpen: true,
        openingHours: ["Mon-Fri: 4pm-2am", "Sat-Sun: 2pm-2am"]
    )
}

// MARK: - Drink Models
public struct Drink: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Double
    public let imageURL: URL?
    
    public init(id: String, name: String, description: String, price: Double, imageURL: URL?) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageURL = imageURL
    }
    
    public static let preview = Drink(
        id: "drink-1",
        name: "Signature Cocktail",
        description: "Our house specialty with premium spirits and fresh ingredients.",
        price: 12.99,
        imageURL: URL(string: "https://example.com/drink1.jpg")
    )
}

public struct DrinkOrderItem: Identifiable {
    public let id = UUID()
    public let drink: Drink
    public let quantity: Int
    
    public var totalPrice: Double {
        return drink.price * Double(quantity)
    }
    
    public init(drink: Drink, quantity: Int) {
        self.drink = drink
        self.quantity = quantity
    }
}

public struct DrinkOrder {
    public let id = UUID()
    public let items: [DrinkOrderItem]
    
    public var totalPrice: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    public init(items: [DrinkOrderItem]) {
        self.items = items
    }
}

// MARK: - Pass Models
public struct PricingTier: Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Double
    public let features: [String]
    
    public init(id: String, name: String, description: String, price: Double, features: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.features = features
    }
    
    public static let preview = PricingTier(
        id: "tier-1",
        name: "Standard Pass",
        description: "Basic entry to the venue",
        price: 25.0,
        features: ["Entry to main areas", "Access to standard bars"]
    )
}

public struct Pass: Identifiable {
    public let id: String
    public let venueId: String
    public let userId: String
    public let tier: PricingTier
    public let purchaseDate: Date
    public let expiryDate: Date
    public let isActive: Bool
    
    public init(id: String, venueId: String, userId: String, tier: PricingTier, purchaseDate: Date, expiryDate: Date, isActive: Bool) {
        self.id = id
        self.venueId = venueId
        self.userId = userId
        self.tier = tier
        self.purchaseDate = purchaseDate
        self.expiryDate = expiryDate
        self.isActive = isActive
    }
    
    public static let preview = Pass(
        id: "pass-1",
        venueId: "venue-1",
        userId: "user-1",
        tier: .preview,
        purchaseDate: Date(),
        expiryDate: Date().addingTimeInterval(86400), // 24 hours later
        isActive: true
    )
}

// MARK: - User Models
public struct Profile: Identifiable {
    public let id: String
    public let name: String
    public let email: String
    public let phoneNumber: String?
    public let imageURL: URL?
    public let preferences: Preferences
    
    public init(id: String, name: String, email: String, phoneNumber: String?, imageURL: URL?, preferences: Preferences) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.imageURL = imageURL
        self.preferences = preferences
    }
    
    public struct Preferences {
        public var notificationsEnabled: Bool
        public var emailUpdatesEnabled: Bool
        public var favoriteVenues: [String]
        
        public init(notificationsEnabled: Bool, emailUpdatesEnabled: Bool, favoriteVenues: [String]) {
            self.notificationsEnabled = notificationsEnabled
            self.emailUpdatesEnabled = emailUpdatesEnabled
            self.favoriteVenues = favoriteVenues
        }
    }
    
    public static let preview = Profile(
        id: "user-1",
        name: "John Doe",
        email: "john.doe@example.com",
        phoneNumber: "+1 (555) 123-4567",
        imageURL: URL(string: "https://example.com/profile.jpg"),
        preferences: Preferences(
            notificationsEnabled: true,
            emailUpdatesEnabled: false,
            favoriteVenues: ["venue-1", "venue-3"]
        )
    )
} 