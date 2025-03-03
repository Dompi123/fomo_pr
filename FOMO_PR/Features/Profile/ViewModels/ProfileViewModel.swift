import Foundation
import SwiftUI
import Combine
import OSLog
import Core

// Define the Profile model
struct Profile: Identifiable {
    let id: String
    var name: String
    var email: String
    var phone: String?
    var profileImageURL: URL?
    var preferences: [String: Bool]
    
    static var preview: Profile {
        Profile(
            id: "user-123",
            name: "John Doe",
            email: "john.doe@example.com",
            phone: "+1 (555) 123-4567",
            profileImageURL: URL(string: "https://example.com/profile.jpg"),
            preferences: [
                "emailNotifications": true,
                "pushNotifications": true,
                "smsNotifications": false
            ]
        )
    }
}

// Make Profile conform to Codable
extension Profile: Codable {}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Using URLSession directly instead of APIClient
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.fomo", category: "ProfileViewModel")
    
    // Regular initializer that requires async
    init() async {
        await fetchProfile()
    }
    
    // Preview-specific initializer
    init(preview: Bool) {
        // This initializer is only for preview purposes
        // No async operations are performed
        print("Creating preview ProfileViewModel")
    }
    
    func fetchProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create a URL request directly
            var request = URLRequest(url: URL(string: "https://api.fomopr.com/profile")!)
            request.httpMethod = "GET"
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let profile = try JSONDecoder().decode(Profile.self, from: data)
            
            self.profile = profile
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch profile: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func updateProfile() {
        guard let profile = profile else { return }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                // Create a URL request directly
                var request = URLRequest(url: URL(string: "https://api.fomopr.com/profile")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let data = try JSONEncoder().encode(profile)
                request.httpBody = data
                
                let (responseData, _) = try await URLSession.shared.data(for: request)
                let updatedProfile = try JSONDecoder().decode(Profile.self, from: responseData)
                
                self.profile = updatedProfile
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func updateProfileImage(url: URL) {
        guard let profile = profile else { return }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                // Create a URL request directly
                var request = URLRequest(url: URL(string: "https://api.fomopr.com/profile/image")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let payload = ["url": url.absoluteString]
                let data = try JSONEncoder().encode(payload)
                request.httpBody = data
                
                let (responseData, _) = try await URLSession.shared.data(for: request)
                let updatedProfile = try JSONDecoder().decode(Profile.self, from: responseData)
                
                self.profile = updatedProfile
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to update profile image: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func updatePreferences(preferences: [String: Bool]) {
        guard var profile = profile else { return }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                // Create updated profile
                let updatedProfile = Profile(
                    id: profile.id,
                    name: profile.name,
                    email: profile.email,
                    phone: profile.phone,
                    profileImageURL: profile.profileImageURL,
                    preferences: preferences
                )
                
                // Update profile on server using direct URL request
                var request = URLRequest(url: URL(string: "https://api.fomopr.com/profile")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let data = try JSONEncoder().encode(updatedProfile)
                request.httpBody = data
                
                let (responseData, _) = try await URLSession.shared.data(for: request)
                let result = try JSONDecoder().decode(Profile.self, from: responseData)
                
                self.profile = result
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to update preferences: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

// MARK: - Preview Helper
extension ProfileViewModel {
    static var preview: ProfileViewModel {
        let viewModel = ProfileViewModel(preview: true)
        viewModel.profile = Profile(
            id: "user123",
            name: "John Doe",
            email: "john.doe@example.com",
            phone: "+1 (555) 123-4567",
            profileImageURL: URL(string: "https://example.com/profile.jpg"),
            preferences: [
                "emailNotifications": true,
                "pushNotifications": true,
                "darkMode": false,
                "savePaymentInfo": true
            ]
        )
        return viewModel
    }
}
