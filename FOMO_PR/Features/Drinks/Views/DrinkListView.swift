import SwiftUI
import FOMO_PR // Import for FOMOTheme

// Import the theme extensions
import FOMOThemeExtensions

#if ENABLE_DRINK_MENU || PREVIEW_MODE
struct DrinkListView: View {
    let venue: Venue
    @StateObject private var viewModel = DrinkListViewModel()
    @EnvironmentObject var navigationCoordinator: PreviewNavigationCoordinator
    @Environment(\.dismiss) private var dismiss
    
    var isCheckoutEnabled: Bool {
        #if ENABLE_CHECKOUT
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading drinks...")
                } else if !viewModel.errorMessage.isEmpty {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .drinkErrorIconStyle()
                        
                        Text(viewModel.errorMessage)
                            .multilineTextAlignment(.center)
                            .padding(FOMOTheme.Spacing.medium)
                        
                        Button("Try Again") {
                            viewModel.loadDrinks()
                        }
                        .drinkButtonStyle()
                    }
                } else if viewModel.drinks.isEmpty {
                    VStack {
                        Image(systemName: "wineglass")
                            .drinkEmptyIconStyle()
                        
                        Text("No drinks available")
                            .drinkTitleStyle()
                        
                        Text("This venue hasn't added any drinks to their menu yet.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                            .padding(FOMOTheme.Spacing.medium)
                    }
                } else {
                    VStack {
                        List {
                            ForEach(viewModel.drinks) { drink in
                                DrinkRow(drink: drink, viewModel: viewModel)
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        if !viewModel.cartItems.isEmpty {
                            DrinkCartView(
                                items: viewModel.cartItems,
                                total: viewModel.cartTotal,
                                isCheckoutEnabled: isCheckoutEnabled,
                                onCheckout: {
                                    viewModel.isCheckingOut = true
                                }
                            )
                            .transition(.move(edge: .bottom))
                        }
                    }
                }
            }
            .navigationTitle("\(venue.name) Menu")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadDrinks()
            }
            .onChange(of: viewModel.isCheckingOut) { isCheckingOut in
                if isCheckingOut {
                    if isCheckoutEnabled {
                        // Create drink order and navigate to checkout
                        let order = DrinkOrder(
                            id: UUID().uuidString,
                            items: viewModel.cartItems,
                            totalPrice: viewModel.cartTotal
                        )
                        navigationCoordinator.navigateToCheckout(order: order, venue: venue)
                        viewModel.isCheckingOut = false
                    } else {
                        print("Checkout feature is disabled")
                        viewModel.isCheckingOut = false
                    }
                }
            }
        }
    }
}

struct DrinkRow: View {
    let drink: Drink
    @ObservedObject var viewModel: DrinkListViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack {
                if let imageURLString = drink.imageURL, let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .drinkImageStyle()
                    } placeholder: {
                        Rectangle()
                            .drinkPlaceholderStyle()
                    }
                } else {
                    Image(systemName: "wineglass")
                        .drinkIconStyle()
                }
                
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.xxSmall) {
                    Text(drink.name)
                        .drinkTitleStyle()
                    
                    Text(drink.description)
                        .drinkDescriptionStyle()
                    
                    Text("$\(String(format: "%.2f", drink.price))")
                        .drinkPriceStyle()
                }
                
                Spacer()
                
                if viewModel.cartItems.contains(where: { $0.drink.id == drink.id }) {
                    Text("\(viewModel.cartItems.first(where: { $0.drink.id == drink.id })?.quantity ?? 0)×")
                        .drinkQuantityStyle()
                }
            }
        }
        .contentShape(Rectangle())
        .sheet(isPresented: $showingDetail) {
            DrinkDetailView(drink: drink, viewModel: viewModel)
        }
    }
}

struct DrinkDetailView: View {
    let drink: Drink
    @ObservedObject var viewModel: DrinkListViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationCoordinator: PreviewNavigationCoordinator
    
    var isCheckoutEnabled: Bool {
        #if ENABLE_CHECKOUT
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let imageURLString = drink.imageURL, let imageURL = URL(string: imageURLString) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 240)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 240)
                                .overlay(
                                    ProgressView()
                                )
                        }
                    } else {
                        Image(systemName: "wineglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 240)
                            .background(Color.gray.opacity(0.2))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(drink.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("$\(String(format: "%.2f", drink.price))")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(drink.description)
                            .font(.body)
                            .padding(.top, 4)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Quantity selector
                        HStack {
                            Text("Quantity")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.decrementQuantity(for: drink)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .disabled(!viewModel.cartItems.contains(where: { $0.drink.id == drink.id }))
                            
                            Text("\(viewModel.cartItems.first(where: { $0.drink.id == drink.id })?.quantity ?? 0)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(minWidth: 40)
                                .padding(.horizontal, 8)
                            
                            Button(action: {
                                viewModel.incrementQuantity(for: drink)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Add to cart button
                        Button(action: {
                            if isCheckoutEnabled {
                                viewModel.addToCart(drink: drink)
                                dismiss()
                            } else {
                                print("Checkout feature is disabled")
                            }
                        }) {
                            Text("Add to Cart")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .background(isCheckoutEnabled ? Color.blue : Color.gray)
                        .cornerRadius(10)
                        .padding(.top, 16)
                        .disabled(!isCheckoutEnabled)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Drink Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DrinkCartView: View {
    let items: [CartItem]
    let total: Double
    let isCheckoutEnabled: Bool
    let onCheckout: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Your Order")
                        .font(.headline)
                    
                    Text("\(items.reduce(0) { $0 + $1.quantity }) items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.2f", total))")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Button(action: onCheckout) {
                    Text("Checkout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                }
                .background(isCheckoutEnabled ? Color.blue : Color.gray)
                .cornerRadius(8)
                .padding(.leading, 16)
                .disabled(!isCheckoutEnabled)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
}

class DrinkListViewModel: ObservableObject {
    @Published var drinks: [Drink] = []
    @Published var cartItems: [CartItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isCheckingOut = false
    
    var cartTotal: Double {
        cartItems.reduce(0) { $0 + ($1.drink.price * Double($1.quantity)) }
    }
    
    func loadDrinks() {
        isLoading = true
        errorMessage = ""
        
        // In a real app, we would load from API
        #if PREVIEW_MODE || ENABLE_MOCK_DATA
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.drinks = [
                Drink(
                    id: "drink1",
                    name: "Mojito",
                    description: "Classic cocktail with rum, mint, lime, and sugar",
                    price: 12.99,
                    imageURL: nil,
                    available: true
                ),
                Drink(
                    id: "drink2",
                    name: "Margarita",
                    description: "Tequila cocktail with lime juice and orange liqueur",
                    price: 14.99,
                    imageURL: nil,
                    available: true
                ),
                Drink(
                    id: "drink3",
                    name: "Old Fashioned",
                    description: "Classic whiskey cocktail with bitters and sugar",
                    price: 15.99,
                    imageURL: nil,
                    available: true
                ),
                Drink(
                    id: "drink4",
                    name: "Sparkling Water",
                    description: "Refreshing sparkling water with lime",
                    price: 4.99,
                    imageURL: nil,
                    available: true
                ),
                Drink(
                    id: "drink5",
                    name: "Craft Beer",
                    description: "Local IPA with notes of citrus and pine",
                    price: 8.99,
                    imageURL: nil,
                    available: true
                )
            ]
            self.isLoading = false
        }
        #else
        // Set error for real app without API implementation
        self.errorMessage = "API connection not implemented"
        self.isLoading = false
        #endif
    }
    
    func addToCart(drink: Drink) {
        if let index = cartItems.firstIndex(where: { $0.drink.id == drink.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(drink: drink, quantity: 1))
        }
    }
    
    func incrementQuantity(for drink: Drink) {
        if let index = cartItems.firstIndex(where: { $0.drink.id == drink.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(drink: drink, quantity: 1))
        }
    }
    
    func decrementQuantity(for drink: Drink) {
        if let index = cartItems.firstIndex(where: { $0.drink.id == drink.id }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
            } else {
                cartItems.remove(at: index)
            }
        }
    }
}

struct CartItem: Identifiable {
    var id: String { drink.id }
    let drink: Drink
    var quantity: Int
}

#if DEBUG
struct DrinkListView_Previews: PreviewProvider {
    static var previews: some View {
        let previewVenue = Venue(
            id: "123",
            name: "Preview Venue",
            description: "A venue for preview",
            location: "123 Main St",
            imageURL: nil,
            isPremium: false
        )
        
        return DrinkListView(venue: previewVenue)
            .environmentObject(PreviewNavigationCoordinator())
    }
}
#endif
#endif 