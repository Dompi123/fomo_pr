import Foundation
import SwiftUI
import Combine

// Simple DrinkMenuViewModel that doesn't depend on external modules
class DrinkMenuViewModel: ObservableObject {
    @Published var drinks: [DrinkItem] = []
    @Published var categories: [String] = []
    @Published var cart: DrinkOrder
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var cartItemCount: Int {
        cart.items.reduce(0) { $0 + $1.quantity }
    }
    
    var cartTotal: Double {
        NSDecimalNumber(decimal: cart.items.reduce(0) { $0 + ($1.price * Decimal($1.quantity)) }).doubleValue
    }
    
    init() {
        self.cart = DrinkOrder()
    }
    
    func fetchDrinks() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Use mock data
        let mockDrinks = [
            DrinkItem(id: "1", name: "Mojito", description: "Classic cocktail with mint, lime, and rum", category: "Cocktails", price: 12.99),
            DrinkItem(id: "2", name: "Old Fashioned", description: "Whiskey cocktail with bitters and sugar", category: "Cocktails", price: 14.99),
            DrinkItem(id: "3", name: "Margarita", description: "Tequila cocktail with lime and salt", category: "Cocktails", price: 11.99),
            DrinkItem(id: "4", name: "Craft Beer", description: "Local IPA with citrus notes", category: "Beer", price: 8.99),
            DrinkItem(id: "5", name: "Red Wine", description: "Cabernet Sauvignon", category: "Wine", price: 10.99),
            DrinkItem(id: "6", name: "White Wine", description: "Chardonnay", category: "Wine", price: 9.99),
            DrinkItem(id: "7", name: "Sparkling Water", description: "Refreshing carbonated water", category: "Non-Alcoholic", price: 3.99),
            DrinkItem(id: "8", name: "Soda", description: "Cola or lemon-lime", category: "Non-Alcoholic", price: 2.99)
        ]
        
        await MainActor.run {
            self.drinks = mockDrinks
            self.categories = Array(Set(mockDrinks.map { $0.category })).sorted()
            self.isLoading = false
        }
    }
    
    func addToCart(_ drink: DrinkItem) {
        if let index = cart.items.firstIndex(where: { $0.id == drink.id }) {
            cart.items[index].quantity += 1
        } else {
            var drinkCopy = drink
            drinkCopy.quantity = 1
            cart.items.append(drinkCopy)
        }
    }
    
    func removeFromCart(_ drink: DrinkItem) {
        if let index = cart.items.firstIndex(where: { $0.id == drink.id }) {
            if cart.items[index].quantity > 1 {
                cart.items[index].quantity -= 1
            } else {
                cart.items.remove(at: index)
            }
        }
    }
    
    func clearCart() {
        cart.items.removeAll()
    }
}

// Define the DrinkItem type locally
struct DrinkItem: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let category: String
    let price: Decimal
    var quantity: Int
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        category: String = "",
        price: Double,
        quantity: Int = 1
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.price = Decimal(price)
        self.quantity = quantity
    }
    
    var total: Decimal {
        price * Decimal(quantity)
    }
}

// Define the DrinkOrder type locally
struct DrinkOrder: Identifiable, Codable {
    let id: String
    var items: [DrinkItem]
    let timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        items: [DrinkItem] = [],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.items = items
        self.timestamp = timestamp
    }
} 