import Foundation
import SwiftUI

// This file provides a local implementation of the Models namespace
public enum Models {
    public struct ModelVersion {
        public static let version = "1.0.0"
        
        public static func getVersionInfo() -> String {
            return "Models Framework Version \(version)"
        }
    }
    
    public protocol Model {
        var id: String { get }
        var createdAt: Date { get }
        var updatedAt: Date { get }
    }
    
    public struct User: Model, Codable {
        public let id: String
        public let username: String
        public let email: String
        public let createdAt: Date
        public let updatedAt: Date
        
        public init(id: String, username: String, email: String, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.username = username
            self.email = email
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
    
    public struct Venue: Model, Codable, Identifiable {
        public let id: String
        public let name: String
        public let address: String
        public let createdAt: Date
        public let updatedAt: Date
        
        public init(id: String, name: String, address: String, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.name = name
            self.address = address
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
    
    public struct DrinkItem: Identifiable, Equatable, Codable {
        public let id: String
        public let name: String
        public let description: String
        public let price: Decimal
        public var quantity: Int
        
        public init(id: String, name: String, description: String, price: Decimal, quantity: Int = 0) {
            self.id = id
            self.name = name
            self.description = description
            self.price = price
            self.quantity = quantity
        }
        
        public func formattedPrice() -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            return formatter.string(from: price as NSDecimalNumber) ?? "$\(price)"
        }
        
        public static func == (lhs: DrinkItem, rhs: DrinkItem) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    public struct DrinkOrder: Identifiable, Equatable {
        public let id: String
        public var items: [DrinkItem]
        public let venueId: String
        public var status: OrderStatus
        
        public init(id: String = UUID().uuidString, items: [DrinkItem] = [], venueId: String, status: OrderStatus = .pending) {
            self.id = id
            self.items = items
            self.venueId = venueId
            self.status = status
        }
        
        public var totalPrice: Decimal {
            items.reduce(Decimal(0)) { $0 + ($1.price * Decimal($1.quantity)) }
        }
        
        public var formattedTotalPrice: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            return formatter.string(from: totalPrice as NSDecimalNumber) ?? "$\(totalPrice)"
        }
        
        public enum OrderStatus: String, Codable {
            case pending
            case confirmed
            case preparing
            case ready
            case delivered
            case cancelled
        }
        
        public static func == (lhs: DrinkOrder, rhs: DrinkOrder) -> Bool {
            return lhs.id == rhs.id
        }
    }
} 