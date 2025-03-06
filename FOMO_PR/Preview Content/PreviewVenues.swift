import Foundation
import SwiftUI
import FOMO_PR

#if PREVIEW_MODE || ENABLE_MOCK_DATA
// Create a local struct for preview data to avoid ambiguity
struct PreviewData {
    static var previewDrinks: [DrinkItem] {
        return [
            DrinkItem(id: "1", name: "Espresso", description: "Strong coffee", imageURL: nil, price: 3.50, category: "Coffee"),
            DrinkItem(id: "2", name: "Latte", description: "Coffee with milk", imageURL: nil, price: 4.50, category: "Coffee"),
            DrinkItem(id: "3", name: "Cappuccino", description: "Coffee with foamed milk", imageURL: nil, price: 4.00, category: "Coffee")
        ]
    }
    
    static var previewVenues: [Venue] {
        return [
            Venue(
                id: "1",
                name: "Coffee House",
                description: "A cozy coffee shop",
                address: "123 Main St",
                imageURL: nil,
                latitude: 0.0,
                longitude: 0.0,
                isPremium: false
            ),
            Venue(
                id: "2",
                name: "Tea Time",
                description: "Specialty tea shop",
                address: "456 Oak Ave",
                imageURL: nil,
                latitude: 0.0,
                longitude: 0.0,
                isPremium: false
            )
        ]
    }
}

// VenueListViewModel extension for preview
extension VenueListViewModel {
    static var preview: VenueListViewModel {
        let viewModel = VenueListViewModel()
        viewModel.venues = PreviewData.previewVenues
        return viewModel
    }
}
#endif