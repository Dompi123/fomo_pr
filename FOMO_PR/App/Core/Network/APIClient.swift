import Foundation

// APIClient Type
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