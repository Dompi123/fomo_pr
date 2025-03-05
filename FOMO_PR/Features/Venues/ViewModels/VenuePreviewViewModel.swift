import Foundation
import SwiftUI
import Combine
// import Models // Commenting out Models import to use local implementations instead
// import Core // Commenting out Core import to use local implementations instead

// Define the BaseViewModel class
// Remove this local definition since we're using the core BaseViewModel
/*
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    
    func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.isLoading = loading
        }
    }
    
    func setError(_ error: Error?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
}
*/

// Define the Venue struct
// Remove this local definition since we're using the core Venue model
/*
struct Venue: Identifiable {
    let id: String
    let name: String
    let description: String
    let location: String
    let imageURL: URL?
}
*/

// Add extension for location property since it's not in the core Venue model
extension Venue {
    var locationString: String {
        return address
    }
    
    // For backward compatibility
    var isOpen: Bool {
        return true // Default to open since isOpenNow is no longer available
    }
}

// Define the VenuePreviewViewModel class
class VenuePreviewViewModel: ObservableObject {
    @Published var venue: Venue?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedTab = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(venueId: String) {
        loadVenue(id: venueId)
    }
    
    init(venue: Venue) {
        self.venue = venue
    }
    
    func loadVenue(id: String) {
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            self.venue = self.createMockVenue()
            self.isLoading = false
        }
    }
    
    func refreshVenue() {
        guard let venue = venue else { return }
        loadVenue(id: venue.id)
    }
    
    // Helper function to create a mock venue
    private func createMockVenue() -> Venue {
        return Venue(
            id: "venue_123",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, San Francisco, CA 94105",
            imageURL: URL(string: "https://example.com/venue.jpg"),
            latitude: 37.7749,
            longitude: -122.4194,
            isPremium: true
        )
    }
}

// Remove the APIClient class and replace with simple functions to get mock data
func getMockVenueDetails(id: String) -> Venue {
    // Return a default venue
    return Venue(
        id: id,
        name: "Sample Venue",
        description: "A sample venue description",
        address: "123 Main St, New York, NY",
        imageURL: URL(string: "https://example.com/venue.jpg"),
        latitude: 40.7128,
        longitude: -74.0060,
        isPremium: true
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
    static var preview: VenuePreviewViewModel {
        let viewModel = VenuePreviewViewModel(venueId: "1")
        viewModel.venue = Venue(
            id: "1",
            name: "The Rooftop",
            description: "A beautiful rooftop bar with amazing views",
            address: "123 Main St, New York, NY",
            imageURL: URL(string: "https://example.com/image.jpg"),
            latitude: 40.7128,
            longitude: -74.0060,
            isPremium: true
        )
        return viewModel
    }
} 
