import Foundation
import SwiftUI

#if PREVIEW_MODE
// Define the DrinkItem type for preview mode
public struct DrinkItem: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Decimal
    public let imageURL: URL?
    public let category: String
    
    public init(
        id: String,
        name: String,
        description: String,
        price: Decimal,
        imageURL: URL? = nil,
        category: String = "Other"
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageURL = imageURL
        self.category = category
    }
    
    public static func == (lhs: DrinkItem, rhs: DrinkItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    #if DEBUG
    public static var mockDrink: DrinkItem {
        DrinkItem(
            id: "drink-123",
            name: "Signature Cocktail",
            description: "Our signature blend of premium spirits and fresh ingredients",
            price: 12.99,
            imageURL: URL(string: "https://example.com/cocktail.jpg"),
            category: "Cocktails"
        )
    }
    
    public static var mockDrinks: [DrinkItem] {
        [
            DrinkItem(
                id: "drink-123",
                name: "Signature Cocktail",
                description: "Our signature blend of premium spirits and fresh ingredients",
                price: 12.99,
                imageURL: URL(string: "https://example.com/cocktail.jpg"),
                category: "Cocktails"
            ),
            DrinkItem(
                id: "drink-456",
                name: "Craft Beer",
                description: "Locally brewed IPA with citrus notes",
                price: 8.99,
                imageURL: URL(string: "https://example.com/beer.jpg"),
                category: "Beer"
            ),
            DrinkItem(
                id: "drink-789",
                name: "Classic Martini",
                description: "Gin or vodka with dry vermouth and olive garnish",
                price: 14.99,
                imageURL: URL(string: "https://example.com/martini.jpg"),
                category: "Cocktails"
            )
        ]
    }
    #endif
}

// Define the DrinkOrder type
public struct DrinkOrder: Identifiable, Codable {
    public let id: String
    public let drinkId: String
    public let quantity: Int
    public let status: OrderStatus
    public let timestamp: Date
    
    public enum OrderStatus: String, Codable {
        case pending
        case preparing
        case ready
        case delivered
        case cancelled
    }
    
    public init(
        id: String,
        drinkId: String,
        quantity: Int = 1,
        status: OrderStatus = .pending,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.drinkId = drinkId
        self.quantity = quantity
        self.status = status
        self.timestamp = timestamp
    }
    
    #if DEBUG
    public static var mockOrder: DrinkOrder {
        DrinkOrder(
            id: "order-123",
            drinkId: "drink-123",
            quantity: 2,
            status: .preparing
        )
    }
    #endif
}

// Define the Venue type for preview mode
public struct Venue: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let address: String
    public let imageURL: URL?
    public let rating: Double
    public let drinks: [DrinkItem]
    public let latitude: Double?
    public let longitude: Double?
    
    public init(
        id: String,
        name: String,
        description: String,
        address: String,
        imageURL: URL? = nil,
        rating: Double = 0.0,
        drinks: [DrinkItem] = [],
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.imageURL = imageURL
        self.rating = rating
        self.drinks = drinks
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public static func == (lhs: Venue, rhs: Venue) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    #if DEBUG
    public static var mockVenue: Venue {
        Venue(
            id: "venue-123",
            name: "Skyline Lounge",
            description: "Upscale rooftop bar with panoramic city views",
            address: "123 Main St, New York, NY 10001",
            imageURL: URL(string: "https://example.com/venue.jpg"),
            rating: 4.8,
            drinks: DrinkItem.mockDrinks,
            latitude: 40.7128,
            longitude: -74.0060
        )
    }
    
    public static var mockVenues: [Venue] {
        [
            Venue(
                id: "venue-123",
                name: "Skyline Lounge",
                description: "Upscale rooftop bar with panoramic city views",
                address: "123 Main St, New York, NY 10001",
                imageURL: URL(string: "https://example.com/venue1.jpg"),
                rating: 4.8,
                drinks: DrinkItem.mockDrinks,
                latitude: 40.7128,
                longitude: -74.0060
            ),
            Venue(
                id: "venue-456",
                name: "The Speakeasy",
                description: "Hidden cocktail bar with vintage ambiance",
                address: "456 Broadway, New York, NY 10012",
                imageURL: URL(string: "https://example.com/venue2.jpg"),
                rating: 4.5,
                drinks: DrinkItem.mockDrinks,
                latitude: 40.7193,
                longitude: -73.9951
            )
        ]
    }
    #endif
}
#endif

// Verify that venue types are available
func verifyVenueTypes() {
    #if PREVIEW_MODE
    print("DrinkItem is available in preview mode")
    print("Sample drink: \(DrinkItem.mockDrink)")
    print("Venue is available in preview mode")
    print("Sample venue: \(Venue.mockVenue)")
    print("DrinkOrder is available in preview mode")
    print("Sample order: \(DrinkOrder.mockOrder)")
    #else
    print("Using production Venue module")
    #endif
} 