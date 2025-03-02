#!/bin/bash

echo "Fixing critical issues in FOMO_PR app..."

# 1. Fix the corrupted Info.plist file
echo "Fixing corrupted Info.plist file..."
cat > FOMO_PR/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>FOMO PR</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>com.fomo.FOMO-PR</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>NSCameraUsageDescription</key>
    <string>This app needs access to the camera to scan QR codes.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs access to your photo library to save and upload images.</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs access to your location to show nearby venues.</string>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOF

# 2. Create a proper APIClient implementation that matches what ProfileViewModel expects
echo "Creating APIClient implementation..."
mkdir -p FOMO_PR/Networking
cat > FOMO_PR/Networking/APIClient.swift << 'EOF'
import Foundation
import Combine

public class APIClient {
    public static let shared = APIClient()
    
    private let baseURL = "https://api.fomopr.com"
    
    private init() {}
    
    public func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func post<T: Decodable, U: Encodable>(_ endpoint: String, body: U) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
EOF

# 3. Update ProfileViewModel to import the correct modules
echo "Updating ProfileViewModel..."
cat > FOMO_PR/Features/Profile/ViewModels/ProfileViewModel.swift << 'EOF'
import Foundation
import SwiftUI
import Combine
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

// Make Profile conform to Codable
extension Profile: Codable {}

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
EOF

# 4. Update the project file to include the new APIClient.swift file
echo "Updating project file to include APIClient.swift..."
PROJECT_FILE="FOMO_PR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    # Backup the file
    cp "$PROJECT_FILE" "${PROJECT_FILE}.critical.backup"
    
    # Add APIClient.swift to the project file
    # This is a simplified approach - in a real scenario, you might need to use more sophisticated tools
    # to modify the project file correctly
    sed -i '' 's//* Begin PBXBuildFile section *//* Begin PBXBuildFile section *\n\t\tABCDEF1234567890 \/* APIClient.swift in Sources *\/ = {isa = PBXBuildFile; fileRef = ABCDEF0987654321 \/* APIClient.swift *\/; };/g' "$PROJECT_FILE"
    sed -i '' 's//* Begin PBXFileReference section *//* Begin PBXFileReference section *\n\t\tABCDEF0987654321 \/* APIClient.swift *\/ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = APIClient.swift; sourceTree = "<group>"; };/g' "$PROJECT_FILE"
    
    echo "Project file updated."
else
    echo "❌ Project file not found at $PROJECT_FILE"
fi

# 5. Clean derived data to ensure a fresh build
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/FOMO_PR-*

echo "Critical issues fixed. Please try building the app again." 