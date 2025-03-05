import Foundation
import UIKit
import SwiftUI

// This file helps with module imports
// It provides direct access to types from the Models framework

// Re-export Models types - COMMENTED OUT to avoid circular references
// public typealias ModelVersion = Models.ModelVersion
// public typealias Model = Models.Model
// public typealias User = Models.User
// public typealias Venue = Models.Venue

// Create a Models namespace to simulate the Models module
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
    
    public struct Venue: Model, Codable {
        public let id: String
        public let name: String
        public let address: String
        public let description: String
        public let capacity: Int
        public let currentOccupancy: Int
        public let waitTime: Int
        public let imageURL: String?
        public let latitude: Double
        public let longitude: Double
        public let openingHours: String
        public let tags: [String]
        public let rating: Double
        public let isOpen: Bool
        public let createdAt: Date
        public let updatedAt: Date
        
        public init(
            id: String,
            name: String,
            address: String,
            description: String,
            capacity: Int,
            currentOccupancy: Int,
            waitTime: Int,
            imageURL: String?,
            latitude: Double,
            longitude: Double,
            openingHours: String,
            tags: [String],
            rating: Double,
            isOpen: Bool,
            createdAt: Date,
            updatedAt: Date
        ) {
            self.id = id
            self.name = name
            self.address = address
            self.description = description
            self.capacity = capacity
            self.currentOccupancy = currentOccupancy
            self.waitTime = waitTime
            self.imageURL = imageURL
            self.latitude = latitude
            self.longitude = longitude
            self.openingHours = openingHours
            self.tags = tags
            self.rating = rating
            self.isOpen = isOpen
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
        
        // Simplified initializer for basic properties
        public init(id: String, name: String, address: String, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.name = name
            self.address = address
            self.description = "A venue"
            self.capacity = 100
            self.currentOccupancy = 0
            self.waitTime = 0
            self.imageURL = nil
            self.latitude = 0.0
            self.longitude = 0.0
            self.openingHours = "9AM-5PM"
            self.tags = []
            self.rating = 0.0
            self.isOpen = false
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
    
    // Add preview extension for Venue
    #if DEBUG
    public extension Venue {
        static var preview: Venue {
            Venue(
                id: "venue-123",
                name: "The Rooftop Bar",
                address: "123 Main St, New York, NY 10001",
                description: "A luxurious rooftop bar with stunning city views",
                capacity: 200,
                currentOccupancy: 150,
                waitTime: 15,
                imageURL: "venue_rooftop",
                latitude: 40.7128,
                longitude: -74.0060,
                openingHours: "Mon-Sun: 4PM-2AM",
                tags: ["Rooftop", "Cocktails", "Views"],
                rating: 4.5,
                isOpen: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
    }
    #endif
} 