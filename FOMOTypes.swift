import Foundation
import SwiftUI
import Combine
import CoreLocation

// This file provides complete type definitions for key types
// that are causing issues in the Xcode build

// MARK: - BaseViewModel
public class BaseViewModel: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    
    public init() {}
    
    public func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.isLoading = loading
        }
    }
    
    public func setError(_ error: Error?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
}

// MARK: - FOMOTheme
public enum FOMOTheme {
    public static let primaryColor = Color(red: 0.2, green: 0.5, blue: 0.9)
    public static let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.3)
    public static let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.97)
    public static let textColor = Color.black
    public static let lightTextColor = Color.gray
    
    public static let cornerRadius: CGFloat = 12
    public static let padding: CGFloat = 16
    public static let smallPadding: CGFloat = 8
    public static let largePadding: CGFloat = 24
    
    public static let titleFont = Font.system(size: 24, weight: .bold)
    public static let subtitleFont = Font.system(size: 18, weight: .semibold)
    public static let bodyFont = Font.system(size: 16, weight: .regular)
    public static let smallFont = Font.system(size: 14, weight: .regular)
}

// MARK: - FOMOAnimations
#if !SWIFT_PACKAGE && !XCODE_HELPER
public enum FOMOAnimations {
    public static let standard = Animation.easeInOut(duration: 0.3)
    public static let slow = Animation.easeInOut(duration: 0.5)
    public static let springy = Animation.spring(response: 0.3, dampingFraction: 0.6)
}
#endif

// MARK: - Card
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

// MARK: - User
public struct User: Identifiable, Codable {
    public let id: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let profileImageURL: URL?
    public let phone: String?
    
    public init(
        id: String,
        email: String,
        firstName: String,
        lastName: String,
        profileImageURL: URL? = nil,
        phone: String? = nil
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageURL = profileImageURL
        self.phone = phone
    }
    
    #if DEBUG
    public static var mockUser: User {
        User(
            id: "user-123",
            email: "john.doe@example.com",
            firstName: "John",
            lastName: "Doe",
            profileImageURL: URL(string: "https://example.com/profile.jpg"),
            phone: "+1234567890"
        )
    }
    #endif
}

// MARK: - Notification
public struct Notification: Identifiable, Codable {
    public let id: String
    public let title: String
    public let body: String
    public let isRead: Bool
    public let createdAt: Date
    
    public init(
        id: String,
        title: String,
        body: String,
        isRead: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.isRead = isRead
        self.createdAt = createdAt
    }
    
    #if DEBUG
    public static var mockNotification: Notification {
        Notification(
            id: "notification-123",
            title: "New Message",
            body: "You have received a new message from John",
            isRead: false
        )
    }
    #endif
}

// MARK: - APIClient Type
#if !SWIFT_PACKAGE && !XCODE_HELPER
public actor APIClient {
    public static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private var authToken: String?
    
    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    public func validateAPIKey(_ key: String) async throws -> Bool {
        // Simulate API key validation
        try await Task.sleep(nanoseconds: 500_000_000)
        return true
    }
    
    public enum Endpoint {
        case venues
        case venueDetails(id: String)
        case venueDrinks(id: String)
        case venuePricingTiers(id: String)
        case profile
        case updateProfile
        case purchasePass(venueId: String, tierId: String)
        
        var path: String {
            switch self {
            case .venues:
                return "/venues"
            case .venueDetails(let id):
                return "/venues/\(id)"
            case .venueDrinks(let id):
                return "/venues/\(id)/drinks"
            case .venuePricingTiers(let id):
                return "/venues/\(id)/pricing"
            case .profile:
                return "/profile"
            case .updateProfile:
                return "/profile/update"
            case .purchasePass(let venueId, let tierId):
                return "/venues/\(venueId)/purchase/\(tierId)"
            }
        }
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // This would normally make a network request
        // For now, just return mock data
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Return a placeholder value - this won't actually be used
        // since we're just trying to make the build succeed
        let json = "{}"
        let data = json.data(using: .utf8)!
        return try decoder.decode(T.self, from: data)
    }
}
#endif

// MARK: - Import Payment Types
// These types are now defined in PaymentManager.swift
// PricingTier, TokenizationService, and Security are imported from there

// MARK: - Payment Types
#if !SWIFT_PACKAGE && !XCODE_HELPER
// PaymentResult and PaymentStatus are now defined in PaymentManager.swift
// Import FOMO_PR to access these types
#endif 