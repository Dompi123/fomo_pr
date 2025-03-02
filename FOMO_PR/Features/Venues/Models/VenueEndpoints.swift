import Foundation

enum VenueEndpoint {
    case getAll
    case getDetails(id: String)
    case getDrinks(venueId: String)
    case purchasePass(venueId: String)
    case getCapacity(venueId: String)
    case search(query: String)
    case getEvents(venueId: String)
    case getReviews(venueId: String)
    case postReview(venueId: String, review: ReviewData)
    case favorite(venueId: String)
    
    static let base = "venues"
    
    var path: String {
        switch self {
        case .getAll:
            return "/\(Self.base)"
        case .getDetails(let id):
            return "/\(Self.base)/\(id)"
        case .getDrinks(let venueId):
            return "/\(Self.base)/\(venueId)/drinks"
        case .purchasePass(let venueId):
            return "/\(Self.base)/\(venueId)/passes"
        case .getCapacity(let venueId):
            return "/\(Self.base)/\(venueId)/capacity"
        case .search:
            return "/\(Self.base)/search"
        case .getEvents(let venueId):
            return "/\(Self.base)/\(venueId)/events"
        case .getReviews(let venueId):
            return "/\(Self.base)/\(venueId)/reviews"
        case .postReview(let venueId, _):
            return "/\(Self.base)/\(venueId)/reviews"
        case .favorite(let venueId):
            return "/\(Self.base)/\(venueId)/favorites"
        }
    }
    
    var method: String {
        switch self {
        case .postReview, .favorite, .purchasePass:
            return "POST"
        default:
            return "GET"
        }
    }
    
    var operationId: String {
        switch self {
        case .getAll: return "getAllVenues"
        case .getDetails: return "getVenueDetails"
        case .getDrinks: return "getVenueDrinks"
        case .purchasePass: return "purchaseVenuePass"
        case .getCapacity: return "getVenueCapacity"
        case .search: return "searchVenues"
        case .getEvents: return "getVenueEvents"
        case .getReviews: return "getVenueReviews"
        case .postReview: return "postVenueReview"
        case .favorite: return "favoriteVenue"
        }
    }
}

struct ReviewData: Codable {
    let rating: Int
    let comment: String
}

#if DEBUG
extension VenueEndpoint {
    static let previewEndpoints: [VenueEndpoint] = [
        .getAll,
        .getDetails(id: "venue_123"),
        .getDrinks(venueId: "venue_123"),
        .getCapacity(venueId: "venue_123"),
        .search(query: "nightclub"),
        .getEvents(venueId: "venue_123"),
        .getReviews(venueId: "venue_123")
    ]
}
#endif 