import Foundation

// This file explicitly exports all public types from the Models module
// to ensure they are visible to other modules

// Re-export Foundation types
@_exported import struct Foundation.URL
@_exported import struct Foundation.Data
@_exported import struct Foundation.Decimal
@_exported import struct Foundation.Date
@_exported import struct Foundation.UUID

// Explicitly export our types
// No need for explicit typealias as these types are already public in their respective files
// This is just to ensure the compiler knows these types should be exported
public typealias ModelCard = Card
public typealias ModelPaymentResult = PaymentResult
public typealias ModelPaymentStatus = PaymentStatus
public typealias ModelVenue = Venue
public typealias ModelDrink = Drink
public typealias ModelPass = Pass
public typealias ModelPricingTier = PricingTier
public typealias ModelProfile = Profile 