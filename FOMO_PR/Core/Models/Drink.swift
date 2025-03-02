import Foundation

public struct Drink: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Double
    public let imageURL: URL?
    public let category: String
    public let isAvailable: Bool
    
    public init(id: String, name: String, description: String, price: Double, imageURL: URL? = nil, category: String, isAvailable: Bool = true) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageURL = imageURL
        self.category = category
        self.isAvailable = isAvailable
    }
}

extension Drink {
    public static let preview = Drink(
        id: "preview-drink",
        name: "Classic Mojito",
        description: "Fresh mint, lime juice, sugar, white rum, and soda water",
        price: 12.99,
        imageURL: URL(string: "https://example.com/mojito.jpg"),
        category: "Cocktails"
    )
} 