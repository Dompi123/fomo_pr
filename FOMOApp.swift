import SwiftUI
import UIKit
import OSLog
import Foundation
// Using PaymentTypes types from local file instead of as a module
// import FOMO_PR - Commented out as this file is part of the module

// MARK: - Debug Logging
private let logger = Logger(subsystem: "com.fomo.pr", category: "AppInit")

// MARK: - Feature Flags
#if DEBUG
// These will be controlled by environment variables in build scripts
public var isPaywallEnabled: Bool {
    #if ENABLE_PAYWALL
    return true
    #else
    return ProcessInfo.processInfo.environment["ENABLE_PAYWALL"] == "1"
    #endif
}

public var isDrinkMenuEnabled: Bool {
    #if ENABLE_DRINK_MENU
    return true
    #else
    return ProcessInfo.processInfo.environment["ENABLE_DRINK_MENU"] == "1"
    #endif
}

public var isCheckoutEnabled: Bool {
    #if ENABLE_CHECKOUT
    return true
    #else
    return ProcessInfo.processInfo.environment["ENABLE_CHECKOUT"] == "1"
    #endif
}

public var isSearchEnabled: Bool {
    #if ENABLE_SEARCH
    return true
    #else
    return ProcessInfo.processInfo.environment["ENABLE_SEARCH"] == "1"
    #endif
}

public var isPremiumVenuesEnabled: Bool {
    #if ENABLE_PREMIUM_VENUES
    return true
    #else
    return ProcessInfo.processInfo.environment["ENABLE_PREMIUM_VENUES"] == "1"
    #endif
}

public var isMockDataEnabled: Bool {
    #if ENABLE_MOCK_DATA
    return true
    #else
    return ProcessInfo.processInfo.environment["ENABLE_MOCK_DATA"] == "1"
    #endif
}

public var isPreviewMode: Bool {
    #if PREVIEW_MODE
    return true
    #else
    return ProcessInfo.processInfo.environment["PREVIEW_MODE"] == "1"
    #endif
}
#else
// In release builds, these features might be controlled by remote config
public let isPaywallEnabled = false
public let isDrinkMenuEnabled = false
public let isCheckoutEnabled = false
public let isSearchEnabled = false
public let isPremiumVenuesEnabled = false
public let isMockDataEnabled = false
public let isPreviewMode = false
#endif

// MARK: - Core Types
// Define the Venue struct
public struct Venue: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let address: String
    public let imageURL: URL?
    public let latitude: Double
    public let longitude: Double
    public let isPremium: Bool
    public let rating: Double
    
    public init(
        id: String,
        name: String,
        description: String,
        address: String,
        imageURL: URL?,
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        rating: Double = 4.5,
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
        self.rating = rating
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Venue, rhs: Venue) -> Bool {
        lhs.id == rhs.id
    }
}

// Define the DrinkItem struct
public struct DrinkItem: Identifiable, Codable, Hashable {
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
        imageURL: URL?,
        price: Double,
        category: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.price = Decimal(price)
        self.category = category
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DrinkItem, rhs: DrinkItem) -> Bool {
        lhs.id == rhs.id
    }
}

// Define the PricingTier struct if it's not already defined
public struct PricingTier: Identifiable, Codable, Hashable {
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: PricingTier, rhs: PricingTier) -> Bool {
        lhs.id == rhs.id
    }
    
    // Add preview tiers for testing
    public static var previewTiers: [PricingTier] {
        return [
            PricingTier(
                id: "standard",
                name: "Standard",
                price: Decimal(19.99),
                description: "Basic venue access"
            ),
            PricingTier(
                id: "premium",
                name: "Premium",
                price: Decimal(39.99),
                description: "Priority entry and exclusive areas"
            ),
            PricingTier(
                id: "vip",
                name: "VIP",
                price: Decimal(99.99),
                description: "All access pass with complimentary drinks"
            )
        ]
    }
}

// MARK: - Navigation Types
public enum Sheet: Identifiable {
    case profile
    case settings
    case payment
    case drinkDetails(DrinkItem)
    case checkout(order: DrinkOrder)
    case paywall(venue: Venue)
    case drinkMenu(venue: Venue)
    case designSystem // New case for the design system showcase
    
    public var id: String {
        switch self {
        case .profile: return "profile"
        case .settings: return "settings"
        case .payment: return "payment"
        case .drinkDetails(let drink): return "drink_\(drink.id)"
        case .checkout: return "checkout"
        case .paywall(let venue): return "paywall_\(venue.id)"
        case .drinkMenu(let venue): return "drink_menu_\(venue.id)"
        case .designSystem: return "design_system"
        }
    }
}

// MARK: - Preview Navigation Coordinator
@MainActor
public final class PreviewNavigationCoordinator: ObservableObject {
    public static let shared = PreviewNavigationCoordinator()
    
    @Published public var path = NavigationPath()
    @Published public var presentedSheet: Sheet?
    
    private init() {
        logger.debug("PreviewNavigationCoordinator initialized")
    }
    
    public func navigate(to destination: Sheet) {
        logger.debug("Navigating to: \(destination.id)")
        presentedSheet = destination
    }
    
    public func navigateToVenueDetails(venue: Venue) {
        logger.debug("Navigating to venue details: \(venue.name)")
        // In a real app, this would modify the navigation path
        print("Navigating to venue details: \(venue.name)")
    }
    
    public func navigateToDrinkMenu(venue: Venue) {
        if isDrinkMenuEnabled {
            navigate(to: .drinkMenu(venue: venue))
        } else {
            logger.debug("Drink menu is disabled")
        }
    }
    
    public func navigateToPaywall(venue: Venue) {
        if isPaywallEnabled {
            navigate(to: .paywall(venue: venue))
        } else {
            logger.debug("Paywall is disabled")
        }
    }
    
    public func navigateToCheckout(order: DrinkOrder) {
        if isCheckoutEnabled {
            navigate(to: .checkout(order: order))
        } else {
            logger.debug("Checkout is disabled")
        }
    }
    
    public func navigateToDesignSystem() {
        navigate(to: .designSystem)
    }
    
    public func dismissSheet() {
        presentedSheet = nil
    }
    
    public func goBack() {
        if !path.isEmpty {
            path.removeLast()
        } else {
            presentedSheet = nil
        }
    }
}

// MARK: - Payment Manager
public class PaymentManager: ObservableObject {
    public static func createMock() async -> PaymentManager {
        return PaymentManager()
    }
    
    public static func create() async -> PaymentManager {
        return PaymentManager()
    }
    
    public init() {}
}

// Define the DrinkOrder struct
public struct DrinkOrder: Identifiable, Codable, Hashable {
    public let id: String
    public var items: [DrinkItem]
    public var totalPrice: Decimal {
        items.reduce(Decimal(0)) { $0 + $1.price }
    }
    
    public init(id: String = UUID().uuidString, items: [DrinkItem] = []) {
        self.id = id
        self.items = items
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DrinkOrder, rhs: DrinkOrder) -> Bool {
        lhs.id == rhs.id
    }
}

// Define the MockDataProvider class
public class MockDataProvider {
    public static let shared = MockDataProvider()
    
    public var venues: [Venue] {
        return [
            Venue(
                id: "1",
                name: "The Rooftop Lounge",
                description: "Elegant rooftop venue with panoramic city views",
                address: "123 Main St, San Francisco, CA",
                imageURL: nil,
                latitude: 37.7749,
                longitude: -122.4194,
                isPremium: isPremiumVenuesEnabled
            ),
            Venue(
                id: "2",
                name: "Underground Club",
                description: "Vibrant nightclub with top DJs",
                address: "456 Market St, San Francisco, CA",
                imageURL: nil,
                latitude: 37.7899,
                longitude: -122.4009,
                isPremium: false
            ),
            Venue(
                id: "3",
                name: "Skyline Bar",
                description: "Luxurious bar with city skyline views",
                address: "789 Mission St, San Francisco, CA",
                imageURL: nil,
                latitude: 37.7833,
                longitude: -122.4167,
                isPremium: isPremiumVenuesEnabled
            ),
            Venue(
                id: "4",
                name: "Jazz Lounge",
                description: "Intimate venue featuring live jazz performances",
                address: "321 Ellis St, San Francisco, CA",
                imageURL: nil,
                latitude: 37.7847,
                longitude: -122.4119,
                isPremium: false
            )
        ]
    }
    
    public var drinks: [DrinkItem] {
        return [
            DrinkItem(
                id: "1",
                name: "Mojito",
                description: "Classic cocktail with mint, lime, and rum",
                imageURL: nil,
                price: 12.99,
                category: "Cocktails"
            ),
            DrinkItem(
                id: "2",
                name: "Old Fashioned",
                description: "Whiskey cocktail with bitters and sugar",
                imageURL: nil,
                price: 14.99,
                category: "Cocktails"
            ),
            DrinkItem(
                id: "3",
                name: "Margarita",
                description: "Tequila-based cocktail with lime and salt",
                imageURL: nil,
                price: 11.99,
                category: "Cocktails"
            ),
            DrinkItem(
                id: "4",
                name: "Craft Beer",
                description: "Local IPA with citrus notes",
                imageURL: nil,
                price: 8.99,
                category: "Beer"
            ),
            DrinkItem(
                id: "5",
                name: "Red Wine",
                description: "Full-bodied Cabernet Sauvignon",
                imageURL: nil,
                price: 10.99,
                category: "Wine"
            ),
            DrinkItem(
                id: "6",
                name: "White Wine",
                description: "Crisp Chardonnay with fruity notes",
                imageURL: nil,
                price: 9.99,
                category: "Wine"
            )
        ]
    }
    
    public var pricingTiers: [PricingTier] {
        return PricingTier.previewTiers
    }
    
    public func getVenues() -> [Venue] {
        return venues
    }
    
    public func getDrinks(for venue: Venue) -> [DrinkItem] {
        return drinks
    }
    
    public func getPricingTiers(for venue: Venue) -> [PricingTier] {
        return pricingTiers
    }
}

// MARK: - Root View
struct RootView: View {
    @EnvironmentObject var navigationCoordinator: PreviewNavigationCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            TabView {
                VenueListView()
                    .tabItem {
                        Label("Venues", systemImage: "building.2")
                    }
                
                if isDrinkMenuEnabled {
                    Text("Drinks")
                        .tabItem {
                            Label("Drinks", systemImage: "wineglass")
                        }
                }
                
                if isPaywallEnabled {
                PassesView()
                    .tabItem {
                        Label("Passes", systemImage: "ticket")
                    }
                }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                
                // Add a new tab for design system access
                Button("Design System") {
                    navigationCoordinator.navigateToDesignSystem()
                }
                .tabItem {
                    Label("Design", systemImage: "paintpalette")
                }
            }
            .navigationTitle("FOMO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Theme selection options
                        ForEach(ThemeType.allCases) { themeType in
                            Button(themeType.rawValue) {
                                themeManager.selectedThemeType = themeType
                            }
                        }
                    } label: {
                        Image(systemName: "paintpalette")
                            .foregroundColor(themeManager.activeTheme.primary)
                    }
                }
            }
        }
        .sheet(item: $navigationCoordinator.presentedSheet) { sheet in
            switch sheet {
            case .profile:
                ProfileView()
            case .settings:
                Text("Settings")
            case .payment:
                Text("Payment")
            case .drinkDetails(let drink):
                DrinkDetailView(drink: LocalDrinkItem(
                    id: drink.id,
                    name: drink.name,
                    description: drink.description,
                    price: drink.price,
                    quantity: 1
                ))
            case .checkout(let order):
                if isCheckoutEnabled {
                    DrinkCartView()
                } else {
                    Text("Checkout is disabled in this build")
                }
            case .paywall(let venue):
                if isPaywallEnabled {
                    PaywallView(viewModel: PaywallViewModel(venue: venue))
                } else {
                    Text("Paywall is disabled in this build")
                }
            case .drinkMenu(let venue):
                if isDrinkMenuEnabled {
                    DrinkListView()
                        .environmentObject(navigationCoordinator)
                } else {
                    Text("Drink Menu is disabled in this build")
                }
            case .designSystem:
                // Display the design system showcase
                ThemeShowcaseTabView()
                    .environmentObject(themeManager)
            }
        }
        .withTheme() // Apply the active theme to the entire app
    }
}

// MARK: - Main App
@main
struct FOMOApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    // Navigation
    @StateObject private var navigationCoordinator = PreviewNavigationCoordinator.shared
    
    // Payment
    @StateObject private var paymentManager = PaymentManager()
    
    // Theme management
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        // Register fonts at app startup
        TypographySystem.registerFonts()
        
        // Monitor for system appearance changes
        let name = UIDevice.current.userInterfaceIdiom == .pad ? UIDevice.orientationDidChangeNotification : UIApplication.didBecomeActiveNotification
        
        NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: .main
        ) { _ in
            // Update the system dark mode flag
            let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
            UserDefaults.standard.set(isDarkMode, forKey: "isSystemInDarkMode")
            NotificationCenter.default.post(name: Notification.Name("systemAppearanceChanged"), object: nil)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(navigationCoordinator)
                .environmentObject(paymentManager)
                .environmentObject(themeManager)
                .onAppear {
                    // Log environment info at startup
                    logger.debug("App started in Preview Mode: \(isPreviewMode)")
                    logger.debug("Feature flags: Paywall=\(isPaywallEnabled), DrinkMenu=\(isDrinkMenuEnabled), Checkout=\(isCheckoutEnabled), Search=\(isSearchEnabled), PremiumVenues=\(isPremiumVenuesEnabled), MockData=\(isMockDataEnabled)")
                }
        }
    }
}

// MARK: - Stub Views for Preview
#if PREVIEW_MODE
// These views are now imported from FOMO_PR/Features/Root/Views directory
// struct ProfileView: View {
//     var body: some View {
//         Text("Profile View")
//     }
// }

// struct PassesView: View {
//     var body: some View {
//         Text("Passes View")
//     }
// }

// struct PaywallView: View {
//     var viewModel: PaywallViewModel
//     
//     var body: some View {
//         Text("Paywall View")
//     }
// }

#if ENABLE_DRINK_MENU
// These views are already defined in DrinkListView.swift
// Commenting out to avoid duplicate declarations
/*
struct DrinkDetailView: View {
    var drink: LocalDrinkItem
    
    var body: some View {
        Text("Drink Detail: \(drink.name)")
    }
}

struct DrinkCartView: View {
    var body: some View {
        Text("Drink Cart View")
    }
}
*/
#endif

// Add the missing #endif for PREVIEW_MODE
#endif 