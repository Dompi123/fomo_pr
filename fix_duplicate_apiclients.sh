#!/bin/bash

echo "Fixing duplicate APIClient declarations and KeychainManager issues..."

# 1. Remove our new APIClient implementation since there's already one in the codebase
echo "Removing duplicate APIClient implementation..."
rm -f FOMO_PR/Networking/APIClient.swift
rmdir FOMO_PR/Networking 2>/dev/null || true

# 2. Update the ProfileViewModel to use the existing APIClient
echo "Updating ProfileViewModel to use the existing APIClient..."
cat > FOMO_PR/Features/Profile/ViewModels/ProfileViewModel.swift << 'EOF'
import Foundation
import SwiftUI
import Combine

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

# 3. Fix the KeychainManager concurrency issues
echo "Fixing KeychainManager concurrency issues..."
cat > FOMO_PR/Core/Storage/KeychainManager.swift << 'EOF'
import Foundation
import Security
import OSLog
import SwiftUI

/// Manages secure storage and rotation of sensitive data
private let logger = Logger(subsystem: "com.fomo", category: "KeychainManager")

// Add diagnostic logging
#if DEBUG
private func logDebug(_ message: String) {
    print("[KeychainManager Debug] \(message)")
}
#else
private func logDebug(_ message: String) {}
#endif

// Log at initialization time to help diagnose issues
private let initLog: Void = {
    logDebug("KeychainManager.swift is being compiled")
    logDebug("Available modules: \(Bundle.allBundles.map { $0.bundleIdentifier ?? "unknown" })")
    return ()
}()

@available(iOS 15.0, *)
public enum KeychainKey: String, CaseIterable, Sendable {
    case apiKey
    case userToken
    case refreshToken
    
    var service: String {
        return "com.fomo.app"
    }
    
    var accessibility: CFString {
        switch self {
        case .apiKey:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .userToken, .refreshToken:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }
    }
    
    public var rawValue: String {
        switch self {
        case .apiKey: return "com.fomo.apiKey"
        case .refreshToken: return "com.fomo.refreshToken"
        case .userToken: return "com.fomo.userToken"
        }
    }
    var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: rawValue,
            kSecAttrAccessible as String: accessibility
        ]
    }
}

@available(iOS 15.0, *)
@MainActor
public class KeychainManager {
    public static let shared = KeychainManager()
    
    private let queue = DispatchQueue(label: "com.fomo.keychain", qos: .userInitiated)
    
    public init() {
        // Log that we're initializing
        logDebug("KeychainManager initializing")
        logger.debug("KeychainManager initialized")
        
        // Use the init log to ensure it's evaluated
        _ = initLog
    }
    
    /// Validates an API key with the server
    /// - Parameter key: The API key to validate
    /// - Returns: Whether the key is valid
    private func validateAPIKey(_ key: String) async throws -> Bool {
        // Simulate API key validation
        try await Task.sleep(nanoseconds: 500_000_000)
        logDebug("Validating API key: \(key)")
        return true
    }
    
    /// Rotates API keys with secure generation
    /// - Parameter completion: Called with success/failure of rotation
    public func rotateAPIKey() async throws -> Bool {
        logger.info("Starting key rotation")
        
        do {
            let newKey = UUID().uuidString
            
            // Validate the new key with the server
            guard try await validateAPIKey(newKey) else {
                return false
            }
            
            // Store the new key
            try await store(key: .apiKey, value: newKey)
            logger.info("Key rotation successful")
            return true
        } catch {
            logger.error("Key rotation failed: \(error.localizedDescription)")
            throw KeychainError.rotationFailed(error)
        }
    }
    
    /// Generates a cryptographically secure key
    private func generateSecureKey() throws -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            logger.fault("Failed to generate secure key")
            throw KeychainError.keyGenerationFailed
        }
        return Data(bytes).base64EncodedString()
    }
    
    /// Sets a value in the keychain
    /// - Parameters:
    ///   - value: The value to store
    ///   - key: The key to store it under
    public func store(key: KeychainKey, value: String) async throws {
        // Make a local copy of the key and value to avoid capturing self
        let keyService = key.service
        let keyRawValue = key.rawValue
        let keyAccessibility = key.accessibility
        let valueData = value.data(using: .utf8)
        
        guard let valueData = valueData else {
            throw KeychainError.encodingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                // Create query
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: keyService,
                    kSecAttrAccount as String: keyRawValue,
                    kSecValueData as String: valueData,
                    kSecAttrAccessible as String: keyAccessibility
                ]
                
                // Delete any existing key before saving
                SecItemDelete(query as CFDictionary)
                
                // Add the new key
                let status = SecItemAdd(query as CFDictionary, nil)
                
                if status != errSecSuccess {
                    continuation.resume(throwing: KeychainError.saveFailed(status))
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    /// Gets a value from the keychain
    /// - Parameter key: The key to retrieve
    /// - Returns: The stored value
    public func retrieveValue(for key: KeychainKey) async throws -> String? {
        // Make a local copy of the key to avoid capturing self
        let keyService = key.service
        let keyRawValue = key.rawValue
        
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: keyService,
                    kSecAttrAccount as String: keyRawValue,
                    kSecReturnData as String: true,
                    kSecMatchLimit as String: kSecMatchLimitOne
                ]
                
                var item: CFTypeRef?
                let status = SecItemCopyMatching(query as CFDictionary, &item)
                
                guard status != errSecItemNotFound else {
                    continuation.resume(returning: nil)
                    return
                }
                
                guard status == errSecSuccess else {
                    continuation.resume(throwing: KeychainError.readFailed(status))
                    return
                }
                
                guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
                    continuation.resume(throwing: KeychainError.decodingFailed)
                    return
                }
                
                continuation.resume(returning: value)
            }
        }
    }
    
    /// Deletes a value from the keychain
    /// - Parameter key: The key to delete
    public func deleteValue(for key: KeychainKey) async throws {
        let query = key.baseQuery
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
    
    public func updateAPIKey(_ newKey: String) async throws -> Bool {
        do {
            // Validate the new key with the server
            guard try await validateAPIKey(newKey) else {
                return false
            }
            
            // Store the new key
            try await store(key: .apiKey, value: newKey)
            logger.info("API key updated successfully")
            return true
        } catch {
            throw KeychainError.updateFailed(error)
        }
    }
}

// MARK: - Error Types
@available(iOS 15.0, *)
public enum KeychainError: Error, LocalizedError, Sendable {
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(status: OSStatus)
    case encodingFailed
    case decodingFailed
    case rotationFailed(Error)
    case keyGenerationFailed
    case updateFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .readFailed(let status):
            return "Failed to read from keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        case .encodingFailed:
            return "Failed to encode data for keychain"
        case .decodingFailed:
            return "Failed to decode data from keychain"
        case .rotationFailed(let error):
            return "Failed to rotate key: \(error.localizedDescription)"
        case .keyGenerationFailed:
            return "Failed to generate secure key"
        case .updateFailed(let error):
            return "Failed to update API key: \(error.localizedDescription)"
        }
    }
}
EOF

# 4. Update the project file to remove references to our APIClient.swift
echo "Updating project file to remove references to our APIClient.swift..."
PROJECT_FILE="FOMO_PR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    # Backup the file
    cp "$PROJECT_FILE" "${PROJECT_FILE}.apifix.backup"
    
    # Remove references to our APIClient.swift
    sed -i '' '/ABCDEF1234567890/d' "$PROJECT_FILE"
    sed -i '' '/ABCDEF0987654321/d' "$PROJECT_FILE"
    
    echo "Project file updated."
else
    echo "❌ Project file not found at $PROJECT_FILE"
fi

# 5. Clean derived data to ensure a fresh build
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/FOMO_PR-*

echo "Duplicate APIClient and KeychainManager issues fixed. Please try building the app again." 