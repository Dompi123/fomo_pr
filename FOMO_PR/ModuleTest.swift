import Foundation
import SwiftUI

// This file can be used to test if the module issue is fixed
// It doesn't rely on any module imports, just direct imports of Foundation and SwiftUI

// Try to import all possible modules
#if canImport(Network)
import Network
#endif

#if canImport(Core)
import Core
#endif

#if canImport(Models)
import Models
#endif

// Function to test module availability
public func testModuleAvailability() {
    var results = [String]()
    
    results.append("=== Module Availability Test ===")
    
    // Test Network module
    #if canImport(Network)
    results.append("✅ Network module can be imported")
    
    // Test if APIClient exists in Network
    do {
        // Try to access Network.APIClient
        #if canImport(Network)
        // Check if we can access APIClient directly
        let apiClientType = Network.self
        results.append("✅ Network namespace is available")
        
        // Try to create an instance using reflection
        if let apiClientClass = NSClassFromString("Network.APIClient") {
            results.append("✅ Network.APIClient class exists via reflection")
        } else {
            results.append("❌ Network.APIClient class does not exist via reflection")
        }
        
        // Try to access APIClient directly
        #if canImport(Network) && swift(>=5.0)
        // This will only compile if APIClient is directly accessible
        if Network.APIClient.self != nil {
            results.append("✅ Network.APIClient type is directly accessible")
        }
        #else
        results.append("⚠️ Cannot test direct access to Network.APIClient")
        #endif
        #endif
    } catch {
        results.append("❌ Error accessing Network types: \(error.localizedDescription)")
    }
    #else
    results.append("❌ Network module cannot be imported")
    #endif
    
    // Print all available bundles
    results.append("Available bundles:")
    for bundle in Bundle.allBundles {
        results.append("- \(bundle.bundleIdentifier ?? "unknown") at \(bundle.bundlePath)")
    }
    
    // Print all available frameworks
    results.append("Available frameworks:")
    if let frameworksPath = Bundle.main.privateFrameworksPath {
        do {
            let frameworks = try FileManager.default.contentsOfDirectory(atPath: frameworksPath)
            for framework in frameworks {
                results.append("- \(framework)")
            }
        } catch {
            results.append("Error listing frameworks: \(error.localizedDescription)")
        }
    } else {
        results.append("No frameworks path available")
    }
    
    results.append("==============================")
    
    // Print all results
    for result in results {
        print(result)
    }
}

// Call the test function when the file is loaded
@_cdecl("runModuleTest")
public func runModuleTest() {
    testModuleAvailability()
}

// Automatically run the test
#if DEBUG
class ModuleTestRunner {
    static let shared = ModuleTestRunner()
    init() {
        DispatchQueue.main.async {
            testModuleAvailability()
        }
    }
}
private let runner = ModuleTestRunner.shared
#endif

struct ModuleTestView: View {
    @State private var testResult: String = "Press the button to test"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Module Test")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(testResult)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Button("Test Module") {
                testModule()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    private func testModule() {
        var results: [String] = []
        
        // Test if we can create the types directly
        do {
            #if !SWIFT_PACKAGE
            // Card type
            let card = Card(id: "test", last4: "1234", brand: Card.CardBrand.visa, expiryMonth: 12, expiryYear: 2025)
            results.append("✅ Card type is available directly")
            
            // APIClient type
            let apiClient = APIClient.shared
            results.append("✅ APIClient type is available directly")
            
            // Security namespace
            let tokenizationService = Security.LiveTokenizationService.shared
            results.append("✅ TokenizationService type is available directly")
            
            // PaymentResult type
            let paymentResult = PaymentResult(
                transactionId: "test",
                amount: 10.0,
                status: PaymentStatus.success
            )
            results.append("✅ PaymentResult type is available directly")
            
            // PricingTier type
            let pricingTier = PricingTier(
                id: "test",
                name: "Test Tier",
                price: 10.0,
                description: "Test description"
            )
            results.append("✅ PricingTier type is available directly")
            
            results.append("✅ All types are available directly!")
            #else
            // In Swift Package Manager mode, we'll just show a message
            results.append("⚠️ Running in Swift Package Manager mode")
            results.append("⚠️ Types test skipped in SPM build")
            #endif
        } catch {
            results.append("❌ Test failed: \(error.localizedDescription)")
        }
        
        testResult = results.joined(separator: "\n")
    }
}

#Preview {
    ModuleTestView()
} 