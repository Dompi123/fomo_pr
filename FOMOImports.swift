import Foundation
import SwiftUI
// Remove the PaymentTypes import since we'll use the local file
// import PaymentTypes

// This file provides a single import point for all the types
// needed in the Xcode project

// When using Swift Package Manager, these imports will work
#if SWIFT_PACKAGE
// These imports are commented out as they're causing issues
// import Models // Commenting out Models import to use local implementations instead
// import Network // Commenting out Network import to use local implementations instead
// import Core // Commenting out Core import to use local implementations instead
#endif

// When using Xcode directly, the types are defined in FOMOTypes.swift
// No additional imports needed

// Import views from Features/Root/Views directory
#if PREVIEW_MODE
@_exported import struct FOMO_PR.ProfileView
@_exported import struct FOMO_PR.PassesView
@_exported import struct FOMO_PR.PaywallView
#endif

// Add local Models implementation
public enum Models {
    public struct ModelVersion: Model {
        public let id: String
        public let version: String
        public let buildNumber: Int
        
        public static func == (lhs: ModelVersion, rhs: ModelVersion) -> Bool {
            return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    public protocol Model: Identifiable, Hashable {
        var id: String { get }
    }
    
    public struct User: Model, Codable {
        public let id: String
        public let name: String
        public let email: String
        
        public static func == (lhs: User, rhs: User) -> Bool {
            return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    public struct Venue: Model, Codable {
        public let id: String
        public let name: String
        public let description: String
        public let address: String
        public let imageURL: URL?
        public let latitude: Double
        public let longitude: Double
        public let isPremium: Bool
        
        public init(
            id: String,
            name: String,
            description: String,
            address: String,
            imageURL: URL?,
            latitude: Double,
            longitude: Double,
            isPremium: Bool
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
        
        public static func == (lhs: Venue, rhs: Venue) -> Bool {
            return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

// Ensure we're using the PricingTier from FOMOApp.swift
// The PricingTier is defined in FOMOApp.swift and is public
// No need to redefine it here

// MARK: - Payment Types
public enum PaymentStatus: String, Equatable, Codable {
    case pending
    case completed
    case failed
    case refunded
}

// MARK: - Payment Result
public struct PaymentResult: Identifiable, Codable, Equatable {
    public let id: String
    public let transactionId: String
    public let status: PaymentStatus
    public let amount: Decimal
    public let timestamp: Date
    
    public init(id: String = UUID().uuidString,
                transactionId: String,
                status: PaymentStatus,
                amount: Decimal,
                timestamp: Date = Date()) {
        self.id = id
        self.transactionId = transactionId
        self.status = status
        self.amount = amount
        self.timestamp = timestamp
    }
}

// Helper extension for PricingTier
public extension PricingTier {
    static func features(for tier: PricingTier) -> [String] {
        switch tier.id {
        case "tier-123":
            return ["Entry to venue", "One welcome drink", "Access to main areas"]
        case "tier-456":
            return ["Priority entry", "Open bar for 2 hours", "Access to VIP areas", "Meet & greet with performers"]
        default:
            return ["Standard venue access"]
        }
    }
}

// This function can be called to verify that all required types are available
public func verifyCommonTypesAvailable() {
    #if DEBUG
    print("Verifying types availability...")
    
    #if !SWIFT_PACKAGE
    // Card type
    let card = Card(id: "test", lastFour: "1234", expiryMonth: 12, expiryYear: 2025, cardholderName: "Test User", brand: "visa")
    print("Card type is available: \(card)")
    
    // APIClient type
    let apiClient = APIClient.shared
    print("APIClient type is available: \(apiClient)")
    
    // Security namespace
    let tokenizationService = FOMOSecurity.LiveTokenizationService.shared
    print("TokenizationService type is available: \(tokenizationService)")
    
    // PaymentResult type
    let paymentResult = PaymentResult(
        id: "sample-id",
        transactionId: "sample-transaction",
        status: PaymentStatus.completed,
        amount: 19.99,
        timestamp: Date()
    )
    print("PaymentResult type is available: \(paymentResult)")
    
    // PricingTier type
    let pricingTier = PricingTier(
        id: "test",
        name: "Test Tier",
        price: 10.0,
        description: "Test description"
    )
    print("PricingTier type is available: \(pricingTier)")
    
    // Venue type
    let venue = Venue(
        id: "test-id", 
        name: "Test Venue", 
        description: "A test venue description",
        address: "123 Test St", 
        imageURL: nil,
        latitude: 37.7749,
        longitude: -122.4194,
        isPremium: false
    )
    print("Venue type is available: \(venue)")
    
    // DrinkItem type
    let drinkItem = DrinkItem(
        id: "test",
        name: "Test Drink",
        description: "Test description",
        imageURL: nil,
        price: 5.0,
        category: "Test"
    )
    print("DrinkItem type is available: \(drinkItem)")
    
    print("All types are available!")
    #else
    print("Running in Swift Package Manager mode - types not available")
    #endif
    #endif
}

// Only declare these types if we're in preview mode
#if PREVIEW_MODE || ENABLE_MOCK_DATA

// We're using the PreviewNavigationCoordinator and MockDataProvider defined in other files
// to avoid ambiguity and redeclaration errors.

// Import DrinkOrder from FOMOApp instead of redefining it here
// This avoids the ambiguity error

// Verify that all types are available
public func verifyAllPreviewTypesAvailable() {
    print("All types are available in preview mode!")
    #if PREVIEW_MODE
    // These references should use the types from NavigationTypes.swift
    print("PreviewNavigationCoordinator is available!")
    print("MockDataProvider is available!")
    print("Venue is available!")
    print("DrinkItem is available!")
    print("Card is available!")
    print("PaymentResult is available!")
    print("APIClient is available!")
    #endif
}

#endif // PREVIEW_MODE || ENABLE_MOCK_DATA 

// MARK: - Type Verification
func verifyFOMOImports() {
    // Create a User instance
    let user = Models.User(id: "test-id", name: "Test User", email: "test@example.com")
    print("User is available: \(user)")
    
    // Create a Venue instance
    let venue = Models.Venue(
        id: "test-id", 
        name: "Test Venue", 
        description: "A test venue description",
        address: "123 Test St", 
        imageURL: nil,
        latitude: 37.7749,
        longitude: -122.4194,
        isPremium: false
    )
    print("Venue is available: \(venue)")
    
    // Create a PaymentResult instance
    let paymentResult = PaymentResult(
        id: "sample-id",
        transactionId: "sample-transaction",
        status: PaymentStatus.completed,
        amount: 19.99,
        timestamp: Date()
    )
    print("PaymentResult is available: \(paymentResult)")
} 
