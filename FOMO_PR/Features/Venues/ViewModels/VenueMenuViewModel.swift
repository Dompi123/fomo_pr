import Foundation
import SwiftUI
import Core

final class VenueMenuViewModel: BaseViewModel {
    @Published private(set) var drinks: [Drink] = []
    @Published var selectedDrinkQuantities: [String: Int] = [:]
    
    private let venue: Venue
    private let apiClient: APIClient
    
    init(venue: Venue, apiClient: APIClient = .shared) {
        self.venue = venue
        self.apiClient = apiClient
        super.init()
        Task {
            await loadDrinks()
        }
    }
    
    @MainActor
    func loadDrinks() async {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            drinks = try await apiClient.request(.getDrinks(venueId: venue.id)) as [Drink]
        } catch {
            handleError(error)
        }
    }
    
    func incrementQuantity(for drink: Drink) {
        selectedDrinkQuantities[drink.id] = (selectedDrinkQuantities[drink.id] ?? 0) + 1
    }
    
    func decrementQuantity(for drink: Drink) {
        guard let currentQuantity = selectedDrinkQuantities[drink.id], currentQuantity > 0 else { return }
        selectedDrinkQuantities[drink.id] = currentQuantity - 1
        if selectedDrinkQuantities[drink.id] == 0 {
            selectedDrinkQuantities.removeValue(forKey: drink.id)
        }
    }
    
    var selectedDrinks: [(drink: Drink, quantity: Int)] {
        drinks.compactMap { drink in
            guard let quantity = selectedDrinkQuantities[drink.id], quantity > 0 else { return nil }
            return (drink: drink, quantity: quantity)
        }
    }
    
    var totalAmount: Double {
        selectedDrinks.reduce(0) { total, item in
            total + (item.drink.price * Double(item.quantity))
        }
    }
    
    @MainActor
    func createOrder() async throws -> DrinkOrder {
        guard !selectedDrinks.isEmpty else {
            throw VenueMenuError.emptyOrder
        }
        
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            let items = selectedDrinks.map { DrinkOrderItem(drink: $0.drink, quantity: $0.quantity) }
            let order = try await apiClient.request(.createOrder(venueId: venue.id, items: items)) as DrinkOrder
            selectedDrinkQuantities.removeAll()
            return order
        } catch {
            handleError(error)
            throw error
        }
    }
}

// MARK: - Errors
enum VenueMenuError: LocalizedError {
    case emptyOrder
    
    var errorDescription: String? {
        switch self {
        case .emptyOrder:
            return "Please select at least one drink to create an order"
        }
    }
}

// MARK: - Preview
#if DEBUG
extension VenueMenuViewModel {
    static var preview: VenueMenuViewModel {
        let viewModel = VenueMenuViewModel(venue: .preview)
        viewModel.drinks = [.preview]
        viewModel.selectedDrinkQuantities = [Drink.preview.id: 2]
        return viewModel
    }
} 