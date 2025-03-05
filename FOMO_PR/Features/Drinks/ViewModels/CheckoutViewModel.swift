import Foundation
import SwiftUI

// Use the DrinkItem and DrinkOrder from FOMOApp.swift
class CheckoutViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    @Published var order: DrinkOrder?
    @Published var items: [DrinkItem] = []
    
    var totalPrice: Double {
        items.reduce(0) { $0 + (Double(truncating: $1.price as NSNumber) * Double($1.quantity)) }
    }
    
    func processPayment() {
        isLoading = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            // Simulate success
            NotificationCenter.default.post(name: NSNotification.Name("PaymentCompleted"), object: nil)
        }
    }
    
    // For previews
    static func preview() -> CheckoutViewModel {
        let viewModel = CheckoutViewModel()
        viewModel.items = [
            DrinkItem(name: "Mojito", price: 12.99, quantity: 2),
            DrinkItem(name: "Margarita", price: 10.99, quantity: 1)
        ]
        return viewModel
    }
} 
