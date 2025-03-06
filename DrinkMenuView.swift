import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.fomo.pr", category: "DrinkMenuView")

struct DrinkMenuView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    @StateObject private var viewModel = DrinkMenuViewModel()
    @State private var searchText = ""
    
    var venue: Venue? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading menu...")
                        .padding()
                } else {
                    menuContent
                }
            }
            .navigationTitle("Drink Menu")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    navigationCoordinator.dismissSheet()
                },
                trailing: Button(action: {
                    if !viewModel.cart.isEmpty {
                        logger.debug("Checkout button tapped with \(viewModel.cart.count) items")
                        let order = DrinkOrder(items: viewModel.cart)
                        navigationCoordinator.navigate(to: .checkout(order: order))
                    }
                }) {
                    HStack {
                        Image(systemName: "cart")
                        Text("\(viewModel.cartItemCount)")
                    }
                }
                .disabled(viewModel.cart.isEmpty)
            )
            .searchable(text: $searchText, prompt: "Search drinks")
            .onAppear {
                logger.debug("DrinkMenuView appeared")
                Task {
                    await viewModel.fetchDrinks()
                }
            }
        }
    }
    
    private var menuContent: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Categories
                ForEach(viewModel.categories, id: \.self) { category in
                    if !filteredDrinks(for: category).isEmpty {
                        categorySection(category: category)
                    }
                }
                
                // Cart summary if not empty
                if !viewModel.cart.isEmpty {
                    cartSummary
                }
            }
            .padding(.vertical)
        }
    }
    
    private func categorySection(category: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(category)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ForEach(filteredDrinks(for: category)) { drink in
                DrinkItemRow(
                    drink: drink,
                    quantity: viewModel.quantityInCart(for: drink),
                    onAdd: {
                        viewModel.addToCart(drink)
                    },
                    onRemove: {
                        viewModel.removeFromCart(drink)
                    }
                )
                .padding(.horizontal)
            }
        }
    }
    
    private var cartSummary: some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.horizontal)
            
            HStack {
                Text("Your Order")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.cart.count) items")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Button(action: {
                logger.debug("Checkout button tapped from cart summary")
                let order = DrinkOrder(items: viewModel.cart)
                navigationCoordinator.navigate(to: .checkout(order: order))
            }) {
                HStack {
                    Text("Checkout")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(viewModel.cartTotal.formatted(.currency(code: "USD")))
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    private func filteredDrinks(for category: String) -> [DrinkItem] {
        let drinksInCategory = viewModel.drinks.filter { $0.category == category }
        
        if searchText.isEmpty {
            return drinksInCategory
        } else {
            return drinksInCategory.filter { drink in
                drink.name.localizedCaseInsensitiveContains(searchText) ||
                drink.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct DrinkItemRow: View {
    let drink: DrinkItem
    let quantity: Int
    let onAdd: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Drink image placeholder
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                
                Image(systemName: "wineglass")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
            .frame(width: 60, height: 60)
            
            // Drink details
            VStack(alignment: .leading, spacing: 4) {
                Text(drink.name)
                    .font(.headline)
                
                Text(drink.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(drink.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            // Quantity controls
            HStack(spacing: 8) {
                if quantity > 0 {
                    Button(action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    
                    Text("\(quantity)")
                        .font(.headline)
                        .frame(minWidth: 24)
                }
                
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

class DrinkMenuViewModel: ObservableObject {
    @Published var drinks: [DrinkItem] = []
    @Published var cart: [DrinkItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var categories: [String] {
        Array(Set(drinks.map { $0.category })).sorted()
    }
    
    var cartItemCount: Int {
        cart.reduce(0) { $0 + $1.quantity }
    }
    
    var cartTotal: Decimal {
        cart.reduce(0) { $0 + ($1.price * Decimal($1.quantity)) }
    }
    
    func fetchDrinks() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // In a real app, this would be a network call
            // For now, use mock data
            let mockDrinks = MockDataProvider.shared.drinks
            
            await MainActor.run {
                self.drinks = mockDrinks
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func addToCart(_ drink: DrinkItem) {
        // Check if the drink is already in the cart
        if let index = cart.firstIndex(where: { $0.id == drink.id }) {
            // Increment quantity
            cart[index].quantity += 1
        } else {
            // Add new item with quantity 1
            var newItem = drink
            newItem.quantity = 1
            cart.append(newItem)
        }
    }
    
    func removeFromCart(_ drink: DrinkItem) {
        cart.removeAll { $0.id == drink.id }
    }
    
    func incrementQuantity(for drink: DrinkItem) {
        if let index = cart.firstIndex(where: { $0.id == drink.id }) {
            cart[index].quantity += 1
        }
    }
    
    func decrementQuantity(for drink: DrinkItem) {
        if let index = cart.firstIndex(where: { $0.id == drink.id }) {
            if cart[index].quantity > 1 {
                cart[index].quantity -= 1
            } else {
                cart.remove(at: index)
            }
        }
    }
    
    func quantityInCart(for drink: DrinkItem) -> Int {
        if let cartItem = cart.first(where: { $0.id == drink.id }) {
            return cartItem.quantity
        }
        return 0
    }
}

// Add category property to DrinkItem
extension DrinkItem {
    var category: String {
        get {
            UserDefaults.standard.string(forKey: "category_\(id)") ?? "Uncategorized"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "category_\(id)")
        }
    }
    
    init(name: String, description: String, price: Double, category: String) {
        self.init(name: name, description: description, price: price)
        self.category = category
    }
}

#if DEBUG
struct DrinkMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMenuView()
            .environmentObject(PreviewNavigationCoordinator.shared)
            .preferredColorScheme(.dark)
    }
}
#endif 