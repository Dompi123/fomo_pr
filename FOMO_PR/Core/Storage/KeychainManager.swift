import Foundation
import Security
import OSLog
import SwiftUI

/// Manages secure storage and rotation of sensitive data
private let logger = Logger(subsystem: "com.fomo", category: "KeychainManager")

// Simplify the diagnostic logging
#if DEBUG
private func logDebug(_ message: String) {
    print("[KeychainManager Debug] \(message)")
}
#else
private func logDebug(_ message: String) {}
#endif

public enum KeychainKey: String, CaseIterable {
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

@MainActor
public class KeychainManager {
    public static let shared = KeychainManager()
    
    private let queue = DispatchQueue(label: "com.fomo.keychain", qos: .userInitiated)
    
    public init() {
        logDebug("KeychainManager initialized")
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
    /// - Returns: Whether the rotation was successful
    public func rotateAPIKey() async throws -> Bool {
        logDebug("Starting key rotation")
        
        do {
            let newKey = UUID().uuidString
            
            // Validate the new key with the server
            guard try await validateAPIKey(newKey) else {
                return false
            }
            
            // Store the new key
            try await storeSimple(key: .apiKey, value: newKey)
            logDebug("Key rotation successful")
            return true
        } catch {
            logDebug("Key rotation failed: \(error.localizedDescription)")
            throw KeychainError.rotationFailed(error)
        }
    }
    
    /// Sets a value in the keychain using a simpler approach
    /// - Parameters:
    ///   - key: The key to store it under
    ///   - value: The value to store
    public func storeSimple(key: KeychainKey, value: String) async throws {
        return try await Task {
            // Convert string to data
            guard let valueData = value.data(using: .utf8) else {
                throw KeychainError.encodingFailed
            }
            
            // Create query
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: key.service,
                kSecAttrAccount as String: key.rawValue,
                kSecValueData as String: valueData,
                kSecAttrAccessible as String: key.accessibility
            ]
            
            // Delete any existing key before saving
            SecItemDelete(query as CFDictionary)
            
            // Add the new key
            let status = SecItemAdd(query as CFDictionary, nil)
            
            if status != errSecSuccess {
                throw KeychainError.saveFailed(status)
            }
        }.value
    }
    
    /// Gets a value from the keychain using a simpler approach
    /// - Parameter key: The key to retrieve
    /// - Returns: The stored value
    public func retrieveValueSimple(for key: KeychainKey) async throws -> String? {
        return try await Task {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: key.service,
                kSecAttrAccount as String: key.rawValue,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            
            guard status != errSecItemNotFound else {
                return nil
            }
            
            guard status == errSecSuccess else {
                throw KeychainError.readFailed(status)
            }
            
            guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
                throw KeychainError.decodingFailed
            }
            
            return value
        }.value
    }
    
    /// Deletes a value from the keychain
    /// - Parameter key: The key to delete
    public func deleteValue(for key: KeychainKey) async throws {
        let status = SecItemDelete(key.baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
    
    /// Updates an API key
    /// - Parameter newKey: The new API key
    /// - Returns: Whether the update was successful
    public func updateAPIKey(_ newKey: String) async throws -> Bool {
        do {
            // Validate the new key with the server
            guard try await validateAPIKey(newKey) else {
                return false
            }
            
            // Store the new key
            try await storeSimple(key: .apiKey, value: newKey)
            logDebug("API key updated successfully")
            return true
        } catch {
            throw KeychainError.updateFailed(error)
        }
    }
}

// MARK: - Error Types
public enum KeychainError: Error, LocalizedError {
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(status: OSStatus)
    case encodingFailed
    case decodingFailed
    case rotationFailed(Error)
    case updateFailed(Error)
    case keyGenerationFailed
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .readFailed(let status):
            return "Failed to read from keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        case .encodingFailed:
            return "Failed to encode value for keychain"
        case .decodingFailed:
            return "Failed to decode value from keychain"
        case .rotationFailed(let error):
            return "Failed to rotate API key: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update API key: \(error.localizedDescription)"
        case .keyGenerationFailed:
            return "Failed to generate secure key"
        }
    }
} 
