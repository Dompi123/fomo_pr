import SwiftUI
import UIKit
import OSLog
import Foundation
// Import our extracted models
import Models
// Import our extracted navigation types
// import Navigation
// Import our feature management system
import Features

// Define necessary navigation types directly
import SwiftUI

// MARK: - Navigation Types
public struct NavigationState {
    public var path = NavigationPath()
    public var activeSheet: Sheet?
    
    public init(path: NavigationPath = NavigationPath(), activeSheet: Sheet? = nil) {
        self.path = path
        self.activeSheet = activeSheet
    }
}

public enum Sheet: Identifiable, Hashable {
    case paywall
    case drinkMenu(venueId: String)
    case checkout(venueId: String, items: [String: Int])
    
    public var id: String {
        switch self {
        case .paywall:
            return "paywall"
        case .drinkMenu(let venueId):
            return "drinkMenu-\(venueId)"
        case .checkout(let venueId, _):
            return "checkout-\(venueId)"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.id == rhs.id
    }
}

public enum Route: Hashable {
    case venueDetail(id: String)
    case profile
    case passes
    case settings
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .venueDetail(let id):
            hasher.combine("venueDetail")
            hasher.combine(id)
        case .profile:
            hasher.combine("profile")
        case .passes:
            hasher.combine("passes")
        case .settings:
            hasher.combine("settings")
        }
    }
    
    public static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.venueDetail(let lhsId), .venueDetail(let rhsId)):
            return lhsId == rhsId
        case (.profile, .profile), (.passes, .passes), (.settings, .settings):
            return true
        default:
            return false
        }
    }
}

public protocol FeatureAvailabilityChecking {
    func isEnabled(_ feature: Feature) -> Bool
}

public struct DefaultFeatureAvailability: FeatureAvailabilityChecking {
    public func isEnabled(_ feature: Feature) -> Bool {
        return true
    }
    
    public init() {}
}

public final class NavigationCoordinator: ObservableObject {
    public static let shared = NavigationCoordinator()
    
    private let logger = Logger(subsystem: "com.fomo.pr", category: "Navigation")
    
    @Published public var path = NavigationPath()
    @Published public var activeSheet: Sheet?
    
    private var featureAvailability: FeatureAvailabilityChecking
    
    public init(featureAvailability: FeatureAvailabilityChecking = DefaultFeatureAvailability()) {
        self.featureAvailability = featureAvailability
        logger.debug("NavigationCoordinator initialized")
    }
    
    // MARK: - Navigation Methods
    
    public func navigateTo(_ route: Route) {
        path.append(route)
    }
    
    public func presentSheet(_ sheet: Sheet) {
        activeSheet = sheet
    }
    
    public func dismissSheet() {
        activeSheet = nil
    }
    
    public func popToRoot() {
        path = NavigationPath()
    }
    
    public func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}

// MARK: - RuntimeFeatureAvailability
class RuntimeFeatureAvailability: FeatureAvailabilityChecking {
    static let shared = RuntimeFeatureAvailability()
    
    var logger = Logger(subsystem: "com.fomo.pr", category: "FeatureManagement")
    
    init() {
        logger.debug("RuntimeFeatureAvailability initialized")
    }
    
    func isEnabled(_ feature: Feature) -> Bool {
        return FeatureManager.shared.isEnabled(feature)
    }
}

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

// MARK: - Feature Availability
/// Runtime feature checker that uses the FeatureManager
public class RuntimeFeatureAvailability: FeatureAvailabilityChecking {
    static let shared = RuntimeFeatureAvailability()
    
    var logger = Logger(subsystem: "com.fomo.pr", category: "FeatureManagement")
    
    init() {
        logger.debug("RuntimeFeatureAvailability initialized")
    }
    
    func isEnabled(_ feature: Feature) -> Bool {
        return FeatureManager.shared.isEnabled(feature)
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
                isPremium: FeatureManager.shared.isEnabled(.premiumVenues)
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
                isPremium: FeatureManager.shared.isEnabled(.premiumVenues)
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
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @ObservedObject private var featureManager = FeatureManager.shared
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            TabView {
                VenueListView()
                    .tabItem {
                        Label("Venues", systemImage: "building.2")
                    }
                
                if featureManager.isEnabled(.drinkMenu) {
                    Text("Drinks")
                        .tabItem {
                            Label("Drinks", systemImage: "wineglass")
                        }
                }
                
                if featureManager.isEnabled(.paywall) {
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
                
                #if DEBUG
                // Add feature toggle UI in debug builds
                Button("Features") {
                    navigationCoordinator.navigate(to: .featureToggles)
                }
                .tabItem {
                    Label("Features", systemImage: "switch.2")
                }
                #endif
            }
            .navigationTitle("FOMO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Theme selection options
                        ForEach(ThemeType.allCases) { themeType in
                            Button(themeType.rawValue) {
                                // themeManager.selectedThemeType = themeType
                            }
                        }
                    } label: {
                        Image(systemName: "paintpalette")
                            .foregroundColor(.primary)
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
            case .checkout(let _):
                // Handle checkout
                EmptyView()
            case .paywall(let venue):
                if featureManager.isEnabled(.paywall) {
                    PaywallView(venue: venue)
                } else {
                    Text("Paywall is disabled in this build")
                }
            case .drinkMenu(let _):
                // Handle drink menu
                EmptyView()
            case .designSystem:
                // Display the design system showcase
                ThemeShowcaseTabView()
            }
        }
    }
}

// MARK: - Main App
@main
struct FOMOApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    // Navigation with runtime feature availability
    @StateObject private var navigationCoordinator = NavigationCoordinator(featureAvailability: RuntimeFeatureAvailability.shared)
    
    // Payment
    @StateObject private var paymentManager = PaymentManager()
    
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
            NotificationCenter.default.post(name: .init("systemAppearanceChanged"), object: nil)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(navigationCoordinator)
                .environmentObject(paymentManager)
        }
    }
}

// MARK: - Stub Views for Preview
#if PREVIEW_MODE
// These views are now imported from FOMO_PR/Features/Root/Views directory
// No need for stub implementations as they exist as separate files
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

// MARK: - Theme Definitions
struct ThemeShowcaseTabView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ThemeColorShowcase()
                    .tabItem {
                        Label("Colors", systemImage: "paintpalette")
                    }
                    .tag(0)
                
                ThemeTypographyShowcase()
                    .tabItem {
                        Label("Typography", systemImage: "textformat")
                    }
                    .tag(1)
                
                ThemeComponentShowcase()
                    .tabItem {
                        Label("Components", systemImage: "square.on.square")
                    }
                    .tag(2)
                
                ThemeSpacingShowcase()
                    .tabItem {
                        Label("Layout", systemImage: "ruler")
                    }
                    .tag(3)
                
                ThemeSettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(4)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(themeManager)
        }
    }
    
    private var navigationTitle: String {
        switch selectedTab {
        case 0: return "Colors"
        case 1: return "Typography"
        case 2: return "Components"
        case 3: return "Layout"
        case 4: return "Settings"
        default: return "Design System"
        }
    }
}

// MARK: - Color Showcase View
struct ThemeColorShowcase: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                sectionHeader("Color System")
                
                colorSection(title: "Brand Colors", colors: [
                    ("Primary", FOMOTheme.Colors.primary),
                    ("Secondary", FOMOTheme.Colors.secondary),
                    ("Accent", FOMOTheme.Colors.accent)
                ])
                
                colorSection(title: "Status Colors", colors: [
                    ("Success", FOMOTheme.Colors.success),
                    ("Warning", FOMOTheme.Colors.warning),
                    ("Error", FOMOTheme.Colors.error)
                ])
                
                colorSection(title: "Background Colors", colors: [
                    ("Background", FOMOTheme.Colors.background),
                    ("Surface", FOMOTheme.Colors.surface)
                ])
                
                colorSection(title: "Text Colors", colors: [
                    ("Text", FOMOTheme.Colors.text),
                    ("Text Secondary", FOMOTheme.Colors.textSecondary)
                ])
            }
            .padding()
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(FOMOTheme.Typography.headlineLarge)
                .foregroundColor(FOMOTheme.Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
        }
    }
    
    private func colorSection(title: String, colors: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(colors, id: \.0) { name, color in
                    colorItem(name, color)
                }
            }
        }
    }
    
    private func colorItem(_ name: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(height: 80)
                .cornerRadius(FOMOTheme.Radius.small)
                .shadow(radius: 2)
            
            Text(name)
                .font(FOMOTheme.Typography.headline)
                .foregroundColor(FOMOTheme.Colors.text)
            
            // Color value placeholder - in a real implementation we'd extract the hex value
            Text("#Color")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
    }
}

// MARK: - Typography Showcase View
struct ThemeTypographyShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                sectionHeader("Typography System")
                
                typographySection(title: "Headlines", items: [
                    ("headlineLarge", FOMOTheme.Typography.headlineLarge, "28pt Bold"),
                    ("headlineMedium", FOMOTheme.Typography.headlineMedium, "22pt Bold"),
                    ("headlineSmall", FOMOTheme.Typography.headlineSmall, "20pt Bold")
                ])
                
                typographySection(title: "Body Text", items: [
                    ("bodyLarge", FOMOTheme.Typography.bodyLarge, "18pt Regular"),
                    ("bodyRegular", FOMOTheme.Typography.bodyRegular, "16pt Regular"),
                    ("bodySmall", FOMOTheme.Typography.bodySmall, "14pt Regular")
                ])
                
                typographySection(title: "Captions", items: [
                    ("caption1", FOMOTheme.Typography.caption1, "12pt Regular"),
                    ("caption2", FOMOTheme.Typography.caption2, "10pt Regular")
                ])
                
                typographySection(title: "Original Styles", items: [
                    ("display", FOMOTheme.Typography.display, "34pt Bold Rounded"),
                    ("title1", FOMOTheme.Typography.title1, "26pt Bold"),
                    ("title2", FOMOTheme.Typography.title2, "22pt Bold"),
                    ("headline", FOMOTheme.Typography.headline, "17pt Semibold"),
                    ("subheadline", FOMOTheme.Typography.subheadline, "15pt Regular"),
                    ("body", FOMOTheme.Typography.body, "17pt Regular")
                ])
            }
            .padding()
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(FOMOTheme.Typography.headlineLarge)
                .foregroundColor(FOMOTheme.Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
        }
    }
    
    private func typographySection(title: String, items: [(String, Font, String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.0) { name, font, description in
                    typographyItem(name, font, description)
                }
            }
        }
    }
    
    private func typographyItem(_ name: String, _ font: Font, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(FOMOTheme.Typography.headline)
                    .foregroundColor(FOMOTheme.Colors.text)
                
                Spacer()
                
                Text(description)
                    .font(FOMOTheme.Typography.caption1)
                    .foregroundColor(FOMOTheme.Colors.textSecondary)
            }
            
            Text("The quick brown fox jumps over the lazy dog")
                .font(font)
                .foregroundColor(FOMOTheme.Colors.text)
            
            Divider()
        }
    }
}

// MARK: - Component Showcase View
struct ThemeComponentShowcase: View {
    @State private var textFieldValue = "Input Text"
    @State private var toggleValue = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                sectionHeader("UI Components")
                
                buttonSection
                
                cardSection
                
                inputSection
                
                toggleSection
            }
            .padding()
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(FOMOTheme.Typography.headlineLarge)
                .foregroundColor(FOMOTheme.Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
        }
    }
    
    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buttons")
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            VStack(spacing: 16) {
                // Primary Button
                Button("Primary Button") { }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, FOMOTheme.Spacing.small)
                    .background(FOMOTheme.Colors.primary)
                    .foregroundColor(FOMOTheme.Colors.text)
                    .cornerRadius(FOMOTheme.Radius.medium)
                
                // Secondary Button
                Button("Secondary Button") { }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, FOMOTheme.Spacing.small)
                    .background(FOMOTheme.Colors.surface)
                    .foregroundColor(FOMOTheme.Colors.primary)
                    .cornerRadius(FOMOTheme.Radius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                            .stroke(FOMOTheme.Colors.primary, lineWidth: 1)
                    )
                
                // Disabled Button
                Button("Disabled Button") { }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, FOMOTheme.Spacing.small)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(Color.gray)
                    .cornerRadius(FOMOTheme.Radius.medium)
                    .disabled(true)
            }
        }
    }
    
    private var cardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cards")
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            VStack(spacing: 16) {
                // Basic Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Basic Card")
                        .font(FOMOTheme.Typography.headline)
                        .foregroundColor(FOMOTheme.Colors.text)
                    
                    Text("This is a basic card component with standard styling applied.")
                        .font(FOMOTheme.Typography.body)
                        .foregroundColor(FOMOTheme.Colors.text)
                }
                .padding(FOMOTheme.Spacing.medium)
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.medium)
                
                // Card with Image
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                    
                    Text("Card with Image")
                        .font(FOMOTheme.Typography.headline)
                        .foregroundColor(FOMOTheme.Colors.text)
                    
                    Text("This card includes an image placeholder at the top.")
                        .font(FOMOTheme.Typography.body)
                        .foregroundColor(FOMOTheme.Colors.text)
                }
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.medium)
                .shadow(color: FOMOTheme.Shadow.medium, radius: 4, x: 0, y: 2)
            }
        }
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Text Inputs")
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            VStack(spacing: 16) {
                // Standard Text Field
                TextField("Standard Input", text: $textFieldValue)
                    .padding()
                    .background(FOMOTheme.Colors.surface)
                    .cornerRadius(FOMOTheme.Radius.small)
                
                // Secure Field
                SecureField("Password Input", text: $textFieldValue)
                    .padding()
                    .background(FOMOTheme.Colors.surface)
                    .cornerRadius(FOMOTheme.Radius.small)
            }
        }
    }
    
    private var toggleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Toggles & Controls")
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            Toggle("Toggle Option", isOn: $toggleValue)
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
        }
    }
}

// MARK: - Spacing Showcase View
struct ThemeSpacingShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                sectionHeader("Layout System")
                
                spacingSection
                
                radiusSection
                
                gridSection
            }
            .padding()
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(FOMOTheme.Typography.headlineLarge)
                .foregroundColor(FOMOTheme.Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
        }
    }
    
    private var spacingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spacing")
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            VStack(spacing: 20) {
                spacingItem("xxSmall", FOMOTheme.Spacing.xxSmall)
                spacingItem("small", FOMOTheme.Spacing.small)
                spacingItem("medium", FOMOTheme.Spacing.medium)
                spacingItem("large", FOMOTheme.Spacing.large)
                spacingItem("xLarge", FOMOTheme.Spacing.xLarge)
                spacingItem("xxLarge", FOMOTheme.Spacing.xxLarge)
            }
        }
    }
    
    private func spacingItem(_ name: String, _ spacing: CGFloat) -> some View {
        HStack {
            Text(name)
                .font(FOMOTheme.Typography.headline)
                .foregroundColor(FOMOTheme.Colors.text)
                .frame(width: 100, alignment: .leading)
            
            Text("\(Int(spacing))pt")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
                .frame(width: 50)
            
            Rectangle()
                .fill(FOMOTheme.Colors.primary)
                .frame(width: spacing, height: 40)
            
            Spacer()
        }
    }
    
    private var radiusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Corner Radius")
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            HStack(spacing: 20) {
                radiusItem("small", FOMOTheme.Radius.small)
                radiusItem("medium", FOMOTheme.Radius.medium)
                radiusItem("large", FOMOTheme.Radius.large)
            }
        }
    }
    
    private func radiusItem(_ name: String, _ radius: CGFloat) -> some View {
        VStack {
            Rectangle()
                .fill(FOMOTheme.Colors.primary)
                .frame(width: 80, height: 80)
                .cornerRadius(radius)
            
            Text(name)
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.text)
            
            Text("\(Int(radius))pt")
                .font(FOMOTheme.Typography.caption2)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
    }
    
    private var gridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Grid & Layout")
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            // Simple grid example
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(1..<5) { index in
                    Rectangle()
                        .fill(FOMOTheme.Colors.primary.opacity(0.7))
                        .frame(height: 80)
                        .overlay(
                            Text("Item \(index)")
                                .foregroundColor(.white)
                        )
                }
            }
            
            Text("2-column grid with 16pt spacing")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
        }
    }
}

// MARK: - Settings View
struct ThemeSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                sectionHeader("Theme Settings")
                
                themeSelectionSection
                
                debuggingTools
            }
            .padding()
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(FOMOTheme.Typography.headlineLarge)
                .foregroundColor(FOMOTheme.Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
        }
    }
    
    private var themeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Theme")
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            ForEach(ThemeType.allCases) { themeType in
                themeButton(for: themeType)
            }
        }
    }
    
    private func themeButton(for themeType: ThemeType) -> some View {
        Button(action: {
            themeManager.selectedThemeType = themeType
        }) {
            HStack {
                Text(themeType.rawValue)
                    .font(FOMOTheme.Typography.headline)
                    .foregroundColor(FOMOTheme.Colors.text)
                
                Spacer()
                
                if themeManager.selectedThemeType == themeType {
                    Image(systemName: "checkmark")
                        .foregroundColor(FOMOTheme.Colors.primary)
                }
            }
            .padding()
            .background(FOMOTheme.Colors.surface)
            .cornerRadius(FOMOTheme.Radius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                    .stroke(
                        themeManager.selectedThemeType == themeType ? 
                            FOMOTheme.Colors.primary : 
                            Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var debuggingTools: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Debugging Tools")
                .font(FOMOTheme.Typography.headlineSmall)
                .foregroundColor(FOMOTheme.Colors.text)
            
            Button(action: {
                // Toggle layout guides
            }) {
                HStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(FOMOTheme.Colors.primary)
                    
                    Text("Toggle Layout Guides")
                        .font(FOMOTheme.Typography.headline)
                        .foregroundColor(FOMOTheme.Colors.text)
                    
                    Spacer()
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.medium)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                // Show color palette
            }) {
                HStack {
                    Image(systemName: "paintpalette")
                        .foregroundColor(FOMOTheme.Colors.primary)
                    
                    Text("Show Color Palette")
                        .font(FOMOTheme.Typography.headline)
                        .foregroundColor(FOMOTheme.Colors.text)
                    
                    Spacer()
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.medium)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Missing Type Definitions
enum ThemeType: String, CaseIterable, Identifiable {
    case light, dark, system
    
    var id: String { self.rawValue }
}

struct TypographySystem {
    static func registerFonts() {
        // Register custom fonts if needed
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    /// Singleton instance
    static let shared = ThemeManager()
    
    /// Currently selected theme type
    @Published var selectedThemeType: ThemeType = .system {
        didSet {
            UserDefaults.standard.set(selectedThemeType.rawValue, forKey: "selectedTheme")
            updateActiveTheme()
            objectWillChange.send()
        }
    }
    
    private init() {
        // Load saved theme preference
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let themeType = ThemeType(rawValue: savedTheme) {
            self.selectedThemeType = themeType
        } else {
            self.selectedThemeType = .system
        }
    }
    
    private func updateActiveTheme() {
        // Here we would update active theme colors
        // This is a placeholder for actual theme switching logic
    }
} 