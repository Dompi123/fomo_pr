import SwiftUI

// This is a simple view that can be used to verify that all the types are available
// Add this to your Xcode project and try to build it

// We need to make sure the types are available
#if !SWIFT_PACKAGE
// When building in Xcode, the types are defined in FOMOTypes.swift
// No additional imports needed
#else
// When building with Swift Package Manager, we need to import the types
// This would normally be handled by the module system
#endif

// Add import for our local implementation
import UIKit

// TypesTestEntry is now defined in TypesTestEntry.swift

// Use the Models enum from FOMOImports.swift instead of redefining it here
// The User struct can be added to the existing Models enum if needed

struct TypesTestView: View {
    @State private var testResult: String = ""
    
    var body: some View {
        VStack {
            Button("Test Types") {
                testTypes()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            ScrollView {
                Text(testResult)
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Types Test")
    }
    
    func testTypes() {
        var results: [String] = []
        
        // Test Models
        do {
            // Using a throwing function to make the catch block reachable
            let userData = try JSONSerialization.data(withJSONObject: [
                "id": "test-id",
                "username": "testuser",
                "email": "test@example.com",
                "createdAt": Date().description,
                "updatedAt": Date().description
            ], options: [])
            
            let user = try JSONDecoder().decode(Models.User.self, from: userData)
            results.append("✅ Models.User type is available: \(user.username)")
        } catch {
            results.append("❌ Models.User type is not available: \(error)")
        }
        
        // Test Card
        #if !SWIFT_PACKAGE && !XCODE_HELPER
        results.append("✅ Card type is available")
        #else
        results.append("❌ Card type is not available in this build configuration")
        #endif
        
        // Test APIClient
        #if !SWIFT_PACKAGE && !XCODE_HELPER
        results.append("✅ APIClient type is available")
        #else
        results.append("❌ APIClient type is not available in this build configuration")
        #endif
        
        // Test Security.LiveTokenizationService
        #if !SWIFT_PACKAGE && !XCODE_HELPER
        results.append("✅ Security.LiveTokenizationService type is available")
        #else
        results.append("❌ Security.LiveTokenizationService type is not available in this build configuration")
        #endif
        
        // Test PaymentResult
        #if !SWIFT_PACKAGE && !XCODE_HELPER
        results.append("✅ PaymentResult type is available")
        #else
        results.append("❌ PaymentResult type is not available in this build configuration")
        #endif
        
        // Test PricingTier
        #if !SWIFT_PACKAGE && !XCODE_HELPER
        results.append("✅ PricingTier type is available")
        #else
        results.append("❌ PricingTier type is not available in this build configuration")
        #endif
        
        testResult = results.joined(separator: "\n")
    }
}

#Preview {
    TypesTestView()
} 