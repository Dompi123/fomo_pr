import Foundation
import SwiftUI

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

// Add local Models implementation
public enum Models {
    public struct ModelVersion {
        public static let version = "1.0.0"
        
        public static func getVersionInfo() -> String {
            return "Models Framework Version \(version)"
        }
    }
    
    public protocol Model {
        var id: String { get }
        var createdAt: Date { get }
        var updatedAt: Date { get }
    }
    
    public struct User: Model, Codable {
        public let id: String
        public let username: String
        public let email: String
        public let createdAt: Date
        public let updatedAt: Date
        
        public init(id: String, username: String, email: String, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.username = username
            self.email = email
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
    
    public struct Venue: Model, Codable {
        public let id: String
        public let name: String
        public let address: String
        public let createdAt: Date
        public let updatedAt: Date
        
        public init(id: String, name: String, address: String, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.name = name
            self.address = address
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

// This function can be called to verify that all required types are available
public func verifyTypesAvailable() {
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
    let tokenizationService = Security.LiveTokenizationService.shared
    print("TokenizationService type is available: \(tokenizationService)")
    
    // PaymentResult type has been removed
    // let paymentResult = PaymentResult(
    //     transactionId: "test",
    //     amount: 10.0,
    //     status: PaymentStatus.success
    // )
    
    // PricingTier type
    let pricingTier = PricingTier(
        id: "test",
        name: "Test Tier",
        price: 10.0,
        description: "Test description"
    )
    print("PricingTier type is available: \(pricingTier)")
    
    print("All types are available!")
    #else
    print("Running in Swift Package Manager mode - types not available")
    #endif
    #endif
} 
