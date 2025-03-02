import Foundation
import SwiftUI

// Define base view model since Core module doesn't exist
class BaseViewModel {
    @Published var isLoading: Bool = false
    var error: Error?
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    func handleError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
        self.error = error
    }
}

// Define Profile model since Models module doesn't exist
struct Profile: Codable {
    var id: String
    var name: String
    var email: String
    var phoneNumber: String?
    var imageURL: URL?
    var preferences: Preferences
    
    struct Preferences: Codable {
        var notificationsEnabled: Bool
        var emailUpdatesEnabled: Bool
        var favoriteVenues: [String]
    }
    
    // Preview helper
    static var preview: Profile {
        Profile(
            id: "user-123",
            name: "John Doe",
            email: "john.doe@example.com",
            phoneNumber: "555-123-4567",
            imageURL: nil,
            preferences: Preferences(
                notificationsEnabled: true,
                emailUpdatesEnabled: false,
                favoriteVenues: ["venue-1", "venue-2"]
            )
        )
    }
}

// Define APIClient for this file
class APIClient {
    static let shared = APIClient()
    
    enum Endpoint {
        case getProfile
        case updateProfile(Profile)
        case updateProfileImage(Data)
        case updatePreferences([String: Any])
    }
    
    func request<T>(_ endpoint: Endpoint) async throws -> T {
        // Mock implementation
        switch endpoint {
        case .getProfile:
            return Profile.preview as! T
        case .updateProfile(let profile):
            return profile as! T
        case .updateProfileImage:
            return Profile.preview as! T
        case .updatePreferences:
            var profile = Profile.preview
            return profile as! T
        }
    }
}

final class ProfileViewModel: BaseViewModel, ObservableObject {
    @Published private(set) var profile: Profile?
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
        super.init()
    }
    
    @MainActor
    func loadProfile() async {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            profile = try await apiClient.request(.getProfile)
        } catch {
            handleError(error)
        }
    }
    
    func updateProfile(_ updatedProfile: Profile) async throws {
        do {
            profile = try await apiClient.request(.updateProfile(updatedProfile))
        } catch {
            throw error
        }
    }
    
    func updateProfileImage(_ imageData: Data) async throws {
        do {
            profile = try await apiClient.request(.updateProfileImage(imageData))
        } catch {
            throw error
        }
    }
    
    func updatePreferences(_ preferences: [String: Any]) async throws {
        do {
            profile = try await apiClient.request(.updatePreferences(preferences))
        } catch {
            throw error
        }
    }
    
    func toggleNotifications() {
        guard var preferences = profile?.preferences else { return }
        preferences.notificationsEnabled.toggle()
        Task {
            do {
                try await updatePreferences(["notificationsEnabled": preferences.notificationsEnabled])
            } catch {
                self.error = error
            }
        }
    }
    
    func toggleEmailUpdates() {
        guard var preferences = profile?.preferences else { return }
        preferences.emailUpdatesEnabled.toggle()
        Task {
            do {
                try await updatePreferences(["emailUpdatesEnabled": preferences.emailUpdatesEnabled])
            } catch {
                self.error = error
            }
        }
    }
    
    func toggleFavoriteVenue(_ venueId: String) {
        guard var preferences = profile?.preferences else { return }
        if preferences.favoriteVenues.contains(venueId) {
            preferences.favoriteVenues.removeAll { $0 == venueId }
        } else {
            preferences.favoriteVenues.append(venueId)
        }
        Task {
            do {
                try await updatePreferences(["favoriteVenues": preferences.favoriteVenues])
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
extension ProfileViewModel {
    static var preview: ProfileViewModel {
        let viewModel = ProfileViewModel()
        viewModel.profile = .preview
        return viewModel
    }
}
#endif 