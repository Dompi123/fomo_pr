import Foundation
import SwiftUI
import Combine

// Comment out problematic imports that cause ambiguity
// import FOMOTypes
// import PricingTypes
// import SecurityTypes
// import PaymentTypes

enum PaywallError: Error, LocalizedError {
    case networkError
    case paymentProcessingFailed
    case invalidPricingData
    case userCancelled
    case securityContextInvalid
    case subscriptionAlreadyActive
    case serverError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection error. Please check your internet connection and try again."
        case .paymentProcessingFailed:
            return "Payment processing failed. Please try again or use a different payment method."
        case .invalidPricingData:
            return "Invalid pricing data. Please contact support."
        case .userCancelled:
            return "Payment cancelled by user."
        case .securityContextInvalid:
            return "Security verification failed. Please restart the app and try again."
        case .subscriptionAlreadyActive:
            return "You already have an active subscription for this venue."
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown:
            return "An unknown error occurred. Please try again later."
        }
    }
}

// Add the missing PricingTierFeature type
public struct PricingTierFeature: Identifiable, Codable, Hashable {
    public var id: String
    public var name: String
    public var description: String
    
    public init(id: String, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
    
    // Static method to get features for a tier
    public static func features(for tier: PricingTier) -> [PricingTierFeature] {
        // Generate mock features based on the tier name
        let featureCount = tier.name.lowercased().contains("premium") ? 5 : 3
        var features: [PricingTierFeature] = []
        
        for i in 1...featureCount {
            let featureName = "Feature \(i) for \(tier.name)"
            features.append(PricingTierFeature(id: UUID().uuidString, name: featureName, description: featureName))
        }
        
        return features
    }
}

@available(iOS 15.0, macOS 12.0, *)
public class PaywallViewModel: ObservableObject {
    // Use the Venue type from the main app
    @Published var venue: Venue
    
    // Remove the typealias and use PricingTier directly
    // typealias AppPricingTier = PricingTier
    
    @Published var pricingTiers: [PricingTier] = []
    @Published var selectedTier: PricingTier?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var showAlert: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public var alertMessage: String {
        error?.localizedDescription ?? "An unknown error occurred"
    }
    
    public init(venue: Venue) {
        self.venue = venue
        
        #if PREVIEW_MODE || ENABLE_MOCK_DATA
        // Load mock data for preview mode
        self.loadMockData()
        #endif
    }
    
    private func loadMockData() {
        self.pricingTiers = [
            PricingTier(
                id: "basic",
                name: "Basic Pass",
                price: 19.99,
                description: "Basic venue access"
            ),
            PricingTier(
                id: "premium",
                name: "Premium Pass",
                price: 49.99,
                description: "Premium venue access with perks"
            ),
            PricingTier(
                id: "vip",
                name: "VIP Pass",
                price: 99.99,
                description: "Full VIP experience"
            )
        ]
    }
    
    public func loadPricingTiers(for venueId: String) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        #if PREVIEW_MODE || ENABLE_MOCK_DATA
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            self.loadMockData()
            self.isLoading = false
        }
        #else
        // In a real implementation, this would fetch pricing tiers from an API
        do {
            // Simulate API call
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Mock successful response
            await MainActor.run {
                self.loadMockData()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.showAlert = true
                self.isLoading = false
            }
        }
        #endif
    }
    
    /// Selects a pricing tier
    func selectTier(_ tier: PricingTier) {
        selectedTier = tier
    }
    
    public func processPurchase() async {
        guard selectedTier != nil else {
            await MainActor.run {
                self.error = PaywallError.invalidPricingData
                self.showAlert = true
            }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        #if PREVIEW_MODE || ENABLE_MOCK_DATA
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Simulate successful purchase
        await MainActor.run {
            self.isLoading = false
            // Success notification would happen here
            self.error = nil
        }
        #else
        do {
            // In a real implementation, this would process the payment through a payment gateway
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                self.isLoading = false
                // Success notification would happen here
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.showAlert = true
                self.isLoading = false
            }
        }
        #endif
    }
}

// MARK: - Preview Helper

extension PaywallViewModel {
    static func preview() -> PaywallViewModel {
        let previewVenue = Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, New York, NY 10001",
            imageURL: nil,
            latitude: 40.7128,
            longitude: -74.0060,
            isPremium: true
        )
        
        let viewModel = PaywallViewModel(venue: previewVenue)
        viewModel.pricingTiers = PricingTier.previewTiers
        return viewModel
    }
}

// Fix the extension with stored properties error by using a struct
struct TierFeaturesContainer: Identifiable {
    let id = UUID()
    let tier: PricingTier
    let features: [PricingTierFeature]
    
    init(tier: PricingTier) {
        self.tier = tier
        self.features = PricingTierFeature.features(for: tier)
    }
}

// Extension with computed properties
extension PricingTier {
    // Use computed properties in extensions instead of stored properties
    var featuresContainer: TierFeaturesContainer {
        return TierFeaturesContainer(tier: self)
    }
}

#if DEBUG
struct PaywallViewModel_Previews: PreviewProvider {
    static var previews: some View {
        let previewVenue = Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, New York, NY 10001",
            imageURL: nil,
            latitude: 40.7128,
            longitude: -74.0060,
            isPremium: true
        )
        
        let viewModel = PaywallViewModel(venue: previewVenue)
        viewModel.pricingTiers = PricingTier.previewTiers
        
        // Return a simple Text view instead of PaywallView
        return Text("PaywallViewModel Preview")
            .padding()
    }
}
#endif 

