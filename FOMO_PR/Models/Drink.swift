import Foundation

struct Drink: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String?
    let available: Bool
    
    static func == (lhs: Drink, rhs: Drink) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DrinkOrder: Identifiable {
    let id: String
    let items: [CartItem]
    let totalPrice: Double
    var timestamp: Date = Date()
    var status: OrderStatus = .pending
    
    enum OrderStatus: String, Codable {
        case pending
        case preparing
        case ready
        case completed
        case cancelled
    }
} 