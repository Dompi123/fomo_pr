import SwiftUI
import Foundation
import OSLog

// Simple logger for debugging
private let logger = Logger(subsystem: "com.fomo.pr", category: "Navigation")

// Define the PreviewNavigationCoordinator class
@MainActor
public final class PreviewNavigationCoordinator: ObservableObject {
    public static let shared = PreviewNavigationCoordinator()
    
    @Published public var path = NavigationPath()
    @Published public var presentedSheet: Sheet?
    
    private init() {
        logger.debug("PreviewNavigationCoordinator initialized")
    }
    
    public func navigate(to destination: Destination) {
        logger.debug("Navigating to: \(String(describing: destination))")
        switch destination {
        case .drinkMenu:
            presentedSheet = .drinkMenu
        case .checkout(let order):
            presentedSheet = .checkout(order: order)
        case .paywall(let venue):
            presentedSheet = .paywall(venue: venue)
        }
    }
    
    public func goBack() {
        if !path.isEmpty {
            path.removeLast()
        } else {
            presentedSheet = nil
        }
    }
    
    public func dismissSheet() {
        presentedSheet = nil
    }
}

// Define the necessary enums for navigation
public enum Destination: Hashable {
    case drinkMenu
    case checkout(order: DrinkOrder)
    case paywall(venue: Venue)
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .drinkMenu:
            hasher.combine(0)
        case .checkout(let order):
            hasher.combine(1)
            hasher.combine(order.id)
        case .paywall(let venue):
            hasher.combine(2)
            hasher.combine(venue.id)
        }
    }
    
    public static func == (lhs: Destination, rhs: Destination) -> Bool {
        switch (lhs, rhs) {
        case (.drinkMenu, .drinkMenu):
            return true
        case (.checkout(let lhsOrder), .checkout(let rhsOrder)):
            return lhsOrder.id == rhsOrder.id
        case (.paywall(let lhsVenue), .paywall(let rhsVenue)):
            return lhsVenue.id == rhsVenue.id
        default:
            return false
        }
    }
}

public enum Sheet: Identifiable, Hashable {
    case drinkMenu
    case checkout(order: DrinkOrder)
    case paywall(venue: Venue)
    
    public var id: String {
        switch self {
        case .drinkMenu:
            return "drinkMenu"
        case .checkout(let order):
            return "checkout-\(order.id)"
        case .paywall(let venue):
            return "paywall-\(venue.id)"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.id == rhs.id
    }
}

// Define the DrinkOrder type locally
public struct DrinkOrder: Identifiable, Hashable, Codable {
    public let id: String
    public var items: [DrinkItem]
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        items: [DrinkItem] = [],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.items = items
        self.timestamp = timestamp
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DrinkOrder, rhs: DrinkOrder) -> Bool {
        lhs.id == rhs.id
    }
}

// Define the DrinkItem type locally
public struct DrinkItem: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Decimal
    public var quantity: Int
    
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

// Define the Venue type locally
public struct Venue: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let address: String
    public let imageURL: URL?
    public let latitude: Double
    public let longitude: Double
    public let isPremium: Bool
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        address: String = "",
        imageURL: URL? = nil,
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.isPremium = isPremium
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Venue, rhs: Venue) -> Bool {
        lhs.id == rhs.id
    }
} 