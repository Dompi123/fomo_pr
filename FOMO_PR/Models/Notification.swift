import Foundation

public struct Notification: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let message: String
    public let timestamp: Date
    public let isRead: Bool
    public let type: NotificationType
    
    public init(id: String = UUID().uuidString,
                title: String,
                message: String,
                timestamp: Date = Date(),
                isRead: Bool = false,
                type: NotificationType = .general) {
        self.id = id
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.isRead = isRead
        self.type = type
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Notification, rhs: Notification) -> Bool {
        return lhs.id == rhs.id
    }
}

public enum NotificationType: String, Codable {
    case general
    case event
    case promotion
    case pass
    case payment
    case system
}

// Extension for preview data
public extension Notification {
    static let preview = Notification(
        id: "notification-123",
        title: "New Event",
        message: "A new event has been added to your favorite venue.",
        timestamp: Date(),
        isRead: false,
        type: .event
    )
    
    static let previewList: [Notification] = [
        Notification(
            id: "notification-123",
            title: "New Event",
            message: "A new event has been added to your favorite venue.",
            timestamp: Date(),
            isRead: false,
            type: .event
        ),
        Notification(
            id: "notification-124",
            title: "Payment Successful",
            message: "Your payment for the VIP pass has been processed successfully.",
            timestamp: Date().addingTimeInterval(-3600),
            isRead: true,
            type: .payment
        ),
        Notification(
            id: "notification-125",
            title: "Special Promotion",
            message: "Get 20% off on all drinks this weekend!",
            timestamp: Date().addingTimeInterval(-86400),
            isRead: false,
            type: .promotion
        )
    ]
} 