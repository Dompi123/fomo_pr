import Foundation

// Card type
public struct Card: Identifiable, Codable {
    public let id: String
    public let lastFour: String
    public let expiryMonth: Int
    public let expiryYear: Int
    public let cardholderName: String
    public let brand: String
    
    public init(
        id: String,
        lastFour: String,
        expiryMonth: Int,
        expiryYear: Int,
        cardholderName: String,
        brand: String
    ) {
        self.id = id
        self.lastFour = lastFour
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cardholderName = cardholderName
        self.brand = brand
    }
    
    #if DEBUG
    public static var mockCard: Card {
        Card(
            id: "card-123",
            lastFour: "4242",
            expiryMonth: 12,
            expiryYear: 2025,
            cardholderName: "John Doe",
            brand: "Visa"
        )
    }
    #endif
} 