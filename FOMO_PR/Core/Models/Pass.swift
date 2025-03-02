import Foundation

public struct Pass: Codable, Identifiable {
    public let id: String
    public let venueId: String
    public let name: String
    public let description: String
    public let price: Double
    public let validUntil: Date
    public let status: PassStatus
    public let benefits: [String]
    
    public init(id: String, venueId: String, name: String, description: String, price: Double, validUntil: Date, status: PassStatus, benefits: [String]) {
        self.id = id
        self.venueId = venueId
        self.name = name
        self.description = description
        self.price = price
        self.validUntil = validUntil
        self.status = status
        self.benefits = benefits
    }
}

public enum PassStatus: String, Codable {
    case active
    case expired
    case cancelled
}

extension Pass {
    public static let preview = Pass(
        id: "preview-pass",
        venueId: "venue-1",
        name: "VIP Access Pass",
        description: "Exclusive access to VIP areas and special events",
        price: 99.99,
        validUntil: Date().addingTimeInterval(30 * 24 * 60 * 60), // 30 days from now
        status: .active,
        benefits: [
            "Priority Entry",
            "VIP Lounge Access",
            "Complimentary Welcome Drink",
            "Special Event Invitations"
        ]
    )
} 