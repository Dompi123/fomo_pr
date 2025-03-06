import Foundation
import SwiftUI

// MockDataProvider provides sample data for preview and testing
public class MockDataProvider {
    public static let shared = MockDataProvider()
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    // Mock drink items
    public var drinks: [DrinkItem] {
        return [
            DrinkItem(
                id: "drink1",
                name: "Mojito",
                description: "Classic cocktail with mint, lime, and rum",
                price: 12.99,
                quantity: 1
            ),
            DrinkItem(
                id: "drink2",
                name: "Old Fashioned",
                description: "Whiskey cocktail with bitters and sugar",
                price: 14.99,
                quantity: 1
            ),
            DrinkItem(
                id: "drink3",
                name: "Margarita",
                description: "Tequila cocktail with lime and salt",
                price: 11.99,
                quantity: 1
            ),
            DrinkItem(
                id: "drink4",
                name: "Craft Beer",
                description: "Local IPA with citrus notes",
                price: 8.99,
                quantity: 1
            ),
            DrinkItem(
                id: "drink5",
                name: "Sparkling Water",
                description: "Refreshing carbonated water",
                price: 3.99,
                quantity: 1
            )
        ]
    }
    
    // Mock venues
    public var venues: [Venue] {
        return [
            Venue(
                id: "venue1",
                name: "The Rooftop Lounge",
                description: "Elegant rooftop venue with panoramic city views",
                address: "123 Main St, San Francisco, CA",
                imageURL: URL(string: "https://example.com/rooftop.jpg"),
                latitude: 37.7749,
                longitude: -122.4194,
                isPremium: true
            ),
            Venue(
                id: "venue2",
                name: "Underground Club",
                description: "Vibrant nightclub with top DJs",
                address: "456 Market St, San Francisco, CA",
                imageURL: URL(string: "https://example.com/club.jpg"),
                latitude: 37.7899,
                longitude: -122.4009,
                isPremium: false
            ),
            Venue(
                id: "venue3",
                name: "Beachside Bar",
                description: "Relaxed bar with ocean views",
                address: "789 Beach Rd, Malibu, CA",
                imageURL: URL(string: "https://example.com/beach.jpg"),
                latitude: 34.0259,
                longitude: -118.7798,
                isPremium: true
            )
        ]
    }
    
    // Mock pricing tiers
    public var pricingTiers: [PricingTier] {
        return [
            PricingTier(
                id: "basic",
                name: "Basic Pass",
                price: Decimal(19.99),
                description: "Standard venue access"
            ),
            PricingTier(
                id: "premium",
                name: "Premium Pass",
                price: Decimal(39.99),
                description: "Priority entry and exclusive areas"
            ),
            PricingTier(
                id: "vip",
                name: "VIP Pass",
                price: Decimal(99.99),
                description: "All access pass with complimentary drinks"
            )
        ]
    }
}

// Define the DrinkItem type locally
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
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
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

// Define the PricingTier type locally
public struct PricingTier: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let price: Decimal
    public let description: String
    
    public init(
        id: String,
        name: String,
        price: Decimal,
        description: String
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
    }
} 