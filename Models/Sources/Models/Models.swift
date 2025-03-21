import Foundation

public struct Card: Codable, Identifiable {
    public let id: String
    public let last4: String
    public let brand: CardBrand
    public let expiryMonth: Int
    public let expiryYear: Int
    public let isDefault: Bool
    
    public init(id: String, last4: String, brand: CardBrand, expiryMonth: Int, expiryYear: Int, isDefault: Bool = false) {
        self.id = id
        self.last4 = last4
        self.brand = brand
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.isDefault = isDefault
    }
    
    public enum CardBrand: String, Codable {
        case visa
        case mastercard
        case amex
        case discover
        case unknown
        
        public var displayName: String {
            switch self {
            case .visa: return "Visa"
            case .mastercard: return "Mastercard"
            case .amex: return "American Express"
            case .discover: return "Discover"
            case .unknown: return "Card"
            }
        }
    }
    
    public var displayName: String {
        return "\(brand.displayName) •••• \(last4)"
    }
    
    public var expiryDisplay: String {
        return String(format: "%02d/%d", expiryMonth, expiryYear % 100)
    }
}

public struct PricingTier: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let price: Decimal
    public let features: [String]
    
    public init(id: String, name: String, price: Decimal, features: [String]) {
        self.id = id
        self.name = name
        self.price = price
        self.features = features
    }
}
