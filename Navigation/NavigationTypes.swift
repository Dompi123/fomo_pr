//
// NavigationTypes.swift
// FOMO_PR
//
// Navigation destination types for the app.
//

import SwiftUI
import Models

/// Defines the different sheet destinations that can be presented in the app
public enum Sheet: Identifiable {
    /// User profile screen
    case profile
    
    /// App settings screen
    case settings
    
    /// Payment configuration screen
    case payment
    
    /// Detailed view for a specific drink
    case drinkDetails(DrinkItem)
    
    /// Checkout flow for an order
    case checkout(order: Order)
    
    /// Paywall screen for a specific venue
    case paywall(venue: Venue)
    
    /// Drink menu for a specific venue
    case drinkMenu(venue: Venue)
    
    /// Design system showcase
    case designSystem
    
    /// Unique identifier for each sheet destination
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

/// Route destinations for hierarchical navigation
public enum Route {
    /// Venue details screen
    case venueDetails(Venue)
    
    /// User profile screen
    case userProfile
    
    /// Search results screen
    case search(query: String)
}

/// Navigation state object to pass around
public struct NavigationState {
    /// Current navigation path
    public var path = NavigationPath()
    
    /// Currently presented sheet
    public var presentedSheet: Sheet?
    
    /// Initialize with default empty state
    public init() {}
} 