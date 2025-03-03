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
        print("DEBUG: Starting API key rotation")
        
        do {
            let newKey = try await generateSecureKey()
            
            // Validate the new key with the server
            guard try await validateAPIKey(newKey) else {
                return false
            }
            
            // Store the new key
            try await store(key: .apiKey, value: newKey)
            logger.info("Key rotation successful")
            print("DEBUG: API key rotation completed successfully")
            return true
        } catch {
            logger.error("Key rotation failed: \(error.localizedDescription)")
            throw KeychainError.rotationFailed(error)
        }
    }
    
    /// Generates a cryptographically secure key
    private func generateSecureKey() throws -> String {
        logger.debug("Generating secure key")
        print("DEBUG: Generating secure key")
        
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes { 
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!) 
        }
        
        guard result == errSecSuccess else {
            logger.error("Failed to generate secure key: \(result)")
            print("ERROR: Failed to generate secure key: \(result)")
            throw KeychainError.unexpectedStatus(result)
        }
        
        let secureKey = keyData.base64EncodedString()
        logger.debug("Secure key generated successfully")
        print("DEBUG: Secure key generated successfully")
        
        return secureKey
    }
    
    /// Sets a value in the keychain
    /// - Parameters:
    ///   - value: The value to store
    ///   - key: The key to store it under
    public func store(key: KeychainKey, value: String) async throws {
        logger.debug("Storing value for key: \(key.rawValue)")
        print("DEBUG: Storing value for key: \(key.rawValue)")
        
        guard !value.isEmpty else {
            logger.error("Cannot store empty value for key: \(key.rawValue)")
            print("ERROR: Cannot store empty value for key: \(key.rawValue)")
            throw KeychainError.emptyValue
        }
        
        // Try to delete any existing value first
        try? await deleteValue(for: key)
        
        let valueData = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrService as String: key.service,
            kSecValueData as String: valueData,
            kSecAttrAccessible as String: key.accessibility
        ]
        
        var status: OSStatus = 0
        
        queue.async {
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        if status != errSecSuccess {
            logger.error("Failed to store value: \(status)")
            print("ERROR: Failed to store value: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
        
        logger.debug("Value stored successfully for key: \(key.rawValue)")
        print("DEBUG: Value stored successfully for key: \(key.rawValue)")
    }
    
    /// Gets a value from the keychain
    /// - Parameter key: The key to retrieve
    /// - Returns: The stored value
    public func retrieveValue(for key: KeychainKey) async throws -> String? {
        logger.debug("Retrieving value for key: \(key.rawValue)")
        print("DEBUG: Retrieving value for key: \(key.rawValue)")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrService as String: key.service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        var status: OSStatus = 0
        
        queue.async {
            status = SecItemCopyMatching(query as CFDictionary, &item)
        }
        
        guard status != errSecItemNotFound else {
            logger.debug("No value found for key: \(key.rawValue)")
            print("DEBUG: No value found for key: \(key.rawValue)")
            return nil
        }
        
        guard status == errSecSuccess else {
            logger.error("Failed to retrieve value: \(status)")
            print("ERROR: Failed to retrieve value: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
            logger.error("Retrieved value has invalid format")
            print("ERROR: Retrieved value has invalid format")
            throw KeychainError.invalidItemFormat
        }
        
        logger.debug("Value retrieved successfully for key: \(key.rawValue)")
        print("DEBUG: Value retrieved successfully for key: \(key.rawValue)")
        
        return value
    }
    
    /// Deletes a value from the keychain
    /// - Parameter key: The key to delete
    public func deleteValue(for key: KeychainKey) async throws {
        logger.debug("Deleting value for key: \(key.rawValue)")
        print("DEBUG: Deleting value for key: \(key.rawValue)")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrService as String: key.service
        ]
        
        var status: OSStatus = 0
        
        queue.async {
            status = SecItemDelete(query as CFDictionary)
        }
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Failed to delete value: \(status)")
            print("ERROR: Failed to delete value: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
        
        logger.debug("Value deleted successfully for key: \(key.rawValue)")
        print("DEBUG: Value deleted successfully for key: \(key.rawValue)")
    }
    
    public func updateAPIKey(_ newKey: String) async throws -> Bool {
        logger.debug("Updating API key")
        print("DEBUG: Updating API key")
        
        guard !newKey.isEmpty else {
            logger.error("Cannot update with empty API key")
            print("ERROR: Cannot update with empty API key")
            throw KeychainError.emptyValue
        }
        
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
    
    deinit {
        logger.debug("KeychainManager deinitializing")
        print("DEBUG: KeychainManager deinitializing")
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
    case duplicateItem
    case itemNotFound
    case invalidItemFormat
    case unexpectedStatus(OSStatus)
    case invalidKey
    case emptyValue
    
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
        case .duplicateItem:
            return "Duplicate item found in keychain"
        case .itemNotFound:
            return "Item not found in keychain"
        case .invalidItemFormat:
            return "Invalid item format in keychain"
        case .invalidKey:
            return "Invalid key format in keychain"
        case .emptyValue:
            return "Empty value in keychain"
        case .unexpectedStatus(let status):
            return "Unexpected status from keychain operation: \(status)"
        }
    }
}
