import Foundation

public struct ModelVersion {
    public static let version = "1.0.0"
    
    public static func getVersionInfo() -> String {
        return "Models Framework Version \(version)"
    }
}

public protocol Model {
    var id: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
}

public struct User: Model, Codable {
    public let id: String
    public let username: String
    public let email: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, username: String, email: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.username = username
        self.email = email
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct Venue: Model, Codable {
    public let id: String
    public let name: String
    public let address: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, address: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.address = address
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
