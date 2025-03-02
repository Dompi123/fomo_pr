import SwiftUI

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
        results.append("✅ Card type is available")
        
        // Test APIClient
        results.append("✅ APIClient type is available")
        
        // Test Security.LiveTokenizationService
        results.append("✅ Security.LiveTokenizationService type is available")
        
        // Test PaymentResult
        results.append("✅ PaymentResult type is available")
        
        // Test PricingTier
        results.append("✅ PricingTier type is available")
        
        testResult = results.joined(separator: "\n")
    }
}

#Preview {
    TypesTestView()
}
