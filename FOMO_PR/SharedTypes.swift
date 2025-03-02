import Foundation
import SwiftUI

// MARK: - Base View Model
public class BaseViewModel: ObservableObject {
    @Published public var isLoading = false
    @Published public var error: Error?
    
    public init() {}
    
    public func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    public func setError(_ error: Error?) {
        self.error = error
    }
}

// MARK: - Venue Models
public struct Venue: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let address: String
    public let description: String
    public let tags: [String]
    public let imageURL: URL?
    public let capacity: Int
    public let currentOccupancy: Int
    public let waitTime: Int
    public let isOpen: Bool
    public let openingHours: [String]
    
    public init(id: String, name: String, address: String, description: String, tags: [String], imageURL: URL?, capacity: Int, currentOccupancy: Int, waitTime: Int, isOpen: Bool, openingHours: [String]) {
        self.id = id
        self.name = name
        self.address = address
        self.description = description
        self.tags = tags
        self.imageURL = imageURL
        self.capacity = capacity
        self.currentOccupancy = currentOccupancy
        self.waitTime = waitTime
        self.isOpen = isOpen
        self.openingHours = openingHours
    }
    
    public static func == (lhs: Venue, rhs: Venue) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static let preview = Venue(
        id: "venue-1",
        name: "The Rooftop Bar",
        address: "123 Main St, San Francisco, CA",
        description: "A beautiful rooftop bar with amazing views of the city.",
        tags: ["Rooftop", "Cocktails", "Views"],
        imageURL: URL(string: "https://example.com/venue1.jpg"),
        capacity: 100,
        currentOccupancy: 65,
        waitTime: 15,
        isOpen: true,
        openingHours: ["Mon-Fri: 4pm-2am", "Sat-Sun: 2pm-2am"]
    )
}

// MARK: - Drink Models
public struct Drink: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Double
    public let imageURL: URL?
    
    public init(id: String, name: String, description: String, price: Double, imageURL: URL?) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageURL = imageURL
    }
    
    public static let preview = Drink(
        id: "drink-1",
        name: "Signature Cocktail",
        description: "Our house specialty with premium spirits and fresh ingredients.",
        price: 12.99,
        imageURL: URL(string: "https://example.com/drink1.jpg")
    )
}

public struct DrinkOrderItem: Identifiable {
    public let id = UUID()
    public let drink: Drink
    public let quantity: Int
    
    public var totalPrice: Double {
        return drink.price * Double(quantity)
    }
    
    public init(drink: Drink, quantity: Int) {
        self.drink = drink
        self.quantity = quantity
    }
}

public struct DrinkOrder {
    public let id = UUID()
    public let items: [DrinkOrderItem]
    
    public var totalPrice: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    public init(items: [DrinkOrderItem]) {
        self.items = items
    }
}

// MARK: - Pass Models
public struct PricingTier: Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Double
    public let features: [String]
    
    public init(id: String, name: String, description: String, price: Double, features: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.features = features
    }
    
    public static let preview = PricingTier(
        id: "tier-1",
        name: "Standard Pass",
        description: "Basic entry to the venue",
        price: 25.0,
        features: ["Entry to main areas", "Access to standard bars"]
    )
}

public struct Pass: Identifiable {
    public let id: String
    public let venueId: String
    public let userId: String
    public let tier: PricingTier
    public let purchaseDate: Date
    public let expiryDate: Date
    public let isActive: Bool
    
    public init(id: String, venueId: String, userId: String, tier: PricingTier, purchaseDate: Date, expiryDate: Date, isActive: Bool) {
        self.id = id
        self.venueId = venueId
        self.userId = userId
        self.tier = tier
        self.purchaseDate = purchaseDate
        self.expiryDate = expiryDate
        self.isActive = isActive
    }
    
    public static let preview = Pass(
        id: "pass-1",
        venueId: "venue-1",
        userId: "user-1",
        tier: .preview,
        purchaseDate: Date(),
        expiryDate: Date().addingTimeInterval(86400), // 24 hours later
        isActive: true
    )
}

// MARK: - User Models
public struct Profile: Identifiable {
    public let id: String
    public let name: String
    public let email: String
    public let phoneNumber: String?
    public let imageURL: URL?
    public let preferences: Preferences
    
    public init(id: String, name: String, email: String, phoneNumber: String?, imageURL: URL?, preferences: Preferences) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.imageURL = imageURL
        self.preferences = preferences
    }
    
    public struct Preferences {
        public var notificationsEnabled: Bool
        public var emailUpdatesEnabled: Bool
        public var favoriteVenues: [String]
        
        public init(notificationsEnabled: Bool, emailUpdatesEnabled: Bool, favoriteVenues: [String]) {
            self.notificationsEnabled = notificationsEnabled
            self.emailUpdatesEnabled = emailUpdatesEnabled
            self.favoriteVenues = favoriteVenues
        }
    }
    
    public static let preview = Profile(
        id: "user-1",
        name: "John Doe",
        email: "john.doe@example.com",
        phoneNumber: "+1 (555) 123-4567",
        imageURL: URL(string: "https://example.com/profile.jpg"),
        preferences: Preferences(
            notificationsEnabled: true,
            emailUpdatesEnabled: false,
            favoriteVenues: ["venue-1", "venue-3"]
        )
    )
}

// MARK: - Theme
public enum FOMOTheme {
    public enum Colors {
        public static let primary = Color.blue
        public static let secondary = Color.purple
        public static let background = Color(.systemBackground)
        public static let surface = Color(.secondarySystemBackground)
        public static let text = Color(.label)
        public static let textSecondary = Color(.secondaryLabel)
        public static let success = Color.green
        public static let error = Color.red
    }
    
    public enum Typography {
        public static let title1 = Font.title
        public static let title2 = Font.title2
        public static let title3 = Font.title3
        public static let headline = Font.headline
        public static let body = Font.body
        public static let caption1 = Font.caption
        public static let caption2 = Font.caption2
    }
    
    public enum Spacing {
        public static let xxSmall: CGFloat = 4
        public static let xSmall: CGFloat = 8
        public static let small: CGFloat = 12
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let xLarge: CGFloat = 32
        public static let xxLarge: CGFloat = 48
    }
    
    public enum Radius {
        public static let small: CGFloat = 4
        public static let medium: CGFloat = 8
        public static let large: CGFloat = 16
    }
    
    public enum Shadow {
        public static let medium = Color.black.opacity(0.1)
    }
}

// MARK: - Network
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
        // For now, just return mock data based on the endpoint type
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        switch endpoint {
        case .venues:
            if T.self == [Venue].self {
                return [Venue.preview, Venue.preview] as! T
            }
        case .venueDetails:
            if T.self == Venue.self {
                return Venue.preview as! T
            }
        case .venueDrinks:
            if T.self == [Drink].self {
                return [Drink.preview, Drink.preview] as! T
            }
        case .venuePricingTiers:
            if T.self == [PricingTier].self {
                return [PricingTier.preview, PricingTier.preview] as! T
            }
        case .profile:
            if T.self == Profile.self {
                return Profile.preview as! T
            }
        case .purchasePass:
            if T.self == Pass.self {
                return Pass.preview as! T
            }
        default:
            break
        }
        
        throw NSError(domain: "APIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }
    
    public func setAuthToken(_ token: String) {
        self.authToken = token
    }
}

// MARK: - Animations
public enum FOMOAnimations {
    public static let standard = Animation.easeInOut(duration: 0.3)
    public static let slow = Animation.easeInOut(duration: 0.5)
    public static let fast = Animation.easeInOut(duration: 0.2)
    
    public static func spring(response: Double = 0.55, dampingFraction: Double = 0.825) -> Animation {
        return Animation.spring(response: response, dampingFraction: dampingFraction)
    }
}

// MARK: - CheckoutView
public struct CheckoutView: View {
    private let order: DrinkOrder
    @Environment(\.presentationMode) private var presentationMode
    @State private var isProcessing = false
    @State private var isComplete = false
    
    public init(order: DrinkOrder) {
        self.order = order
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: FOMOTheme.Spacing.large) {
                if isComplete {
                    VStack(spacing: FOMOTheme.Spacing.medium) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(FOMOTheme.Colors.success)
                        
                        Text("Order Complete!")
                            .font(FOMOTheme.Typography.title2)
                        
                        Text("Your drinks will be ready shortly.")
                            .font(FOMOTheme.Typography.body)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(FOMOTheme.Colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(FOMOTheme.Radius.medium)
                        .padding(.top, FOMOTheme.Spacing.large)
                    }
                    .padding()
                } else {
                    List {
                        Section(header: Text("Order Items")) {
                            ForEach(order.items) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.drink.name)
                                            .font(FOMOTheme.Typography.body)
                                        Text("\(item.quantity) x $\(String(format: "%.2f", item.drink.price))")
                                            .font(FOMOTheme.Typography.caption1)
                                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$\(String(format: "%.2f", item.totalPrice))")
                                        .font(FOMOTheme.Typography.body)
                                }
                            }
                        }
                        
                        Section {
                            HStack {
                                Text("Total")
                                    .font(FOMOTheme.Typography.headline)
                                
                                Spacer()
                                
                                Text("$\(String(format: "%.2f", order.totalPrice))")
                                    .font(FOMOTheme.Typography.headline)
                                    .foregroundColor(FOMOTheme.Colors.primary)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                    Button(action: processOrder) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Place Order")
                                .font(FOMOTheme.Typography.headline)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(FOMOTheme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(FOMOTheme.Radius.medium)
                    .padding(.horizontal)
                    .disabled(isProcessing)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func processOrder() {
        isProcessing = true
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            isComplete = true
        }
    }
} 