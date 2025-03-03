import Foundation
import SwiftUI
import Models

// Define the Drink type that was missing
struct Drink: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURLString: String?
    
    // Remove the computed property and use a method instead
    func getImageURL() -> URL? {
        guard let urlString = imageURLString else { return nil }
        return URL(string: urlString)
    }
    
    init(id: String, name: String, description: String, price: Double, imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageURLString = imageURL?.absoluteString
    }
}

// Remove the redundant import since we're already in the FOMO_PR module
// import FOMO_PR

// MARK: - Drink Preview Data
extension Drink {
    static var previewList: [Drink] = [
        Drink(id: "1", name: "Mojito", description: "Classic mojito with mint and lime", price: 12.99),
        Drink(id: "2", name: "Margarita", description: "Traditional margarita with salt rim", price: 10.99),
        Drink(id: "3", name: "Old Fashioned", description: "Whiskey cocktail with bitters", price: 14.99)
    ]
}

// Comment out this section until VenueListViewModel is properly defined
/*
#if DEBUG
extension VenueListViewModel {
    static let preview: VenueListViewModel = {
        let model = VenueListViewModel()
        model.venues = Venue.previewList
        return model
    }()
}
#endif
*/ 