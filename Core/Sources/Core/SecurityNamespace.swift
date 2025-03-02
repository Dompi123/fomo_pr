import Foundation

// Define the Security namespace in the Core module
public enum Security {
    // Empty placeholder to ensure the namespace exists
    // We'll add the actual types later
}

// Log function to help with debugging
public func logSecurityNamespaceAvailability() {
    print("Security namespace is available in Core module: \(Security.self)")
    
    // Try to access the TokenizationService type if it exists
    #if DEBUG
    print("Checking for TokenizationService in Security namespace...")
    // This will be a compile-time check
    #endif
} 