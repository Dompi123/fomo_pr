import Foundation
import SwiftUI
import Models
// import FOMO_PR - Commenting out as it's causing issues

// Define the PaywallError enum
enum PaywallError: Error, Identifiable {
    case noPricingTiers
    case noSelectedTier
    case paymentFailed(String)
    
    var id: String {
        switch self {
        case .noPricingTiers: return "noPricingTiers"
        case .noSelectedTier: return "noSelectedTier"
        case .paymentFailed(let reason): return "paymentFailed-\(reason)"
        }
    }
    
    var message: String {
        switch self {
        case .noPricingTiers: return "Unable to load pricing tiers. Please try again."
        case .noSelectedTier: return "Please select a pricing tier."
        case .paymentFailed(let reason): return "Payment failed: \(reason)"
        }
    }
}

// MARK: - Models

// Use the PricingTier from FOMOTypes.swift instead of defining it here
// struct PricingTier: Identifiable {
//     let id: String
//     let name: String
//     let price: Double
//     let description: String
//     let features: [PricingTierFeature]
// }

// Keep this struct as it's not defined elsewhere
struct PricingTierFeature: Identifiable {
    let id: String
    let name: String
}

// Comment out or remove duplicate definitions
/*
struct Venue: Identifiable {
    let id: String
    let name: String
    let description: String
    let address: String
    let imageURL: String
    let rating: Double
    let priceLevel: Int
    let category: String
    let isOpen: Bool
    let distance: Double?
}

extension Venue {
    static var preview: Venue {
        Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, New York, NY 10001",
            imageURL: "https://example.com/venue1.jpg",
            rating: 4.7,
            priceLevel: 3,
            category: "Bar",
            isOpen: true,
            distance: 0.5
        )
    }
}
*/

// Wrapper class for PricingTier to add features
class EnhancedPricingTier {
    let tier: PricingTier
    let features: [String]
    
    init(tier: PricingTier, features: [String]) {
        self.tier = tier
        self.features = features
    }
    
    // Convenience initializer
    init(id: String, name: String, price: Double, description: String, features: [String]) {
        self.tier = PricingTier(id: id, name: name, price: Decimal(price), description: description)
        self.features = features
    }
    
    // Forward properties from the wrapped tier
    var id: String { tier.id }
    var name: String { tier.name }
    var price: Decimal { tier.price }
    var description: String { tier.description }
}

// MARK: - View Model

class PaywallViewModel: ObservableObject {
    let venue: String
    
    @Published var selectedTier: EnhancedPricingTier?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var tiers: [EnhancedPricingTier] = []
    @Published var purchaseCompleted: Bool = false
    
    init(venue: String) {
        self.venue = venue
        loadTiers()
    }
    
    func loadTiers() {
        isLoading = true
        error = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: DispatchWorkItem {
            // In a real app, this would fetch pricing tiers from an API
            // For now, we'll use mock data
            self.tiers = [
                EnhancedPricingTier(
                    id: "basic",
                    name: "Basic Pass",
                    price: 19.99,
                    description: "Access to the venue for one day",
                    features: ["Entry to main areas", "Access to basic amenities"]
                ),
                EnhancedPricingTier(
                    id: "premium",
                    name: "Premium Pass",
                    price: 49.99,
                    description: "Full access to the venue for one day",
                    features: ["Entry to all areas", "Complimentary drink", "Priority entry", "Access to VIP lounge"]
                ),
                EnhancedPricingTier(
                    id: "vip",
                    name: "VIP Pass",
                    price: 99.99,
                    description: "Ultimate experience for one day",
                    features: ["Entry to all areas", "Open bar", "Meet & greet with artists", "Exclusive merchandise", "Priority entry", "Access to VIP lounge"]
                )
            ]
            
            self.isLoading = false
        })
    }
    
    func selectTier(_ tier: EnhancedPricingTier) {
        selectedTier = tier
    }
    
    func purchasePass() {
        guard let selectedTier = selectedTier else {
            error = NSError(domain: "PaywallViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No tier selected"])
            return
        }
        
        isLoading = true
        error = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: DispatchWorkItem {
            // In a real app, this would process the payment through a payment gateway
            // For now, we'll simulate a successful payment
            
            // Simulate a 90% success rate
            let randomNumber = Int.random(in: 1...10)
            if randomNumber == 1 {
                self.error = NSError(domain: "PaywallViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Payment failed. Please try again."])
                self.isLoading = false
                return
            }
            
            self.purchaseCompleted = true
            self.isLoading = false
        })
    }
}

// MARK: - Preview Helper

extension PaywallViewModel {
    static func preview() -> PaywallViewModel {
        let viewModel = PaywallViewModel(venue: "venue-123")
        viewModel.tiers = [
            EnhancedPricingTier(
                id: "basic",
                name: "Basic Pass",
                price: 19.99,
                description: "Access to the venue for one day",
                features: ["Entry to main areas", "Access to basic amenities"]
            ),
            EnhancedPricingTier(
                id: "premium",
                name: "Premium Pass",
                price: 49.99,
                description: "Full access to the venue for one day",
                features: ["Entry to all areas", "Complimentary drink", "Priority entry", "Access to VIP lounge"]
            )
        ]
        return viewModel
    }
}

// Fix the extension with stored properties error by moving the property to a struct or class
struct TierFeaturesContainer {
    var tierFeatures: [String] = []
}

// Remove the stored property from the extension
extension PricingTier {
    // Use computed properties in extensions instead of stored properties
    var featuresContainer: TierFeaturesContainer {
        let container = TierFeaturesContainer()
        return container
    }
    
    // Other computed properties or methods can stay here
} 

