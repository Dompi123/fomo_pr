import Foundation
import SwiftUI

// This file provides complete type definitions for key types
// that are causing issues in the Xcode build

// MARK: - FOMOTheme
public enum FOMOTheme {
    // MARK: - Colors
    public enum Colors {
        public static let primary = Color.blue
        public static let secondary = Color.gray
        public static let accent = Color.orange
        public static let background = Color.white
        public static let surface = Color.white.opacity(0.9)
        public static let error = Color.red
        public static let success = Color.green
        public static let warning = Color.yellow
        public static let text = Color.black
        public static let textSecondary = Color.gray
    }
    
    // MARK: - Spacing
    public enum Spacing {
        public static let xxxSmall: CGFloat = 2
        public static let xxSmall: CGFloat = 4
        public static let xSmall: CGFloat = 8
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let xLarge: CGFloat = 32
        public static let xxLarge: CGFloat = 40
        public static let xxxLarge: CGFloat = 48
    }
}

// MARK: - FOMOAnimations
public enum FOMOAnimations {
    public struct LoadingView: View {
        public init() {}
        
        public var body: some View {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
        }
    }
}

// MARK: - BaseViewModel
public class BaseViewModel: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    
    public init() {}
    
    public func startLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
    }
    
    public func stopLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    public func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.error = error
            self.isLoading = false
        }
    }
    
    public func clearError() {
        DispatchQueue.main.async {
            self.error = nil
        }
    }
}

// MARK: - Venue Type
public struct Venue: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let address: String
    public let imageURL: URL?
    public let latitude: Double
    public let longitude: Double
    public let isPremium: Bool
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        address: String = "",
        imageURL: URL? = nil,
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.isPremium = isPremium
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Venue, rhs: Venue) -> Bool {
        lhs.id == rhs.id
    }
    
    // Add preview extension for Venue
    #if DEBUG
    public static var preview: Venue {
        Venue(
            id: "venue-123",
            name: "The Rooftop Bar",
            description: "A luxurious rooftop bar with stunning city views",
            address: "123 Main St, New York, NY 10001",
            imageURL: URL(string: "https://example.com/rooftop.jpg"),
            latitude: 40.7128,
            longitude: -74.0060,
            isPremium: true
        )
    }
    #endif
}

// MARK: - Mock Data
extension Venue {
    public static var mockVenues: [Venue] = [
        Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "Enjoy drinks with a stunning view of the city skyline.",
            address: "123 Main St, New York, NY 10001",
            imageURL: URL(string: "https://example.com/rooftop.jpg"),
            latitude: 40.7128,
            longitude: -74.0060,
            isPremium: true
        ),
        Venue(
            id: "venue2",
            name: "Underground Lounge",
            description: "A cozy speakeasy with craft cocktails and live jazz.",
            address: "456 Broadway, New York, NY 10012",
            imageURL: URL(string: "https://example.com/lounge.jpg"),
            latitude: 40.7193,
            longitude: -73.9951,
            isPremium: false
        ),
        Venue(
            id: "venue3",
            name: "Beachside Brewery",
            description: "Craft beers with ocean views and outdoor seating.",
            address: "789 Ocean Dr, Miami, FL 33139",
            imageURL: URL(string: "https://example.com/brewery.jpg"),
            latitude: 25.7617,
            longitude: -80.1918,
            isPremium: true
        )
    ]
    
    public static var mockVenue: Venue {
        mockVenues[0]
    }
} 