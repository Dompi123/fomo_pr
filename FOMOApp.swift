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
        case .drinkMenu(let venue):
            presentedSheet = .drinkMenu(venue: venue)
        case .checkout(let items):
            presentedSheet = .checkout(items: items)
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
    case drinkMenu(venue: Venue)
    case checkout(items: [DrinkItem])
    case paywall(venue: Venue)
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .drinkMenu(let venue):
            hasher.combine("drinkMenu")
            hasher.combine(venue.id)
        case .checkout(let items):
            hasher.combine("checkout")
            for item in items {
                hasher.combine(item.id)
            }
        case .paywall(let venue):
            hasher.combine("paywall")
            hasher.combine(venue.id)
        }
    }
    
    public static func == (lhs: Destination, rhs: Destination) -> Bool {
        switch (lhs, rhs) {
        case (.drinkMenu(let venue1), .drinkMenu(let venue2)):
            return venue1.id == venue2.id
        case (.checkout(let items1), .checkout(let items2)):
            return items1.map { $0.id } == items2.map { $0.id }
        case (.paywall(let venue1), .paywall(let venue2)):
            return venue1.id == venue2.id
        default:
            return false
        }
    }
}

public enum Sheet: Identifiable {
    case drinkMenu(venue: Venue)
    case checkout(items: [DrinkItem])
    case paywall(venue: Venue)
    
    public var id: String {
        switch self {
        case .drinkMenu(let venue):
            return "drinkMenu-\(venue.id)"
        case .checkout(let items):
            return "checkout-\(items.map { $0.id }.joined(separator: "-"))"
        case .paywall(let venue):
            return "paywall-\(venue.id)"
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
    public let imageURL: URL?
    public let price: Decimal
    public let quantity: Int
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        imageURL: URL? = nil,
        price: Double = 0.0,
        quantity: Int = 1
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
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

// Define the Venue type
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

// Define the ContentView
public struct ContentView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    @State private var selectedTab = 0
    
    public var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                VenueListView()
                    .tabItem {
                        Label("Venues", systemImage: "building.2")
                    }
                    .tag(0)
                
                PassesView()
                    .tabItem {
                        Label("Passes", systemImage: "ticket")
                    }
                    .tag(1)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
            }
            .sheet(item: $navigationCoordinator.presentedSheet) { sheet in
                switch sheet {
                case .drinkMenu(let venue):
                    DrinkMenuView(venue: venue)
                case .checkout(let items):
                    CheckoutView(items: items)
                case .paywall(let venue):
                    PaywallView(venue: venue)
                }
            }
            .navigationTitle(selectedTab == 0 ? "Venues" : (selectedTab == 1 ? "Passes" : "Profile"))
        }
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
            ContentView()
                .environmentObject(navigationCoordinator)
                .onAppear {
                    logger.debug("ContentView appeared successfully")
                }
        }
    }
}

// Simple placeholder view for when other views are not available
public struct PlaceholderView: View {
    public var body: some View {
        VStack {
            Image(systemName: "hammer.fill")
                .font(.largeTitle)
                .padding()
            
            Text("This feature is under development")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// Define the preview version of VenueListView
public struct PreviewVenueListView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    
    public var body: some View {
        Text("Venues List")
            .onAppear {
                logger.debug("VenueListView appeared")
            }
    }
}

// Define the PassesView
public struct PassesView: View {
    public var body: some View {
        Text("Passes")
            .onAppear {
                logger.debug("PassesView appeared")
            }
    }
}

// Define the ProfileView
public struct ProfileView: View {
    public var body: some View {
        Text("Profile")
            .onAppear {
                logger.debug("ProfileView appeared")
            }
    }
}

// Define the DrinkMenuView
public struct DrinkMenuView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    let venue: Venue
    
    public var body: some View {
        Text("Drink Menu")
            .onAppear {
                logger.debug("DrinkMenuView appeared")
            }
    }
}

// Define the CheckoutView
public struct CheckoutView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    let items: [DrinkItem]
    
    public var body: some View {
        Text("Checkout")
            .onAppear {
                logger.debug("CheckoutView appeared")
            }
    }
}

// Define the PaywallView
public struct PaywallView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    let venue: Venue
    
    public var body: some View {
        Text("Paywall")
            .onAppear {
                logger.debug("PaywallView appeared")
            }
    }
}

#if DEBUG
struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView()
    }
}
#endif 