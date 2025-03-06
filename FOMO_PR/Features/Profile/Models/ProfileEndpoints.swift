import Foundation
// Remove the FOMO_PR import as it's causing ambiguity
// import FOMO_PR

// Define the missing types
struct ProfileData: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    
    init(from user: User) {
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email
        self.phone = user.phone
    }
}

struct NotificationSettings: Codable {
    var emailEnabled: Bool
    var pushEnabled: Bool
    var smsEnabled: Bool
}

enum ProfileEndpoint {
    case getProfile
    case updateProfile(profile: ProfileData)
    case getFavorites
    case getPasses
    case getPayments
    case getNotifications
    case updateNotifications(settings: NotificationSettings)
    case getSettings
    
    static let base = "profile"
    
    var path: String {
        switch self {
        case .getProfile, .updateProfile:
            return "/\(Self.base)"
        case .getFavorites:
            return "/\(Self.base)/favorites"
        case .getPasses:
            return "/\(Self.base)/passes"
        case .getPayments:
            return "/\(Self.base)/payments"
        case .getNotifications, .updateNotifications:
            return "/\(Self.base)/notifications"
        case .getSettings:
            return "/\(Self.base)/settings"
        }
    }
    
    var method: String {
        switch self {
        case .updateProfile, .updateNotifications:
            return "PUT"
        default:
            return "GET"
        }
    }
    
    var operationId: String {
        switch self {
        case .getProfile: return "getProfile"
        case .updateProfile: return "updateProfile"
        case .getFavorites: return "getProfileFavorites"
        case .getPasses: return "getProfilePasses"
        case .getPayments: return "getProfilePayments"
        case .getNotifications: return "getProfileNotifications"
        case .updateNotifications: return "updateProfileNotifications"
        case .getSettings: return "getProfileSettings"
        }
    }
}

#if DEBUG
extension ProfileEndpoint {
    static let previewEndpoints: [ProfileEndpoint] = [
        .getProfile,
        .getFavorites,
        .getPasses,
        .getPayments,
        .getNotifications,
        .getSettings
    ]
}
#endif 