//
// NavigationCoordinator.swift
// FOMO_PR
//
// Coordinates navigation throughout the app.
//

import SwiftUI
import OSLog
import Models

/// Protocol for feature availability checking
public protocol FeatureAvailabilityChecking {
    var isPaywallEnabled: Bool { get }
    var isDrinkMenuEnabled: Bool { get }
    var isCheckoutEnabled: Bool { get }
    var isSearchEnabled: Bool { get }
}

/// Default implementation for feature availability
public struct DefaultFeatureAvailability: FeatureAvailabilityChecking {
    public var isPaywallEnabled: Bool
    public var isDrinkMenuEnabled: Bool
    public var isCheckoutEnabled: Bool
    public var isSearchEnabled: Bool
    
    public init(
        isPaywallEnabled: Bool = false,
        isDrinkMenuEnabled: Bool = false,
        isCheckoutEnabled: Bool = false,
        isSearchEnabled: Bool = false
    ) {
        self.isPaywallEnabled = isPaywallEnabled
        self.isDrinkMenuEnabled = isDrinkMenuEnabled
        self.isCheckoutEnabled = isCheckoutEnabled
        self.isSearchEnabled = isSearchEnabled
    }
}

/// Coordinator for managing navigation throughout the app
@MainActor
public final class NavigationCoordinator: ObservableObject {
    // MARK: - Properties
    
    /// Shared instance for use in preview mode
    public static let shared = NavigationCoordinator()
    
    /// Logger for debugging navigation events
    private let logger = Logger(subsystem: "com.fomo.pr", category: "Navigation")
    
    /// Current navigation path
    @Published public var path = NavigationPath()
    
    /// Currently presented sheet
    @Published public var presentedSheet: Sheet?
    
    /// Feature availability checker
    private let featureAvailability: FeatureAvailabilityChecking
    
    // MARK: - Initialization
    
    /// Creates a navigation coordinator with specified feature availability
    /// - Parameter featureAvailability: Checker for feature availability
    public init(featureAvailability: FeatureAvailabilityChecking = DefaultFeatureAvailability()) {
        self.featureAvailability = featureAvailability
        logger.debug("NavigationCoordinator initialized")
    }
    
    // MARK: - Navigation Methods
    
    /// Presents a sheet with the specified destination
    /// - Parameter destination: The sheet destination to present
    public func navigate(to destination: Sheet) {
        logger.debug("Navigating to sheet: \(destination.id)")
        presentedSheet = destination
    }
    
    /// Navigates to venue details view
    /// - Parameter venue: The venue to display
    public func navigateToVenueDetails(venue: Venue) {
        logger.debug("Navigating to venue details: \(venue.name)")
        // In a real app, this would modify the navigation path
        print("Navigating to venue details: \(venue.name)")
    }
    
    /// Navigates to the drink menu for a venue if enabled
    /// - Parameter venue: The venue whose drink menu to display
    public func navigateToDrinkMenu(venue: Venue) {
        if featureAvailability.isDrinkMenuEnabled {
            navigate(to: .drinkMenu(venue: venue))
        } else {
            logger.debug("Drink menu is disabled")
        }
    }
    
    /// Navigates to the paywall for a venue if enabled
    /// - Parameter venue: The venue whose paywall to display
    public func navigateToPaywall(venue: Venue) {
        if featureAvailability.isPaywallEnabled {
            navigate(to: .paywall(venue: venue))
        } else {
            logger.debug("Paywall is disabled")
        }
    }
    
    /// Navigates to checkout with an order if enabled
    /// - Parameter order: The order to check out
    public func navigateToCheckout(order: Order) {
        if featureAvailability.isCheckoutEnabled {
            navigate(to: .checkout(order: order))
        } else {
            logger.debug("Checkout is disabled")
        }
    }
    
    /// Navigates to the design system showcase
    public func navigateToDesignSystem() {
        navigate(to: .designSystem)
    }
    
    /// Dismisses the current sheet
    public func dismissSheet() {
        presentedSheet = nil
    }
    
    /// Navigates back one level in the navigation stack or dismisses the sheet
    public func goBack() {
        if !path.isEmpty {
            path.removeLast()
        } else {
            presentedSheet = nil
        }
    }
} 