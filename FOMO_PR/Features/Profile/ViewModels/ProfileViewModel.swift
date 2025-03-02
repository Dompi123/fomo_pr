import Foundation
import SwiftUI
import Combine
import OSLog

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
    
    init() {
        logger.debug("ProfileViewModel initializing")
        print("DEBUG: ProfileViewModel initializing")
        
        Task {
            logger.debug("Starting initial profile fetch")
            print("DEBUG: Starting initial profile fetch")
            await fetchProfile()
        }
    }
    
    func fetchProfile() async {
        logger.debug("fetchProfile called")
        print("DEBUG: fetchProfile called")
        isLoading = true
        errorMessage = nil
        
        do {
            // Create a URL request directly
            guard let url = URL(string: "https://api.fomopr.com/profile") else {
                logger.error("Invalid URL for profile fetch")
                print("ERROR: Invalid URL for profile fetch")
                self.errorMessage = "Invalid URL"
                self.isLoading = false
                return
            }
            
            logger.debug("Creating URL request to \(url.absoluteString)")
            print("DEBUG: Creating URL request to \(url.absoluteString)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            logger.debug("Sending network request")
            print("DEBUG: Sending network request")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    logger.error("Invalid response type")
                    print("ERROR: Invalid response type")
                    self.errorMessage = "Invalid response"
                    self.isLoading = false
                    return
                }
                
                logger.debug("Received response with status code: \(httpResponse.statusCode)")
                print("DEBUG: Received response with status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    logger.debug("Decoding profile data")
                    print("DEBUG: Decoding profile data")
                    
                    do {
                        let profile = try JSONDecoder().decode(Profile.self, from: data)
                        logger.debug("Profile decoded successfully: \(profile.id)")
                        print("DEBUG: Profile decoded successfully: \(profile.id)")
                        
                        self.profile = profile
                        self.isLoading = false
                    } catch {
                        logger.error("Failed to decode profile: \(error.localizedDescription)")
                        print("ERROR: Failed to decode profile: \(error.localizedDescription)")
                        self.errorMessage = "Failed to decode profile: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                } else {
                    logger.error("Server returned error: \(httpResponse.statusCode)")
                    print("ERROR: Server returned error: \(httpResponse.statusCode)")
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    self.isLoading = false
                }
            } catch {
                logger.error("Network request failed: \(error.localizedDescription)")
                print("ERROR: Network request failed: \(error.localizedDescription)")
                self.errorMessage = "Network error: \(error.localizedDescription)"
                self.isLoading = false
            }
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            print("ERROR: Unexpected error: \(error.localizedDescription)")
            self.errorMessage = "Unexpected error: \(error.localizedDescription)"
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
        let viewModel = ProfileViewModel()
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
