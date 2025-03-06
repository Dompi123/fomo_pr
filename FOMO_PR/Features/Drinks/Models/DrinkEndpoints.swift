import Foundation
import SwiftUI
import FOMO_PR

// Internal type with specific name to avoid conflicts with other ReviewData declarations
struct DrinkReviewSubmission: Codable {
    let rating: Int
    let comment: String
    let userId: String
    
    init(rating: Int, comment: String, userId: String = UUID().uuidString) {
        self.rating = rating
        self.comment = comment
        self.userId = userId
    }
}

enum DrinkEndpoint {
    case getAll
    case getDetails(id: String)
    case getFeatured
    case search(query: String)
    case getReviews(drinkId: String)
    case postReview(drinkId: String, review: DrinkReviewSubmission)
    case favorite(drinkId: String)
    case getCategories
    
    static let base = "drinks"
    
    var path: String {
        switch self {
        case .getAll:
            return "/\(Self.base)"
        case .getDetails(let id):
            return "/\(Self.base)/\(id)"
        case .getFeatured:
            return "/\(Self.base)/featured"
        case .search:
            return "/\(Self.base)/search"
        case .getReviews(let drinkId):
            return "/\(Self.base)/\(drinkId)/reviews"
        case .postReview(let drinkId, _):
            return "/\(Self.base)/\(drinkId)/reviews"
        case .favorite(let drinkId):
            return "/\(Self.base)/\(drinkId)/favorites"
        case .getCategories:
            return "/\(Self.base)/categories"
        }
    }
    
    var method: String {
        switch self {
        case .postReview, .favorite:
            return "POST"
        default:
            return "GET"
        }
    }
    
    var operationId: String {
        switch self {
        case .getAll: return "getAllDrinks"
        case .getDetails: return "getDrinkDetails"
        case .getFeatured: return "getFeaturedDrinks"
        case .search: return "searchDrinks"
        case .getReviews: return "getDrinkReviews"
        case .postReview: return "postDrinkReview"
        case .favorite: return "favoriteDrink"
        case .getCategories: return "getDrinkCategories"
        }
    }
}

#if DEBUG
extension DrinkEndpoint {
    static let previewEndpoints: [DrinkEndpoint] = [
        .getAll,
        .getDetails(id: "drink_123"),
        .getFeatured,
        .search(query: "cocktail"),
        .getReviews(drinkId: "drink_123"),
        .getCategories
    ]
}
#endif 