import Foundation
import SwiftUI
// import FOMO_PR - Commenting out as it's causing issues

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

// Define the ProfileViewModel class
class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        getProfile()
    }
    
    func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.isLoading = loading
        }
    }
    
    func setError(_ error: Error?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    func getProfile() {
        setLoading(true)
        setError(nil)
        
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Mock data
                let profile = Profile.preview
                
                DispatchQueue.main.async {
                    self.profile = profile
                    self.setLoading(false)
                }
            } catch {
                setError(error)
                setLoading(false)
            }
        }
    }
    
    func updateProfile(name: String, email: String, phone: String) {
        guard var profile = profile else { return }
        
        setLoading(true)
        setError(nil)
        
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_500_000_000)
                
                // Create updated profile
                let updatedProfile = Profile(
                    id: profile.id,
                    name: name,
                    email: email,
                    phone: phone,
                    profileImageURL: profile.profileImageURL,
                    preferences: profile.preferences
                )
                
                DispatchQueue.main.async {
                    self.profile = updatedProfile
                    self.setLoading(false)
                }
            } catch {
                setError(error)
                setLoading(false)
            }
        }
    }
    
    func updateProfileImage(imageURL: URL) {
        guard var profile = profile else { return }
        
        setLoading(true)
        setError(nil)
        
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_500_000_000)
                
                // Create updated profile
                let updatedProfile = Profile(
                    id: profile.id,
                    name: profile.name,
                    email: profile.email,
                    phone: profile.phone,
                    profileImageURL: imageURL,
                    preferences: profile.preferences
                )
                
                DispatchQueue.main.async {
                    self.profile = updatedProfile
                    self.setLoading(false)
                }
            } catch {
                setError(error)
                setLoading(false)
            }
        }
    }
    
    func updatePreferences(preferences: [String: Bool]) {
        guard var profile = profile else { return }
        
        setLoading(true)
        setError(nil)
        
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Create updated profile
                let updatedProfile = Profile(
                    id: profile.id,
                    name: profile.name,
                    email: profile.email,
                    phone: profile.phone,
                    profileImageURL: profile.profileImageURL,
                    preferences: preferences
                )
                
                DispatchQueue.main.async {
                    self.profile = updatedProfile
                    self.setLoading(false)
                }
            } catch {
                setError(error)
                setLoading(false)
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
