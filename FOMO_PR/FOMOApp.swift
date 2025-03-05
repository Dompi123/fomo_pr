import SwiftUI
import UIKit
import OSLog
import Foundation

// MARK: - Debug Logging
private let logger = Logger(subsystem: "com.fomo.pr", category: "AppInit")

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
            hasher.combine("drinkMenu")
        case .checkout(let order):
            hasher.combine("checkout")
            hasher.combine(order.id)
        case .paywall(let venue):
            hasher.combine("paywall")
            hasher.combine(venue.id)
        }
    }
    
    public static func == (lhs: Destination, rhs: Destination) -> Bool {
        switch (lhs, rhs) {
        case (.drinkMenu, .drinkMenu):
            return true
        case (.checkout(let order1), .checkout(let order2)):
            return order1.id == order2.id
        case (.paywall(let venue1), .paywall(let venue2)):
            return venue1.id == venue2.id
        default:
            return false
        }
    }
}

public enum Sheet: Identifiable {
    case drinkMenu
    case checkout(order: DrinkOrder)
    case paywall(venue: Venue)
    
    public var id: String {
        switch self {
        case .drinkMenu:
            return "drinkMenu"
        case .checkout:
            return "checkout"
        case .paywall:
            return "paywall"
        }
    }
}

// Define the DrinkOrder type
public struct DrinkOrder: Identifiable, Hashable, Codable {
    public let id: String
    public let items: [DrinkItem]
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
    
    public var total: Decimal {
        items.reduce(0) { $0 + ($1.price * Decimal($1.quantity)) }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DrinkOrder, rhs: DrinkOrder) -> Bool {
        lhs.id == rhs.id
    }
}

// Define the DrinkItem type
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

@main
struct FOMOApp: App {
    @StateObject private var navigationCoordinator = PreviewNavigationCoordinator.shared
    
    init() {
        logger.debug("FOMOApp initializing")
        
        // Log available types and modules
        logger.debug("Available types check:")
        #if canImport(FOMO_PR)
        logger.debug("FOMO_PR module can be imported")
        #else
        logger.debug("FOMO_PR module cannot be imported")
        #endif
        
        #if canImport(Models)
        logger.debug("Models module can be imported")
        #else
        logger.debug("Models module cannot be imported")
        #endif
        
        #if canImport(Core)
        logger.debug("Core module can be imported")
        #else
        logger.debug("Core module cannot be imported")
        #endif
        
        // Configure global appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        logger.debug("FOMOApp initialization complete")
    }
    
    var body: some Scene {
        WindowGroup {
            // Try to use ContentView with error handling
            ZStack {
                #if DEBUG
                // In debug mode, try to load ContentView but provide a fallback
                let contentViewType = String(describing: ContentView.self)
                logger.debug("Attempting to load view type: \(contentViewType)")
                
                ContentView()
                    .environmentObject(navigationCoordinator)
                    .preferredColorScheme(.dark)
                    .onAppear {
                        logger.debug("ContentView appeared successfully")
                    }
                #else
                // In release mode, just use ContentView directly
                ContentView()
                    .environmentObject(navigationCoordinator)
                    .preferredColorScheme(.dark)
                #endif
            }
        }
    }
}

// Simple placeholder view for when other views are not available
public struct PlaceholderView: View {
    public var body: some View {
        VStack {
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()
            
            Text("Coming Soon")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            
            Text("This feature is under development")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#if DEBUG
struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView()
    }
}
#endif
