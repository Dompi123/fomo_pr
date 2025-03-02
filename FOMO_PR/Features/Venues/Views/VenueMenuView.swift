import SwiftUI
import Foundation

// MARK: - Models

// Comment out or remove duplicate definitions
/*
struct Venue: Identifiable {
    let id: String
    let name: String
    let description: String
    let address: String
    let imageURL: String
    let rating: Double
    let priceLevel: Int
    let category: String
    let isOpen: Bool
    let distance: Double?
}

extension Venue {
    static var preview: Venue {
        Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, New York, NY 10001",
            imageURL: "https://example.com/venue1.jpg",
            rating: 4.7,
            priceLevel: 3,
            category: "Bar",
            isOpen: true,
            distance: 0.5
        )
    }
}
*/

struct Drink: Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: URL?
    let category: String
    let isAvailable: Bool
    
    static var preview: Drink {
        Drink(
            id: "drink1",
            name: "Classic Mojito",
            description: "Refreshing mint and lime cocktail with rum",
            price: 12.99,
            imageURL: URL(string: "https://example.com/mojito.jpg"),
            category: "Cocktails",
            isAvailable: true
        )
    }
}

// Comment out or remove duplicate definitions
/*
enum FOMOTheme {
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let background = Color.white
        static let text = Color.black
        static let accent = Color.orange
    }
}

struct TextStyle {
    let size: CGFloat
    let weight: Font.Weight
}

extension Text {
    func fomoTextStyle(_ style: TextStyle) -> Text {
        self.font(.system(size: style.size, weight: style.weight))
    }
}

class BaseViewModel {
    var isLoading: Bool = false
    var error: Error?
    
    func simulateNetworkDelay() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        } catch {
            // Ignore cancellation errors
        }
    }
}
*/

// MARK: - View Models

final class VenueMenuViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var drinks: [Drink] = []
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    
    private let venueId: String
    let venue: Venue
    
    init(venueId: String) {
        self.venueId = venueId
        // Create a default venue
        self.venue = Venue(
            id: venueId,
            name: "The Grand Ballroom",
            description: "A luxurious venue for all your special events",
            location: "123 Main Street, New York, NY",
            imageURL: URL(string: "https://example.com/venue.jpg")
        )
        loadDrinks()
    }
    
    var categories: [String] {
        let allCategories = drinks.map { $0.category }
        let uniqueCategories = Array(Set(allCategories)).sorted()
        return ["All"] + uniqueCategories
    }
    
    var filteredDrinks: [Drink] {
        var filtered = drinks
        
        // Apply category filter
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { drink in
                drink.name.localizedCaseInsensitiveContains(searchText) ||
                drink.description.localizedCaseInsensitiveContains(searchText) ||
                drink.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    func loadDrinks() {
        isLoading = true
        error = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: DispatchWorkItem {
            // In a real app, this would fetch drinks from an API
            // For now, we'll use mock data
            self.drinks = [
                Drink(
                    id: "drink1",
                    name: "Classic Mojito",
                    description: "Refreshing mint and lime cocktail with rum",
                    price: 12.99,
                    imageURL: URL(string: "https://example.com/mojito.jpg"),
                    category: "Cocktails",
                    isAvailable: true
                ),
                Drink(
                    id: "drink2",
                    name: "Margarita",
                    description: "Tequila, lime, and orange liqueur with salt rim",
                    price: 11.99,
                    imageURL: URL(string: "https://example.com/margarita.jpg"),
                    category: "Cocktails",
                    isAvailable: true
                ),
                Drink(
                    id: "drink3",
                    name: "Craft IPA",
                    description: "Hoppy India Pale Ale with citrus notes",
                    price: 8.99,
                    imageURL: URL(string: "https://example.com/ipa.jpg"),
                    category: "Beer",
                    isAvailable: true
                ),
                Drink(
                    id: "drink4",
                    name: "Red Wine",
                    description: "Full-bodied Cabernet Sauvignon",
                    price: 9.99,
                    imageURL: URL(string: "https://example.com/wine.jpg"),
                    category: "Wine",
                    isAvailable: false
                ),
                Drink(
                    id: "drink5",
                    name: "Sparkling Water",
                    description: "Refreshing mineral water with bubbles",
                    price: 3.99,
                    imageURL: URL(string: "https://example.com/water.jpg"),
                    category: "Non-Alcoholic",
                    isAvailable: true
                )
            ]
            
            self.isLoading = false
        })
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
}

// MARK: - Views

struct VenueMenuView: View {
    let venue: Venue
    @StateObject private var viewModel: VenueMenuViewModel
    @State private var showingCheckout = false
    @State private var selectedDrinks: [Drink] = []
    
    init(venue: Venue) {
        self.venue = venue
        _viewModel = StateObject(wrappedValue: VenueMenuViewModel(venueId: venue.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter
            VStack(spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search drinks", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            CategoryButton(
                                title: category,
                                isSelected: viewModel.selectedCategory == category,
                                action: {
                                    viewModel.selectCategory(category)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color.white)
            
            // Drinks List
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading drinks...")
                Spacer()
            } else if let error = viewModel.error {
                Spacer()
                VStack {
                    Text("Error loading drinks")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.red)
                    Button("Retry") {
                        viewModel.loadDrinks()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                Spacer()
            } else if viewModel.filteredDrinks.isEmpty {
                Spacer()
                Text("No drinks found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredDrinks) { drink in
                            DrinkCard(
                                drink: drink,
                                isSelected: selectedDrinks.contains(where: { $0.id == drink.id }),
                                onSelect: {
                                    if selectedDrinks.contains(where: { $0.id == drink.id }) {
                                        selectedDrinks.removeAll(where: { $0.id == drink.id })
                                    } else {
                                        selectedDrinks.append(drink)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            
            // Checkout Button
            if !selectedDrinks.isEmpty {
                VStack {
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(selectedDrinks.count) drinks selected")
                                .font(.headline)
                            
                            Text("Total: $\(selectedDrinks.reduce(0) { $0 + $1.price }, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingCheckout = true
                        }) {
                            Text("Checkout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                }
            }
        }
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCheckout) {
            Text("Checkout View Would Go Here")
                .font(.title)
                .padding()
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    Color.blue :
                    Color.secondary.opacity(0.2)
                )
                .foregroundColor(
                    isSelected ?
                    Color.white :
                    Color.primary
                )
                .cornerRadius(16)
        }
    }
}

struct DrinkCard: View {
    let drink: Drink
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Drink Image
            if let imageURL = drink.imageURL {
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                    } else if phase.error != nil {
                        Color.gray
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .overlay(ProgressView())
                    }
                }
            } else {
                Color.gray
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
            
            // Drink Info
            VStack(alignment: .leading, spacing: 4) {
                Text(drink.name)
                    .font(.headline)
                
                Text(drink.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(drink.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("$\(drink.price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Selection Button
            Button(action: onSelect) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(drink.isAvailable ? .blue : .gray)
                    .font(.title2)
            }
            .disabled(!drink.isAvailable)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .opacity(drink.isAvailable ? 1.0 : 0.6)
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
                location: "123 Main Street, New York, NY",
                imageURL: URL(string: "https://example.com/venue.jpg")
            ))
        }
    }
} 
