import Foundation
import SwiftUI

// This function verifies that all required types are available
// It's called from the TypesTestEntry view
public func verifyTypesAvailable() {
    print("Verifying types availability...")
    
    #if PREVIEW_MODE
    // Verify security types
    verifySecurityTypes()
    
    // Verify pricing types
    verifyPricingTypes()
    
    // Verify venue types
    verifyVenueTypes()
    
    // Verify navigation types
    verifyNavigationTypes()
    
    // Additional verification
    print("\n--- Additional Type Verification ---")
    
    // Card type
    let card = Card(id: "card-123", lastFour: "1234", expiryMonth: 12, expiryYear: 2025, cardholderName: "Test User", brand: "visa")
    print("Card type is available: \(card)")
    
    // APIClient type
    #if !SWIFT_PACKAGE && !XCODE_HELPER
    let apiClient = APIClient.shared
    print("APIClient type is available: \(apiClient)")
    #else
    print("APIClient type is not available in this build configuration")
    #endif
    
    // Security.LiveTokenizationService
    let tokenizationService = FOMOSecurity.LiveTokenizationService.shared
    print("Security.LiveTokenizationService type is available: \(tokenizationService)")
    
    // PaymentResult
    let paymentResult = PaymentResult(id: "payment-123", status: .completed, amount: 10.0, description: "Test payment")
    print("PaymentResult type is available: \(paymentResult)")
    
    // PricingTier
    let pricingTier = PricingTier(id: "test", name: "Test Tier", price: 10.0, description: "Test description")
    print("PricingTier type is available: \(pricingTier)")
    
    // Venue
    let venue = Venue.mockVenues.first!
    print("Venue type is available: \(venue)")
    
    // DrinkItem
    let drinkItem = DrinkItem.mockDrinks.first!
    print("DrinkItem type is available: \(drinkItem)")
    
    // PreviewNavigationCoordinator
    let coordinator = PreviewNavigationCoordinator.shared
    print("PreviewNavigationCoordinator type is available: \(coordinator)")
    
    // MockDataProvider
    let dataProvider = MockDataProvider.shared
    print("MockDataProvider type is available: \(dataProvider)")
    
    print("\nAll types verification completed successfully!")
    #else
    print("Running in non-preview mode. Types may not be available.")
    #endif
} 