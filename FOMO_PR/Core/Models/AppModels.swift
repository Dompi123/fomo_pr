import Foundation

// MARK: - Venue Models
public struct Venue: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let description: String
    public let address: String
    public let capacity: Int
    public let currentOccupancy: Int
    public let waitTime: Int
    public let imageURL: String?
    public let latitude: Double
    public let longitude: Double
    public let openingHours: String
    public let tags: [String]
    public let rating: Double
    public let isOpen: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, address, capacity
        case currentOccupancy = "current_occupancy"
        case waitTime = "wait_time"
        case imageURL = "image_url"
        case latitude, longitude
        case openingHours = "opening_hours"
        case tags, rating, isOpen
    }
    
    public init(
        id: String,
        name: String,
        description: String,
        address: String,
        capacity: Int,
        currentOccupancy: Int,
        waitTime: Int,
        imageURL: String?,
        latitude: Double,
        longitude: Double,
        openingHours: String,
        tags: [String],
        rating: Double,
        isOpen: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.capacity = capacity
        self.currentOccupancy = currentOccupancy
        self.waitTime = waitTime
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.openingHours = openingHours
        self.tags = tags
        self.rating = rating
        self.isOpen = isOpen
    }
}

#if DEBUG
public extension Venue {
    static let preview = Venue(
        id: "1",
        name: "The Rooftop Bar",
        description: "A luxurious rooftop bar with stunning city views",
        address: "123 Main St, New York, NY 10001",
        capacity: 200,
        currentOccupancy: 150,
        waitTime: 15,
        imageURL: "venue_rooftop",
        latitude: 40.7128,
        longitude: -74.0060,
        openingHours: "Mon-Sun: 4PM-2AM",
        tags: ["Rooftop", "Cocktails", "Views"],
        rating: 4.5,
        isOpen: true
    )
    
    static let previewList = [
        preview,
        Venue(
            id: "2",
            name: "Underground Lounge",
            description: "An exclusive underground speakeasy",
            address: "456 Park Ave, New York, NY 10002",
            capacity: 100,
            currentOccupancy: 80,
            waitTime: 30,
            imageURL: "venue_lounge",
            latitude: 40.7112,
            longitude: -73.9991,
            openingHours: "Tue-Sun: 6PM-4AM",
            tags: ["Speakeasy", "Cocktails", "Jazz"],
            rating: 4.8,
            isOpen: true
        ),
        Venue(
            id: "3",
            name: "Beach Club",
            description: "Beachfront venue with live music",
            address: "789 Ocean Dr, Miami, FL 33139",
            capacity: 300,
            currentOccupancy: 200,
            waitTime: 0,
            imageURL: "venue_beach",
            latitude: 25.7617,
            longitude: -80.1918,
            openingHours: "Mon-Sun: 11AM-Sunset",
            tags: ["Beach", "Live Music", "Outdoor"],
            rating: 4.2,
            isOpen: false
        )
    ]
}
#endif

// MARK: - Drink Models
public struct Drink: Identifiable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Double
    public let imageURL: String?
    public let ingredients: [String]
    public let alcoholContent: Double?
    public let venueId: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price
        case imageURL = "image_url"
        case ingredients
        case alcoholContent = "alcohol_content"
        case venueId = "venue_id"
    }
    
    public init(
        id: String,
        name: String,
        description: String,
        price: Double,
        imageURL: String?,
        ingredients: [String],
        alcoholContent: Double?,
        venueId: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageURL = imageURL
        self.ingredients = ingredients
        self.alcoholContent = alcoholContent
        self.venueId = venueId
    }
}

// MARK: - Pass Models
public struct Pass: Identifiable, Codable {
    public let id: String
    public let venueId: String
    public let userId: String
    public let purchaseDate: Date
    public let expiryDate: Date
    public let status: PassStatus
    public let price: Double
    public let qrCode: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case venueId = "venue_id"
        case userId = "user_id"
        case purchaseDate = "purchase_date"
        case expiryDate = "expiry_date"
        case status
        case price
        case qrCode = "qr_code"
    }
    
    public init(
        id: String,
        venueId: String,
        userId: String,
        purchaseDate: Date,
        expiryDate: Date,
        status: PassStatus,
        price: Double,
        qrCode: String
    ) {
        self.id = id
        self.venueId = venueId
        self.userId = userId
        self.purchaseDate = purchaseDate
        self.expiryDate = expiryDate
        self.status = status
        self.price = price
        self.qrCode = qrCode
    }
}

public enum PassStatus: String, Codable {
    case active
    case used
    case expired
    case cancelled
}

// MARK: - Profile Models
public struct Profile: Identifiable, Codable {
    public let id: String
    public let email: String
    public let name: String
    public let phoneNumber: String?
    public let profileImageURL: String?
    public let preferences: [String]?
    public let memberSince: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, name
        case phoneNumber = "phone_number"
        case profileImageURL = "profile_image_url"
        case preferences
        case memberSince = "member_since"
    }
    
    public init(
        id: String,
        email: String,
        name: String,
        phoneNumber: String?,
        profileImageURL: String?,
        preferences: [String]?,
        memberSince: Date
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.preferences = preferences
        self.memberSince = memberSince
    }
}

// MARK: - Order Models
public struct Order: Identifiable, Codable {
    public let id: String
    public let userId: String
    public let venueId: String
    public let items: [OrderItem]
    public let totalAmount: Double
    public let status: OrderStatus
    public let orderDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case venueId = "venue_id"
        case items
        case totalAmount = "total_amount"
        case status
        case orderDate = "order_date"
    }
    
    public init(
        id: String,
        userId: String,
        venueId: String,
        items: [OrderItem],
        totalAmount: Double,
        status: OrderStatus,
        orderDate: Date
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.items = items
        self.totalAmount = totalAmount
        self.status = status
        self.orderDate = orderDate
    }
}

public struct OrderItem: Identifiable, Codable {
    public let id: String
    public let drinkId: String
    public let quantity: Int
    public let price: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case drinkId = "drink_id"
        case quantity, price
    }
    
    public init(
        id: String,
        drinkId: String,
        quantity: Int,
        price: Double
    ) {
        self.id = id
        self.drinkId = drinkId
        self.quantity = quantity
        self.price = price
    }
}

public enum OrderStatus: String, Codable {
    case pending
    case confirmed
    case ready
    case delivered
    case cancelled
}

// MARK: - Pricing Models
public struct PricingTier: Identifiable, Codable, Equatable {
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

#if DEBUG
public extension PricingTier {
    static func mockTiers() -> [PricingTier] {
        [
            PricingTier(
                id: "tier_standard",
                name: "Standard",
                price: 29.99,
                description: "Basic entry pass"
            ),
            PricingTier(
                id: "tier_vip",
                name: "VIP",
                price: 49.99,
                description: "Premium experience with exclusive perks"
            ),
            PricingTier(
                id: "tier_premium",
                name: "Premium",
                price: 99.99,
                description: "Ultimate luxury experience"
            )
        ]
    }
    
    static var mock: PricingTier { mockTiers()[0] }
}
#endif

// MARK: - Drink Order Models
public struct DrinkOrder: Identifiable, Hashable, Codable {
    public let id: String
    public let items: [DrinkOrderItem]
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        items: [DrinkOrderItem],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.items = items
        self.timestamp = timestamp
    }
    
    public var total: Decimal {
        items.reduce(0) { $0 + ($1.drink.price * Decimal($1.quantity)) }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DrinkOrder, rhs: DrinkOrder) -> Bool {
        lhs.id == rhs.id
    }
}

public struct DrinkOrderItem: Identifiable, Hashable, Codable {
    public let id: String
    public let drink: DrinkItem
    public var quantity: Int
    
    public init(
        id: String = UUID().uuidString,
        drink: DrinkItem,
        quantity: Int = 1
    ) {
        self.id = id
        self.drink = drink
        self.quantity = quantity
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DrinkOrderItem, rhs: DrinkOrderItem) -> Bool {
        lhs.id == rhs.id
    }
}

public struct DrinkItem: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Decimal
    public var quantity: Int
    
    public var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter.string(from: price as NSDecimalNumber) ?? "$\(price)"
    }
    
    public init(
        id: String,
        name: String,
        description: String,
        price: Double,
        quantity: Int = 1
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = Decimal(price)
        self.quantity = quantity
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DrinkItem, rhs: DrinkItem) -> Bool {
        lhs.id == rhs.id
    }
}

#if DEBUG
public extension DrinkItem {
    static let mock = DrinkItem(
        id: "drink_1",
        name: "Signature Mojito",
        description: "Fresh mint, lime juice, rum, and soda water",
        price: 12.99
    )
    
    static let mock2 = DrinkItem(
        id: "drink_2",
        name: "Classic Martini",
        description: "Gin or vodka with dry vermouth and olive garnish",
        price: 14.99
    )
}
#endif 