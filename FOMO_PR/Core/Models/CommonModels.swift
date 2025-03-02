import Foundation
import SwiftUI

// MARK: - Common Models

// Venue model used across the app
public struct Venue: Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let address: String
    public let imageURL: String
    public let rating: Double
    public let priceLevel: Int
    public let category: String
    public let isOpen: Bool
    public let distance: Double?
    
    public init(
        id: String,
        name: String,
        description: String,
        address: String,
        imageURL: String,
        rating: Double,
        priceLevel: Int,
        category: String,
        isOpen: Bool,
        distance: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.imageURL = imageURL
        self.rating = rating
        self.priceLevel = priceLevel
        self.category = category
        self.isOpen = isOpen
        self.distance = distance
    }
}

// MARK: - UI Components

// Common text styling
public struct TextStyle {
    public let size: CGFloat
    public let weight: Font.Weight
    
    public init(size: CGFloat, weight: Font.Weight) {
        self.size = size
        self.weight = weight
    }
}

// Common theme colors and styles
public enum FOMOTheme {
    public enum Colors {
        public static let primary = Color.blue
        public static let secondary = Color.gray
        public static let background = Color.white
        public static let text = Color.black
        public static let accent = Color.orange
    }
    
    public enum TextStyles {
        public static let h1 = TextStyle(size: 24, weight: .bold)
        public static let h2 = TextStyle(size: 20, weight: .bold)
        public static let body = TextStyle(size: 16, weight: .regular)
        public static let bodyBold = TextStyle(size: 16, weight: .bold)
        public static let caption = TextStyle(size: 12, weight: .regular)
        public static let button = TextStyle(size: 16, weight: .semibold)
    }
}

// MARK: - Base View Models

// Base view model class for common functionality
open class BaseViewModel: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    
    public init() {}
    
    public func simulateNetworkDelay() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        } catch {
            // Ignore cancellation errors
        }
    }
}

// MARK: - Preview Helpers

extension Venue {
    public static var preview: Venue {
        Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, New York, NY 10001",
            imageURL: "https://example.com/venue1.jpg",
            rating: 4.7,
            priceLevel: 3,
            category: "Bar",
            isOpen: true,
            distance: 0.5
        )
    }
}

// Helper function to get mock venue data
public func getMockVenueDetails(id: String) -> Venue {
    Venue(
        id: id,
        name: "The Rooftop Bar",
        description: "A trendy rooftop bar with amazing city views and craft cocktails.",
        address: "123 Main St, New York, NY 10001",
        imageURL: "https://example.com/venue1.jpg",
        rating: 4.7,
        priceLevel: 3,
        category: "Bar",
        isOpen: true,
        distance: 0.5
    )
}

// Extension to apply text styles to Text views
extension Text {
    public func fomoTextStyle(_ style: TextStyle) -> Text {
        self.font(.system(size: style.size, weight: style.weight))
    }
} 