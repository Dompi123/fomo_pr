import Foundation
import SwiftUI

// Define DrinkItem and DrinkOrder for this file only
struct DrinkItem: Identifiable {
    let id: String
    let name: String
    let price: Double
    let quantity: Int
}

struct DrinkOrder {
    let items: [DrinkItem]
    
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}

class CheckoutViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    @Published var order: DrinkOrder
    @Published var paymentCompleted = false
    
    init(order: DrinkOrder) {
        self.order = order
    }
    
    func processPayment() {
        isLoading = true
        error = nil
        
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Mock successful payment
                await MainActor.run {
                    self.paymentCompleted = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview Helper
extension CheckoutViewModel {
    static func preview() -> CheckoutViewModel {
        let order = DrinkOrder(items: [
            DrinkItem(id: "1", name: "Mojito", price: 12.99, quantity: 2),
            DrinkItem(id: "2", name: "Margarita", price: 10.99, quantity: 1)
        ])
        return CheckoutViewModel(order: order)
    }
} 
