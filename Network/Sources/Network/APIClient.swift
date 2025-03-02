import Foundation
import Models

// MARK: - Network
public actor APIClient {
    public static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private var authToken: String?
    
    private init() {
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
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
    
    public func validateAPIKey(_ key: String) async throws -> Bool {
        // Simulate API key validation
        try await Task.sleep(nanoseconds: 500_000_000)
        return true
    }
} 