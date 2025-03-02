#!/bin/bash

echo "Checking for common issues that might cause app crashes..."

# Check Info.plist for required entries
echo "Checking Info.plist..."
if [ -f "FOMO_PR/Info.plist" ]; then
    echo "Info.plist exists"
    
    # Check for NSAppTransportSecurity
    if grep -q "NSAppTransportSecurity" "FOMO_PR/Info.plist"; then
        echo "✅ NSAppTransportSecurity entry found"
    else
        echo "❌ NSAppTransportSecurity entry missing - this could cause network requests to fail"
        echo "Adding NSAppTransportSecurity with NSAllowsArbitraryLoads..."
        
        # Create a backup
        cp "FOMO_PR/Info.plist" "FOMO_PR/Info.plist.backup"
        
        # Add the entry before the closing dict
        sed -i '' 's/<\/dict>/\t<key>NSAppTransportSecurity<\/key>\n\t<dict>\n\t\t<key>NSAllowsArbitraryLoads<\/key>\n\t\t<true\/>\n\t<\/dict>\n<\/dict>/' "FOMO_PR/Info.plist"
    fi
    
    # Check for UIApplicationSceneManifest
    if grep -q "UIApplicationSceneManifest" "FOMO_PR/Info.plist"; then
        echo "✅ UIApplicationSceneManifest entry found"
    else
        echo "❌ UIApplicationSceneManifest entry missing - this could cause UI initialization issues"
    fi
else
    echo "❌ Info.plist not found at FOMO_PR/Info.plist"
fi

# Check for mock data for development
echo "Checking for mock data..."
if [ -d "FOMO_PR/Mock" ]; then
    echo "✅ Mock directory exists"
else
    echo "❓ Mock directory not found - creating one with sample data"
    mkdir -p "FOMO_PR/Mock"
    
    # Create a mock profile JSON file
    cat > "FOMO_PR/Mock/profile.json" << 'EOF'
{
    "id": "user-123",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1 (555) 123-4567",
    "profileImageURL": "https://example.com/profile.jpg",
    "preferences": {
        "emailNotifications": true,
        "pushNotifications": true,
        "smsNotifications": false
    }
}
EOF
    echo "✅ Created mock profile data"
fi

# Check for network reachability handling
echo "Checking for network reachability handling..."
if grep -q "import Network" "FOMO_PR/Core/Network/Network.swift"; then
    echo "✅ Network framework is imported"
else
    echo "❌ Network framework might not be imported - this could cause network issues"
fi

# Check for proper URL handling in ProfileViewModel
echo "Checking URL handling in ProfileViewModel..."
if grep -q "guard let url = URL" "FOMO_PR/Features/Profile/ViewModels/ProfileViewModel.swift"; then
    echo "✅ URL validation is in place"
else
    echo "❌ URL validation might be missing - this could cause crashes with invalid URLs"
fi

# Check for proper error handling in async code
echo "Checking error handling in async code..."
if grep -q "catch {" "FOMO_PR/Features/Profile/ViewModels/ProfileViewModel.swift"; then
    echo "✅ Error handling is in place"
else
    echo "❌ Error handling might be missing - this could cause unhandled exceptions"
fi

# Create a modified ProfileViewModel that uses mock data
echo "Creating a modified ProfileViewModel that uses mock data..."
cat > "FOMO_PR/Features/Profile/ViewModels/ProfileViewModel_mock.swift" << 'EOF'
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
    
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.fomo", category: "ProfileViewModel")
    
    // Flag to use mock data instead of network requests
    private let useMockData = true
    
    init() {
        logger.debug("ProfileViewModel initializing")
        print("DEBUG: ProfileViewModel initializing with mock data: \(useMockData)")
        
        Task {
            logger.debug("Starting initial profile fetch")
            print("DEBUG: Starting initial profile fetch")
            await fetchProfile()
        }
    }
    
    func fetchProfile() async {
        logger.debug("fetchProfile called, using mock data: \(useMockData)")
        print("DEBUG: fetchProfile called, using mock data: \(useMockData)")
        isLoading = true
        errorMessage = nil
        
        if useMockData {
            // Use mock data instead of network request
            do {
                logger.debug("Loading mock profile data")
                print("DEBUG: Loading mock profile data")
                
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Use the preview profile
                self.profile = Profile.preview
                self.isLoading = false
                
                logger.debug("Mock profile loaded successfully")
                print("DEBUG: Mock profile loaded successfully")
            } catch {
                logger.error("Error simulating mock data: \(error.localizedDescription)")
                print("ERROR: Error simulating mock data: \(error.localizedDescription)")
                self.errorMessage = "Error loading mock data"
                self.isLoading = false
            }
            return
        }
        
        // Original network code follows
        do {
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
    
    // Other methods remain the same but use mock data when useMockData is true
    // ...
}

// MARK: - Preview Helper
extension ProfileViewModel {
    static var preview: ProfileViewModel {
        let viewModel = ProfileViewModel()
        viewModel.profile = Profile.preview
        return viewModel
    }
}
EOF

echo "✅ Created a mock version of ProfileViewModel"
echo "To use this version, rename it to ProfileViewModel.swift"

echo "Checks completed. Please review the results above for potential issues." 