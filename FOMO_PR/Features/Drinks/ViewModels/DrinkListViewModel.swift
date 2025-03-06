import SwiftUI
import Combine

#if ENABLE_DRINK_MENU || PREVIEW_MODE
class DrinkListViewModel: ObservableObject {
    @Published var drinks: [Drink] = []
    @Published var cartItems: [CartItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isCheckingOut = false
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func clearCart() {
        cartItems.removeAll()
    }
}

struct CartItem: Identifiable {
    var id: String { drink.id }
    let drink: Drink
    var quantity: Int
}
#endif 