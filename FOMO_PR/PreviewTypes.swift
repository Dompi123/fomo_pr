import Foundation
import SwiftUI

// This file imports all the types needed for preview mode
// It should be imported in any file that needs to use these types

#if PREVIEW_MODE
// Import all the type definition files
@_exported import struct FOMO_PR.Card
@_exported import enum FOMO_PR.FOMOSecurity
@_exported import struct FOMO_PR.PricingTier
@_exported import enum FOMO_PR.PaymentStatus
@_exported import struct FOMO_PR.PaymentResult
@_exported import struct FOMO_PR.DrinkItem
@_exported import struct FOMO_PR.DrinkOrder
@_exported import struct FOMO_PR.Venue
@_exported import class FOMO_PR.PreviewNavigationCoordinator
@_exported import class FOMO_PR.MockDataProvider

// Define a function to verify that all types are imported correctly
public func verifyAllTypesImported() {
    print("Verifying all types are imported correctly...")
    
    // Verify security types
    verifySecurityTypes()
    
    // Verify pricing types
    verifyPricingTypes()
    
    // Verify venue types
    verifyVenueTypes()
    
    // Verify navigation types
    verifyNavigationTypes()
    
    print("All types are imported correctly!")
}
#endif