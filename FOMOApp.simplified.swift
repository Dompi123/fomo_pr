import SwiftUI
import UIKit
import OSLog
import Foundation
import FOMO_PR

// MARK: - Debug Logging
private let logger = Logger(subsystem: "com.fomo.pr", category: "AppInit")

// MARK: - Navigation Types
enum Sheet: Identifiable {
    case profile
    case settings
    case payment
    case drinkDetails(DrinkItem)
    
    var id: String {
        switch self {
        case .profile: return "profile"
        case .settings: return "settings"
        case .payment: return "payment"
        case .drinkDetails(let drink): return "drink_\(drink.id)"
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
    
    public func navigateToVenueDetails(venue: Venue) {
        print("Navigating to venue details: \(venue.name)")
    }
    
    public func navigateToDrinkDetails(drink: DrinkItem) {
        print("Navigating to drink details: \(drink.name)")
    }
    
    public func goBack() {
        if !path.isEmpty {
            path.removeLast()
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

// MARK: - Main App
@main
struct FOMOApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    // Navigation
    @StateObject private var navigationCoordinator = PreviewNavigationCoordinator.shared
    
    // Payment
    @StateObject private var paymentManager = PaymentManager()
    
    // Mock data
    public var pricingTiers: [PricingTier] = [
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
        )
    ]
    
    // Simplified body for preview
    var body: some Scene {
        WindowGroup {
            Text("FOMO Preview App")
                .padding()
                .environmentObject(navigationCoordinator)
                .environmentObject(paymentManager)
        }
    }
} 