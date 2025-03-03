import SwiftUI
import Foundation
import Core
import Models

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
        .background(Color(.systemBackground))
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
                        .background(viewModel.selectedCategory == nil ? Color.accentColor : Color.gray.opacity(0.2))
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
                            .background(viewModel.selectedCategory == category ? Color.accentColor : Color.gray.opacity(0.2))
                            .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    private var drinksList: some View {
        List {
            ForEach(viewModel.filteredDrinks) { drink in
                drinkRow(drink)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func drinkRow(_ drink: MenuDrinkItem) -> some View {
        HStack(spacing: 16) {
            // Drink image
            if let imageURL = drink.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Image(systemName: "wineglass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
            }
            
            // Drink info
            VStack(alignment: .leading, spacing: 4) {
                Text(drink.name)
                    .font(.headline)
                
                Text(drink.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", drink.price))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            // Selection controls
            if drink.isAvailable {
                HStack {
                    Button(action: {
                        viewModel.decrementDrink(drink)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title2)
                    }
                    .disabled(viewModel.selectedDrinks[drink.id] == nil)
                    
                    Text("\(viewModel.selectedDrinks[drink.id] ?? 0)")
                        .font(.headline)
                        .frame(minWidth: 30)
                    
                    Button(action: {
                        viewModel.incrementDrink(drink)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title2)
                    }
                }
            } else {
                Text("Unavailable")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var checkoutButton: some View {
        Button(action: {
            showingCheckout = true
        }) {
            HStack {
                Text("Checkout")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.totalItems) items • $\(String(format: "%.2f", viewModel.totalPrice))")
                    .font(.subheadline)
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
        }
        .disabled(viewModel.totalItems == 0)
        .opacity(viewModel.totalItems == 0 ? 0.5 : 1)
    }
    
    private var checkoutView: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.drinks.filter { viewModel.selectedDrinks[$0.id] != nil }) { drink in
                        HStack {
                            Text(drink.name)
                            Spacer()
                            Text("x\(viewModel.selectedDrinks[drink.id] ?? 0)")
                                .foregroundColor(.secondary)
                            Text("$\(String(format: "%.2f", drink.price * Double(viewModel.selectedDrinks[drink.id] ?? 0)))")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Section {
                        HStack {
                            Text("Total")
                                .fontWeight(.bold)
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.totalPrice))")
                                .fontWeight(.bold)
                        }
                    }
                }
                
                Button(action: {
                    // Process order
                    showingCheckout = false
                }) {
                    Text("Place Order")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding()
                }
            }
            .navigationTitle("Your Order")
            .navigationBarItems(trailing: Button("Cancel") {
                showingCheckout = false
            })
        }
    }
}

// MARK: - Preview

struct VenueMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VenueMenuView(venue: Venue(
                id: "venue1",
                name: "The Grand Ballroom",
                description: "A luxurious venue for all your special events",
                address: "123 Main Street, New York, NY",
                capacity: 500,
                currentOccupancy: 250,
                waitTime: 15,
                imageURL: "https://example.com/venue.jpg",
                latitude: 40.7128,
                longitude: -74.0060,
                openingHours: "Mon-Sun: 10AM-10PM",
                tags: ["Luxury", "Events", "Ballroom"],
                rating: 4.8,
                isOpen: true
            ))
        }
    }
} 