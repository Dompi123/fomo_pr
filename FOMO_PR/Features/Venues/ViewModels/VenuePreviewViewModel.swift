import Foundation
import SwiftUI
// import FOMO_PR - Commenting out as it's causing issues

// MARK: - Base View Model

class BaseViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    func simulateNetworkDelay() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        } catch {
            // Ignore cancellation errors
        }
    }
}

// MARK: - Models

struct Venue: Identifiable {
    let id: String
    let name: String
    let description: String
    let location: String
    let imageURL: URL?
}

extension Venue {
    static var preview: Venue {
        Venue(
            id: "venue-123",
            name: "The Grand Ballroom",
            description: "A luxurious venue for all your special events",
            location: "123 Main Street, New York, NY",
            imageURL: URL(string: "https://example.com/venue.jpg")
        )
    }
}

// MARK: - View Model

class VenuePreviewViewModel: ObservableObject {
    @Published var venue: Venue?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let venueId: String
    
    init(venueId: String) {
        self.venueId = venueId
        loadVenueDetails()
    }
    
    func loadVenueDetails() {
        isLoading = true
        error = nil
        
        Task {
            do {
                await simulateNetworkDelay()
                
                // In a real app, this would fetch venue details from an API
                // For now, we'll use mock data
                let venue = getMockVenueDetails(id: venueId)
                
                await MainActor.run {
                    self.venue = venue
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    private func simulateNetworkDelay() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        } catch {
            // Ignore cancellation errors
        }
    }
}

// MARK: - Mock Data

func getMockVenueDetails(id: String) -> Venue {
    Venue(
        id: id,
        name: "The Grand Ballroom",
        description: "A luxurious venue for all your special events",
        location: "123 Main Street, New York, NY",
        imageURL: URL(string: "https://example.com/venue.jpg")
    )
}

func getMockPricingTiers(venueId: String) -> [PricingTier] {
    return [
        PricingTier(id: "1", name: "Basic Pass", price: Decimal(19.99), description: "Access to the venue"),
        PricingTier(id: "2", name: "VIP Pass", price: Decimal(49.99), description: "Premium access with perks")
    ]
}

func processMockPayment(amount: Decimal) -> Bool {
    // Simulate successful payment
    return true
}

// MARK: - Preview Helper

extension VenuePreviewViewModel {
    static func preview() -> VenuePreviewViewModel {
        let viewModel = VenuePreviewViewModel(venueId: "venue-123")
        viewModel.venue = Venue(
            id: "venue-123",
            name: "The Grand Ballroom",
            description: "A luxurious venue for all your special events",
            location: "123 Main Street, New York, NY",
            imageURL: URL(string: "https://example.com/venue.jpg")
        )
        return viewModel
    }
} 
