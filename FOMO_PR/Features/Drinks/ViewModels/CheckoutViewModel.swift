import Foundation
import SwiftUI
import OSLog

// Comment out the reference to FOMOApp.swift and use the models directly
// Use the DrinkItem and DrinkOrder from FOMOApp.swift
class CheckoutViewModel: ObservableObject {
    private let logger = Logger(subsystem: "com.fomo", category: "CheckoutViewModel")
    
    @Published var isLoading = false
    @Published var error: Error?
    @Published var order: DrinkOrder?
    @Published var items: [DrinkItem]
    @Published var isProcessing = false
    @Published var orderSuccess = false
    @Published var showAlert = false
    @Published var errorMessage: String?
    
    // Define the DrinkItem and DrinkOrder types locally if they're not accessible
    struct DrinkItem: Identifiable, Hashable, Codable {
        let id: String
        let name: String
        let description: String
        let price: Decimal
        var quantity: Int
        
        var formattedPrice: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = .current
            return formatter.string(from: price as NSDecimalNumber) ?? "$\(price)"
        }
        
        init(
            id: String = UUID().uuidString,
            name: String,
            description: String = "",
            price: Double,
            quantity: Int = 1
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.price = Decimal(price)
            self.quantity = quantity
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: DrinkItem, rhs: DrinkItem) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    struct DrinkOrder: Identifiable, Hashable, Codable {
        let id: String
        let items: [DrinkItem]
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
        
        var total: Decimal {
            items.reduce(0) { $0 + ($1.price * Decimal($1.quantity)) }
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: DrinkOrder, rhs: DrinkOrder) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    var totalPrice: Decimal {
        items.reduce(0) { $0 + ($1.price * Decimal($1.quantity)) }
    }
    
    var subtotal: Decimal {
        items.reduce(0) { $0 + ($1.price * Decimal($1.quantity)) }
    }
    
    var tax: Decimal {
        subtotal * Decimal(0.08) // 8% tax
    }
    
    var total: Decimal {
        subtotal + tax
    }
    
    init(items: [DrinkItem]) {
        self.items = items
        self.order = nil
        logger.debug("CheckoutViewModel initialized with \(items.count) items")
    }
    
    init(order: DrinkOrder) {
        self.items = order.items
        self.order = order
        logger.debug("CheckoutViewModel initialized with order: \(order.id)")
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
        let viewModel = CheckoutViewModel(items: [])
        // Add preview items
        viewModel.items = [
            DrinkItem(name: "Mojito", description: "Classic cocktail", price: 12.99, quantity: 2),
            DrinkItem(name: "Beer", description: "Local craft", price: 8.99, quantity: 1)
        ]
        return viewModel
    }
    
    func placeOrder() async {
        await MainActor.run {
            isProcessing = true
            errorMessage = nil
        }
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Simulate network call to place order
            // Succeed 90% of the time
            let orderSucceeded = Double.random(in: 0...1) < 0.9
            
            if !orderSucceeded {
                throw CheckoutError.orderFailed("The order could not be processed")
            }
            
            // Generate order ID and finalize
            let orderId = UUID().uuidString
            logger.debug("Order placed successfully: \(orderId)")
            
            await MainActor.run {
                self.orderSuccess = true
                self.showAlert = true
                self.isProcessing = false
            }
        } catch CheckoutError.orderFailed(let reason) {
            logger.error("Order failed: \(reason)")
            await MainActor.run {
                self.errorMessage = reason
                self.showAlert = true
                self.isProcessing = false
            }
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "An unexpected error occurred"
                self.showAlert = true
                self.isProcessing = false
            }
        }
    }
}

enum CheckoutError: Error {
    case orderFailed(String)
}

// Extension to handle getting checkout view models for previews
extension CheckoutViewModel {
    static var mockItems: [DrinkItem] {
        return [
            DrinkItem(name: "Mojito", description: "Classic cocktail", price: 12.99, quantity: 2),
            DrinkItem(name: "Beer", description: "Local craft", price: 8.99, quantity: 1),
            DrinkItem(name: "Margarita", description: "Tequila cocktail", price: 14.99, quantity: 1)
        ]
    }
    
    static var previewForSuccessfulOrder: CheckoutViewModel {
        let model = CheckoutViewModel(items: mockItems)
        model.orderSuccess = true
        return model
    }
    
    static var previewForFailedOrder: CheckoutViewModel {
        let model = CheckoutViewModel(items: mockItems)
        model.errorMessage = "Payment processing failed"
        return model
    }
    
    static var previewForProcessingOrder: CheckoutViewModel {
        let model = CheckoutViewModel(items: mockItems)
        model.isProcessing = true
        return model
    }
} 
