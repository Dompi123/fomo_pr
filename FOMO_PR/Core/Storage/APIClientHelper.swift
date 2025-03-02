import Foundation

// Define a local APIClient type that can be used by KeychainManager
// This is a temporary solution until we resolve the module issue
public class APIClientHelper {
    public static let shared = APIClientHelper()
    
    private init() {}
    
    public func validateAPIKey(_ key: String) async throws -> Bool {
        // Simulate API key validation
        try await Task.sleep(nanoseconds: 500_000_000)
        print("Validating API key: \(key)")
        return true
    }
}

// Extension to help with module diagnostics
extension APIClientHelper {
    public static func printModuleInfo() {
        print("=== APIClientHelper Module Info ===")
        
        // Check if Network module is available
        #if canImport(Network)
        print("Network module can be imported")
        #else
        print("Network module cannot be imported")
        #endif
        
        // Try to get information about the Network module
        let networkBundleName = "Network"
        if let networkBundle = Bundle(identifier: networkBundleName) {
            print("Found Network bundle: \(networkBundle)")
        } else {
            print("Network bundle not found")
        }
        
        // List all available bundles
        print("Available bundles:")
        for bundle in Bundle.allBundles {
            print("- \(bundle.bundleIdentifier ?? "unknown")")
        }
        
        print("===============================")
    }
} 