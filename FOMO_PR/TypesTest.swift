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

struct TypesTestView: View {
    @State private var testResult: String = "Press the button to test types"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Types Test")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(testResult)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Button("Test Types") {
                testTypes()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    private func testTypes() {
        var results: [String] = []
        
        // Test Card type
        do {
            #if !SWIFT_PACKAGE
            let card = Card(id: "test", last4: "1234", brand: Card.CardBrand.visa, expiryMonth: 12, expiryYear: 2025)
            results.append("✅ Card type is available: \(card.displayName)")
            #else
            results.append("⚠️ Card type test skipped in SPM build")
            #endif
        } catch {
            results.append("❌ Card type test failed: \(error.localizedDescription)")
        }
        
        // Test APIClient type
        do {
            #if !SWIFT_PACKAGE
            let apiClient = APIClient.shared
            results.append("✅ APIClient type is available")
            #else
            results.append("⚠️ APIClient type test skipped in SPM build")
            #endif
        } catch {
            results.append("❌ APIClient type test failed: \(error.localizedDescription)")
        }
        
        // Test Security namespace
        do {
            #if !SWIFT_PACKAGE
            let tokenizationService = Security.LiveTokenizationService.shared
            results.append("✅ TokenizationService type is available")
            #else
            results.append("⚠️ TokenizationService type test skipped in SPM build")
            #endif
        } catch {
            results.append("❌ TokenizationService type test failed: \(error.localizedDescription)")
        }
        
        // Test PaymentResult type
        do {
            #if !SWIFT_PACKAGE
            let paymentResult = PaymentResult(
                transactionId: "test",
                amount: 10.0,
                status: PaymentStatus.success
            )
            results.append("✅ PaymentResult type is available")
            #else
            results.append("⚠️ PaymentResult type test skipped in SPM build")
            #endif
        } catch {
            results.append("❌ PaymentResult type test failed: \(error.localizedDescription)")
        }
        
        // Test PricingTier type
        do {
            #if !SWIFT_PACKAGE
            let pricingTier = PricingTier(
                id: "test",
                name: "Test Tier",
                price: 10.0,
                description: "Test description"
            )
            results.append("✅ PricingTier type is available")
            #else
            results.append("⚠️ PricingTier type test skipped in SPM build")
            #endif
        } catch {
            results.append("❌ PricingTier type test failed: \(error.localizedDescription)")
        }
        
        testResult = results.joined(separator: "\n")
    }
}

#Preview {
    TypesTestView()
} 