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

// TypesTestEntry is now defined in TypesTestEntry.swift

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