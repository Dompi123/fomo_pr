import Foundation
import SwiftUI

// This file provides a single import point for all the types
// needed in the Xcode project

// When using Swift Package Manager, these imports will work
#if SWIFT_PACKAGE
// These imports are commented out as they're causing issues
// import Models
// import Network
// import Core
#endif

// When using Xcode directly, the types are defined in FOMOTypes.swift
// No additional imports needed

// This function can be called to verify that all required types are available
public func verifyTypesAvailable() {
    #if DEBUG
    print("Verifying types availability...")
    
    #if !SWIFT_PACKAGE
    // Card type
    let card = Card(id: "test", last4: "1234", brand: Card.CardBrand.visa, expiryMonth: 12, expiryYear: 2025)
    print("Card type is available: \(card)")
    
    // APIClient type
    let apiClient = APIClient.shared
    print("APIClient type is available: \(apiClient)")
    
    // Security namespace
    let tokenizationService = Security.LiveTokenizationService.shared
    print("TokenizationService type is available: \(tokenizationService)")
    
    // PaymentResult type
    let paymentResult = PaymentResult(
        transactionId: "test",
        amount: 10.0,
        status: PaymentStatus.success
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
    
    print("All types are available!")
    #else
    print("Running in Swift Package Manager mode - types not available")
    #endif
    #endif
} 
