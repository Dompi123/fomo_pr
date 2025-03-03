import Foundation
import SwiftUI
// import FOMO_PR - Commenting out as it's causing issues
import Models
import Core

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
    var location: String {
        return address
    }
}

// Define the VenuePreviewViewModel class
class VenuePreviewViewModel: ObservableObject {
    @Published var venue: Venue?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let venueId: String
    
    init(venueId: String) {
        self.venueId = venueId
        loadVenueDetails()
    }
    
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
    
    func loadVenueDetails() {
        setLoading(true)
        setError(nil)
        
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                let venue: Venue = try await getMockVenueDetails(id: venueId)
                
                DispatchQueue.main.async {
                    self.venue = venue
                    self.setLoading(false)
                }
            } catch {
                setError(error)
                setLoading(false)
            }
        }
    }
}

// Remove the APIClient class and replace with simple functions to get mock data
func getMockVenueDetails(id: String) -> Venue {
    if id == "venue-123" {
        return Venue.preview
    }
    
    // Return a default venue
    return Venue(
        id: id,
        name: "Sample Venue",
        description: "A sample venue description",
        address: "123 Main St, New York, NY",
        capacity: 200,
        currentOccupancy: 100,
        waitTime: 15,
        imageURL: "https://example.com/venue.jpg",
        latitude: 40.7128,
        longitude: -74.0060,
        openingHours: "Mon-Sun: 10AM-10PM",
        tags: ["Sample", "Venue"],
        rating: 4.2,
        isOpen: true
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
            capacity: 150,
            currentOccupancy: 75,
            waitTime: 20,
            imageURL: "https://example.com/image.jpg",
            latitude: 40.7128,
            longitude: -74.0060,
            openingHours: "5PM - 2AM",
            tags: ["Rooftop", "Cocktails", "Views"],
            rating: 4.5,
            isOpen: true
        )
        return viewModel
    }
} 
