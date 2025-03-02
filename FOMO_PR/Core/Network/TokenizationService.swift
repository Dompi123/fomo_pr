import Foundation

public protocol TokenizationService {
    func tokenize(cardNumber: String, expiryMonth: Int, expiryYear: Int, cvv: String) async throws -> String
}

public class MockTokenizationService: TokenizationService {
    public static let shared = MockTokenizationService()
    
    public func tokenize(cardNumber: String, expiryMonth: Int, expiryYear: Int, cvv: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "mock_token_\(UUID().uuidString)"
    }
} 