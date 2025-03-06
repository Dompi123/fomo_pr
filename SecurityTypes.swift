import Foundation
import SwiftUI

#if PREVIEW_MODE
// Define a namespace for security types
enum FOMOSecurity {
    // Mock implementation of LiveTokenizationService
    class LiveTokenizationService {
        static let shared = LiveTokenizationService()
        
        func tokenize(card: Card) -> String {
            return "mock_token"
        }
    }
}
#endif 

// Verify that security types are available
func verifySecurityTypes() {
    #if PREVIEW_MODE
    print("FOMOSecurity namespace is available in preview mode")
    print("LiveTokenizationService is available: \(FOMOSecurity.LiveTokenizationService.shared)")
    #else
    print("Using production Security module")
    #endif
}
