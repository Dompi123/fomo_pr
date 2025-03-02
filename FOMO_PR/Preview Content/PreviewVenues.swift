import Foundation
import SwiftUI

// MARK: - Drink Preview Data
extension Drink {
    static let previewList = [
        Drink(
            id: "drink1",
            name: "FOMO Special",
            description: "Our signature cocktail with premium vodka, fresh lime, and a hint of mint.",
            price: 12.99,
            imageURL: URL(string: "https://fomo-app.com/drinks/fomo-special.jpg"),
            category: "Cocktails",
            isAvailable: true
        ),
        Drink(
            id: "drink2",
            name: "Cosmic Martini",
            description: "A twist on the classic martini with blue curaçao and edible glitter.",
            price: 14.99,
            imageURL: URL(string: "https://fomo-app.com/drinks/cosmic-martini.jpg"),
            category: "Cocktails",
            isAvailable: true
        ),
        Drink(
            id: "drink3",
            name: "Golden Hour",
            description: "Whiskey, honey, lemon, and ginger beer - perfect for sunset vibes.",
            price: 13.99,
            imageURL: URL(string: "https://fomo-app.com/drinks/golden-hour.jpg"),
            category: "Cocktails",
            isAvailable: true
        )
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