import Foundation
import SwiftUI
import Network
import Models

// Diagnostic prints to verify module imports
#if DEBUG
public func printModuleInfo() {
    print("Core module loaded")
    print("Network module types available")
    print("Models module types available")
    
    // Try to access specific types
    let apiClientType = Network.APIClient.self
    print("APIClient type: \(apiClientType)")
    
    let cardType = Models.Card.self
    print("Card type: \(cardType)")
    
    // Check for PaymentResult type
    #if canImport(Models)
    if let paymentResultType = Models.PaymentResult.self as Any.Type? {
        print("PaymentResult type found in Models: \(paymentResultType)")
    } else {
        print("PaymentResult type not found in Models")
    }
    #endif
    
    // Network module doesn't have PaymentResult
    print("PaymentResult not expected in Network module")
    
    // Core module doesn't have PaymentResult directly
    print("PaymentResult accessed through Models in Core module")
    
    // Log TokenizationService availability
    logTokenizationServiceAvailability()
    
    // Log Security namespace availability
    logSecurityNamespaceAvailability()
    
    // Log PaymentResult availability
    Models.logPaymentResultAvailability()
}
#endif

// Re-export Network types
@_exported import Network
public typealias APIClient = Network.APIClient

// Re-export Models types
@_exported import Models
public typealias Card = Models.Card
public typealias PaymentResult = Models.PaymentResult
public typealias PaymentStatus = Models.PaymentStatus 