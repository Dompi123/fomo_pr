import Foundation
// import Models // Commenting out Models import to use local implementations instead

public enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

public protocol APIClient {
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T
    func post<T: Decodable, U: Encodable>(_ endpoint: String, body: U) async throws -> T
}

public class LiveAPIClient: APIClient {
    public static let shared = LiveAPIClient()
    
    private let baseURL = "https://api.example.com"
    
    public init() {}
    
    public func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    public func post<T: Decodable, U: Encodable>(_ endpoint: String, body: U) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
