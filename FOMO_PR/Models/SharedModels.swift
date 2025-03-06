import Foundation

// Shared model for review data used across different features
struct ReviewData: Codable {
    let rating: Int
    let comment: String
    let userId: String
    
    init(rating: Int, comment: String, userId: String = UUID().uuidString) {
        self.rating = rating
        self.comment = comment
        self.userId = userId
    }
} 