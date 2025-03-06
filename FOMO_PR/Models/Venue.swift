import Foundation

struct Venue: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let location: String
    let imageURL: String?
    let isPremium: Bool
    
    static func == (lhs: Venue, rhs: Venue) -> Bool {
        return lhs.id == rhs.id
    }
}

struct PricingTier: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let price: Double
    
    static func == (lhs: PricingTier, rhs: PricingTier) -> Bool {
        return lhs.id == rhs.id
    }
} 