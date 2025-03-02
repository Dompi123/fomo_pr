import Foundation

public struct PricingTier: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Double
    public let features: [String]
    public let duration: TimeInterval
    public let maxPasses: Int
    public let isPopular: Bool
    
    public init(
        id: String,
        name: String,
        description: String,
        price: Double,
        features: [String],
        duration: TimeInterval,
        maxPasses: Int,
        isPopular: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.features = features
        self.duration = duration
        self.maxPasses = maxPasses
        self.isPopular = isPopular
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price, features, duration
        case maxPasses = "max_passes"
        case isPopular = "is_popular"
    }
}

// MARK: - Preview Data
#if DEBUG
public extension PricingTier {
    static let preview = PricingTier(
        id: "1",
        name: "Premium Pass",
        description: "Access to all premium venues with priority entry",
        price: 99.99,
        features: [
            "Priority Entry",
            "VIP Lounge Access",
            "Complimentary Welcome Drink",
            "24/7 Concierge Service"
        ],
        duration: 86400 * 30, // 30 days
        maxPasses: 5,
        isPopular: true
    )
    
    static let previewTiers = [
        PricingTier(
            id: "1",
            name: "Basic Pass",
            description: "Essential access to selected venues",
            price: 49.99,
            features: [
                "Standard Entry",
                "Basic Support",
                "Digital Pass"
            ],
            duration: 86400 * 7, // 7 days
            maxPasses: 2,
            isPopular: false
        ),
        PricingTier(
            id: "2",
            name: "Premium Pass",
            description: "Access to all premium venues with priority entry",
            price: 99.99,
            features: [
                "Priority Entry",
                "VIP Lounge Access",
                "Complimentary Welcome Drink",
                "24/7 Concierge Service"
            ],
            duration: 86400 * 30, // 30 days
            maxPasses: 5,
            isPopular: true
        ),
        PricingTier(
            id: "3",
            name: "Elite Pass",
            description: "Ultimate VIP experience with exclusive benefits",
            price: 199.99,
            features: [
                "Instant VIP Entry",
                "Private Table Service",
                "Personal Concierge",
                "Exclusive Events Access",
                "Complimentary Valet Parking"
            ],
            duration: 86400 * 90, // 90 days
            maxPasses: 10,
            isPopular: false
        )
    ]
}
#endif 