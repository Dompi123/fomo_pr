import Foundation
import SwiftUI
import Combine
import FOMO_PR
// import FOMOTypes - Commenting out as it's causing issues

// Use the User type from FOMO_PR instead of defining Profile locally
typealias Profile = User

// Extension to add preview functionality to User/Profile
extension User {
    static var profilePreview: User {
        User(
            id: "user-123",
            email: "john.doe@example.com",
            firstName: "John",
            lastName: "Doe",
            profileImageURL: URL(string: "https://example.com/profile.jpg"),
            phone: "+1 (555) 123-4567"
        )
    }
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Using URLSession directly instead of APIClient
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            await fetchProfile()
        }
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
        guard profile != nil else { return }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                // Create a URL request directly
                var request = URLRequest(url: URL(string: "https://api.fomopr.com/profile")!)
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
        guard let profile = profile else { return }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                // Create updated profile
                let updatedProfile = Profile(
                    id: profile.id,
                    email: profile.email,
                    firstName: profile.firstName,
                    lastName: profile.lastName,
                    profileImageURL: profile.profileImageURL,
                    phone: profile.phone
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
        let viewModel = ProfileViewModel()
        viewModel.profile = Profile(
            id: "user123",
            email: "john.doe@example.com",
            firstName: "John",
            lastName: "Doe",
            profileImageURL: URL(string: "https://example.com/profile.jpg"),
            phone: "+1 (555) 123-4567"
        )
        return viewModel
    }
}
