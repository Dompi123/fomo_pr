import SwiftUI
import Foundation
// import Models // Commenting out Models import to use local implementations instead

// Local Drink model to avoid conflicts with other Drink models
struct MenuDrinkItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String?
    let ingredients: [String]
    let alcoholContent: Double?
    let isAvailable: Bool
}

// MARK: - View Models

@MainActor
final class VenueMenuViewModel: ObservableObject {
    @Published var drinks: [MenuDrinkItem] = []
    @Published var selectedDrinks: [String: Int] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchText = ""
    @Published var selectedCategory: String?
    
    private let venueId: String
    
    init(venueId: String) {
        self.venueId = venueId
        loadDrinks()
    }
    
    var filteredDrinks: [MenuDrinkItem] {
        var filtered = drinks
        
        if let category = selectedCategory {
            let categoryDrinks = filtered.filter { drink in
                // Create categories based on drink types
                if drink.alcoholContent != nil && drink.alcoholContent! > 0 {
                    return category == "Alcoholic"
                        } else {
                    return category == "Non-Alcoholic"
                }
            }
            filtered = categoryDrinks
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var categories: [String] {
        return ["Alcoholic", "Non-Alcoholic"]
    }
    
    var totalItems: Int {
        selectedDrinks.values.reduce(0, +)
    }
    
    var totalPrice: Double {
        var total: Double = 0
        for (drinkId, quantity) in selectedDrinks {
            if let drink = drinks.first(where: { $0.id == drinkId }) {
                total += drink.price * Double(quantity)
            }
        }
        return total
    }
    
    func loadDrinks() {
        isLoading = true
        
        Task {
            do {
                let fetchedDrinks = try await fetchDrinksForVenue(venueId: venueId)
                self.drinks = fetchedDrinks
                isLoading = false
        } catch {
                self.error = error
                isLoading = false
            }
        }
    }
    
    private func fetchDrinksForVenue(venueId: String) async throws -> [MenuDrinkItem] {
        // In a real app, this would fetch drinks from an API
        // For now, we'll use mock data
        return [
            MenuDrinkItem(
                id: "drink1",
                name: "Classic Mojito",
                description: "Refreshing mint and lime cocktail with rum",
                price: 12.99,
                imageURL: "https://example.com/mojito.jpg",
                ingredients: ["White rum", "Mint leaves", "Lime juice", "Sugar", "Soda water"],
                alcoholContent: 12.0,
                isAvailable: true
            ),
            MenuDrinkItem(
                id: "drink2",
                name: "Margarita",
                description: "Tequila, lime, and orange liqueur with salt rim",
                price: 11.99,
                imageURL: "https://example.com/margarita.jpg",
                ingredients: ["Tequila", "Triple sec", "Lime juice", "Salt"],
                alcoholContent: 15.0,
                isAvailable: true
            ),
            MenuDrinkItem(
                id: "drink3",
                name: "Craft IPA",
                description: "Hoppy India Pale Ale with citrus notes",
                price: 8.99,
                imageURL: "https://example.com/ipa.jpg",
                ingredients: ["Malted barley", "Hops", "Yeast", "Water"],
                alcoholContent: 6.5,
                isAvailable: true
            ),
            MenuDrinkItem(
                id: "drink4",
                name: "Red Wine",
                description: "Full-bodied Cabernet Sauvignon",
                price: 9.99,
                imageURL: "https://example.com/redwine.jpg",
                ingredients: ["Cabernet Sauvignon grapes"],
                alcoholContent: 13.5,
                isAvailable: true
            ),
            MenuDrinkItem(
                id: "drink5",
                name: "White Wine",
                description: "Crisp Chardonnay with notes of apple and oak",
                price: 9.99,
                imageURL: "https://example.com/whitewine.jpg",
                ingredients: ["Chardonnay grapes"],
                alcoholContent: 12.5,
                isAvailable: true
            ),
            MenuDrinkItem(
                id: "drink6",
                name: "Espresso Martini",
                description: "Coffee-infused cocktail with vodka and coffee liqueur",
                price: 13.99,
                imageURL: "https://example.com/espressomartini.jpg",
                ingredients: ["Vodka", "Coffee liqueur", "Espresso", "Simple syrup"],
                alcoholContent: 18.0,
                isAvailable: true
            ),
            MenuDrinkItem(
                id: "drink7",
                name: "Lemonade",
                description: "Fresh-squeezed lemonade with mint",
                price: 4.99,
                imageURL: "https://example.com/lemonade.jpg",
                ingredients: ["Lemon juice", "Sugar", "Water", "Mint"],
                alcoholContent: nil,
                isAvailable: true
            ),
            MenuDrinkItem(
                id: "drink8",
                name: "Sparkling Water",
                description: "Refreshing sparkling water with lime",
                price: 3.99,
                imageURL: "https://example.com/sparklingwater.jpg",
                ingredients: ["Sparkling water", "Lime"],
                alcoholContent: nil,
                isAvailable: true
            )
        ]
    }
    
    func incrementDrink(_ drink: MenuDrinkItem) {
        let currentCount = selectedDrinks[drink.id] ?? 0
        selectedDrinks[drink.id] = currentCount + 1
    }
    
    func decrementDrink(_ drink: MenuDrinkItem) {
        guard let currentCount = selectedDrinks[drink.id], currentCount > 0 else { return }
        
        if currentCount == 1 {
            selectedDrinks.removeValue(forKey: drink.id)
        } else {
            selectedDrinks[drink.id] = currentCount - 1
        }
    }
    
    func selectCategory(_ category: String?) {
        selectedCategory = category
    }
}

// MARK: - Views

struct VenueMenuView: View {
    let venue: Venue
    @StateObject private var viewModel: VenueMenuViewModel
    @State private var showingCheckout = false
    
    init(venue: Venue) {
        self.venue = venue
        _viewModel = StateObject(wrappedValue: VenueMenuViewModel(venueId: venue.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            // Category selector
            categorySelector
            
            // Drinks list
            drinksList
            
            // Checkout button
            checkoutButton
        }
        .navigationTitle(venue.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCheckout) {
            checkoutView
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search drinks", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.selectCategory(nil)
                }) {
                    Text("All")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(viewModel.selectedCategory == nil ? .white : .primary)
                        .cornerRadius(20)
                }
                
                ForEach(viewModel.categories, id: \.self) { category in
                    Button(action: {
                        viewModel.selectCategory(category)
                    }) {
                        Text(category)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
    }
    
    private var drinksList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredDrinks) { drink in
                    DrinkItemView(
                        drink: drink,
                        quantity: viewModel.selectedDrinks[drink.id] ?? 0,
                        onIncrement: {
                            viewModel.incrementDrink(drink)
                        },
                        onDecrement: {
                            viewModel.decrementDrink(drink)
                        }
                    )
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private var checkoutButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: {
                showingCheckout = true
            }) {
                HStack {
                    Text("\(viewModel.totalItems) items")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", viewModel.totalPrice))")
                        .font(.headline)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            }
            .disabled(viewModel.totalItems == 0)
            .opacity(viewModel.totalItems == 0 ? 0.5 : 1)
        }
        .background(Color.white)
    }
    
    private var checkoutView: some View {
        Text("Checkout View")
            .font(.title)
            .padding()
    }
}

// MARK: - Supporting Views

struct DrinkItemView: View {
    let drink: MenuDrinkItem
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Drink image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Text(drink.name.prefix(1))
                    .font(.title)
                    .foregroundColor(.gray)
            }
            
            // Drink details
            VStack(alignment: .leading, spacing: 4) {
                Text(drink.name)
                    .font(.headline)
                
                Text(drink.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", drink.price))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            // Quantity controls
            VStack {
                if quantity > 0 {
                    HStack {
                        Button(action: onDecrement) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Text("\(quantity)")
                            .font(.headline)
                            .frame(minWidth: 30)
                        
                        Button(action: onIncrement) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    Button(action: onIncrement) {
                        Text("Add")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

struct VenueMenuView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock venue for preview
        let mockVenue = Venue(
            id: "venue_123",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, San Francisco, CA 94105",
            imageURL: URL(string: "https://example.com/venue.jpg"),
            latitude: 37.7749,
            longitude: -122.4194,
            isPremium: true
        )
        
        NavigationView {
            VenueMenuView(venue: mockVenue)
        }
    }
} 