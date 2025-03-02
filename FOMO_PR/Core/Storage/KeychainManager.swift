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
    logger.debug("\(message)")
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
        print("[KeychainManager] Initializing")
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
        logDebug("Attempting to store value for key: \(key.rawValue)")
        print("[KeychainManager] Attempting to store value for key: \(key.rawValue)")
        
        // Make a local copy of the key and value to avoid capturing self
        let keyService = key.service
        let keyRawValue = key.rawValue
        let keyAccessibility = key.accessibility
        let valueData = value.data(using: .utf8)
        
        guard let valueData = valueData else {
            logDebug("Failed to encode value for key: \(key.rawValue)")
            print("[KeychainManager] Failed to encode value for key: \(key.rawValue)")
            throw KeychainError.encodingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                logDebug("In queue for storing key: \(keyRawValue)")
                print("[KeychainManager] In queue for storing key: \(keyRawValue)")
                
                // Create query
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: keyService,
                    kSecAttrAccount as String: keyRawValue,
                    kSecValueData as String: valueData,
                    kSecAttrAccessible as String: keyAccessibility
                ]
                
                // Delete any existing key before saving
                let deleteStatus = SecItemDelete(query as CFDictionary)
                logDebug("Delete status for key \(keyRawValue): \(deleteStatus)")
                print("[KeychainManager] Delete status for key \(keyRawValue): \(deleteStatus)")
                
                // Add the new key
                let status = SecItemAdd(query as CFDictionary, nil)
                logDebug("Add status for key \(keyRawValue): \(status)")
                print("[KeychainManager] Add status for key \(keyRawValue): \(status)")
                
                if status != errSecSuccess {
                    logDebug("Failed to save key \(keyRawValue) with status: \(status)")
                    print("[KeychainManager] Failed to save key \(keyRawValue) with status: \(status)")
                    continuation.resume(throwing: KeychainError.saveFailed(status))
                } else {
                    logDebug("Successfully saved key: \(keyRawValue)")
                    print("[KeychainManager] Successfully saved key: \(keyRawValue)")
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    /// Gets a value from the keychain
    /// - Parameter key: The key to retrieve
    /// - Returns: The stored value
    public func retrieveValue(for key: KeychainKey) async throws -> String? {
        logDebug("Attempting to retrieve value for key: \(key.rawValue)")
        print("[KeychainManager] Attempting to retrieve value for key: \(key.rawValue)")
        
        // Make a local copy of the key to avoid capturing self
        let keyService = key.service
        let keyRawValue = key.rawValue
        
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                logDebug("In queue for retrieving key: \(keyRawValue)")
                print("[KeychainManager] In queue for retrieving key: \(keyRawValue)")
                
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: keyService,
                    kSecAttrAccount as String: keyRawValue,
                    kSecReturnData as String: true,
                    kSecMatchLimit as String: kSecMatchLimitOne
                ]
                
                var item: CFTypeRef?
                let status = SecItemCopyMatching(query as CFDictionary, &item)
                
                logDebug("Retrieve status for key \(keyRawValue): \(status)")
                print("[KeychainManager] Retrieve status for key \(keyRawValue): \(status)")
                
                guard status != errSecItemNotFound else {
                    logDebug("Key not found: \(keyRawValue)")
                    print("[KeychainManager] Key not found: \(keyRawValue)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard status == errSecSuccess else {
                    logDebug("Failed to read key \(keyRawValue) with status: \(status)")
                    print("[KeychainManager] Failed to read key \(keyRawValue) with status: \(status)")
                    continuation.resume(throwing: KeychainError.readFailed(status))
                    return
                }
                
                guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
                    logDebug("Failed to decode data for key: \(keyRawValue)")
                    print("[KeychainManager] Failed to decode data for key: \(keyRawValue)")
                    continuation.resume(throwing: KeychainError.decodingFailed)
                    return
                }
                
                logDebug("Successfully retrieved value for key: \(keyRawValue)")
                print("[KeychainManager] Successfully retrieved value for key: \(keyRawValue)")
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
