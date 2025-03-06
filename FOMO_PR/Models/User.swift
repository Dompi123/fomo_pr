import Foundation
import SwiftUI

public struct User: Identifiable, Codable, Hashable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phone: String?
    public let profileImageURL: URL?
    
    public init(id: String = UUID().uuidString, 
                firstName: String, 
                lastName: String, 
                email: String, 
                phone: String? = nil, 
                profileImageURL: URL? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.profileImageURL = profileImageURL
    }
    
    public var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Preview instance
    public static let preview = User(
        id: "user-123",
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@example.com",
        phone: "+1 (555) 123-4567",
        profileImageURL: URL(string: "https://example.com/profile.jpg")
    )
} 