import Foundation
import Combine

public class APIClient {
    public static let shared = APIClient()
    
    private let baseURL = "https://api.fomopr.com"
    
    private init() {}
    
    public func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func post<T: Decodable, U: Encodable>(_ endpoint: String, body: U) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
