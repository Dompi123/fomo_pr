import Foundation
import SwiftUI

#if PREVIEW_MODE
// Define the PreviewNavigationCoordinator type for preview mode
public class PreviewNavigationCoordinator: ObservableObject {
    @Published public var currentScreen: Screen = .home
    @Published public var navigationPath = NavigationPath()
    
    public enum Screen {
        case home
        case venueList
        case venueDetail(Venue)
        case drinkDetail(DrinkItem)
        case profile
        case settings
        case paywall(Venue)
        case passPurchase(Venue)
        case passes
        case passDetail(String)
    }
    
    public init() {}
    
    public func navigate(to screen: Screen) {
        self.currentScreen = screen
    }
    
    public func navigateToVenue(_ venue: Venue) {
        navigate(to: .venueDetail(venue))
    }
    
    public func navigateToDrink(_ drink: DrinkItem) {
        navigate(to: .drinkDetail(drink))
    }
    
    public func navigateToPaywall(for venue: Venue) {
        navigate(to: .paywall(venue))
    }
    
    public func navigateToPassPurchase(for venue: Venue) {
        navigate(to: .passPurchase(venue))
    }
    
    public func navigateToPassDetail(id: String) {
        navigate(to: .passDetail(id))
    }
    
    public func navigateToHome() {
        navigate(to: .home)
    }
    
    public func navigateToProfile() {
        navigate(to: .profile)
    }
    
    public func navigateToSettings() {
        navigate(to: .settings)
    }
    
    public func navigateToPasses() {
        navigate(to: .passes)
    }
    
    public func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    public func popToRoot() {
        navigationPath = NavigationPath()
    }
    
    #if DEBUG
    public static var shared = PreviewNavigationCoordinator()
    #endif
}

// Define the MockDataProvider type for preview mode
public class MockDataProvider {
    public static let shared = MockDataProvider()
    
    public var venues: [Venue] = Venue.mockVenues
    public var drinks: [DrinkItem] = DrinkItem.mockDrinks
    public var pricingTiers: [PricingTier] = PricingTier.mockTiers
    
    private init() {}
    
    public func getVenue(id: String) -> Venue? {
        return venues.first { $0.id == id }
    }
    
    public func getDrink(id: String) -> DrinkItem? {
        return drinks.first { $0.id == id }
    }
    
    public func getPricingTier(id: String) -> PricingTier? {
        return pricingTiers.first { $0.id == id }
    }
    
    public func getVenueDrinks(venueId: String) -> [DrinkItem] {
        guard let venue = getVenue(id: venueId) else { return [] }
        return venue.drinks
    }
    
    public func getVenuePricingTiers(venueId: String) -> [PricingTier] {
        return pricingTiers
    }
}
#endif

// Verify that navigation types are available
func verifyNavigationTypes() {
    #if PREVIEW_MODE
    print("PreviewNavigationCoordinator is available in preview mode")
    print("Sample coordinator: \(PreviewNavigationCoordinator.shared)")
    print("MockDataProvider is available in preview mode")
    print("Sample provider: \(MockDataProvider.shared)")
    #else
    print("Using production Navigation module")
    #endif
} 