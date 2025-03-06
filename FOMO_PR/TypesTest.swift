import SwiftUI
import FOMO_PR

// This is a simple view that can be used to verify that all the types are available
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
        
        #if PREVIEW_MODE
        // Test Card
        let card = Card(id: "card-123", lastFour: "1234", expiryMonth: 12, expiryYear: 2025, cardholderName: "Test User", brand: "visa")
        results.append("✅ Card type is available: \(card.lastFour)")
        
        // Test APIClient
        #if !SWIFT_PACKAGE && !XCODE_HELPER
        let apiClient = APIClient.shared
        results.append("✅ APIClient type is available")
        #else
        results.append("⚠️ APIClient type is not available in this build configuration")
        #endif
        
        // Test Security.LiveTokenizationService
        let tokenizationService = FOMOSecurity.LiveTokenizationService.shared
        results.append("✅ Security.LiveTokenizationService type is available")
        
        // Test PaymentResult
        let paymentResult = PaymentResult(id: "payment-123", status: .completed, amount: 10.0, description: "Test payment")
        results.append("✅ PaymentResult type is available: \(paymentResult.id)")
        
        // Test PricingTier
        let pricingTier = PricingTier(id: "test", name: "Test Tier", price: 10.0, description: "Test description")
        results.append("✅ PricingTier type is available: \(pricingTier.name)")
        
        // Test Venue
        let venue = Venue.mockVenues.first!
        results.append("✅ Venue type is available: \(venue.name)")
        
        // Test DrinkItem
        let drinkItem = DrinkItem.mockDrinks.first!
        results.append("✅ DrinkItem type is available: \(drinkItem.name)")
        
        // Test User - Fix reference to User type
        do {
            let userData = """
            {
                "id": "user-123",
                "firstName": "John",
                "lastName": "Doe",
                "email": "john@example.com"
            }
            """.data(using: .utf8)!
            
            let user = try JSONDecoder().decode(User.self, from: userData)
            results.append("✅ User type is available: \(user.firstName)")
        } catch {
            results.append("❌ User type is NOT available: \(error.localizedDescription)")
        }
        
        // Test PreviewNavigationCoordinator
        let coordinator = PreviewNavigationCoordinator.shared
        results.append("✅ PreviewNavigationCoordinator type is available")
        
        // Test MockDataProvider
        let dataProvider = MockDataProvider.shared
        results.append("✅ MockDataProvider type is available")
        #else
        results.append("⚠️ Running in non-preview mode. Types may not be available.")
        #endif
        
        testResult = results.joined(separator: "\n")
    }
}

#Preview {
    TypesTestView()
}
