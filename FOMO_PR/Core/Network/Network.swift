import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol EndpointProtocol {
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Encodable? { get }
    func urlRequest(baseURL: URL) throws -> URLRequest
}

public struct APIEndpoint: EndpointProtocol {
    public let path: String
    public let method: HTTPMethod
    public let body: Encodable?
    public static let baseURL = URL(string: "https://api.fomopr.com")!
    
    public init(path: String, method: HTTPMethod, body: Encodable? = nil) {
        self.path = path
        self.method = method
        self.body = body
    }
    
    public func urlRequest(baseURL: URL) throws -> URLRequest {
        let components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)!
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}

public struct APIError: Codable {
    public let code: String
    public let message: String
    
    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

public struct APIMeta: Codable {
    public let timestamp: Date
    public let requestId: String
    
    public init(timestamp: Date, requestId: String) {
        self.timestamp = timestamp
        self.requestId = requestId
    }
}

public struct APIResponse<T: Codable>: Codable {
    public let data: T
    public let meta: APIMeta
    public let errors: [APIError]?
    
    public init(data: T, meta: APIMeta, errors: [APIError]? = nil) {
        self.data = data
        self.meta = meta
        self.errors = errors
    }
}

public struct EmptyResponse: Codable {}

@globalActor public actor APIClientActor {
    public static let shared = APIClientActor()
}

@APIClientActor
public class APIClient {
    public static let shared = APIClient()
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var authToken: String?
    
    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.encoder = JSONEncoder()
    }
    
    public func setAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    public func request<T: Decodable>(_ endpoint: EndpointProtocol) async throws -> T {
        var request = try endpoint.urlRequest(baseURL: APIEndpoint.baseURL)
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.wrapped(error)
            }
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 429:
            if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init) {
                throw NetworkError.rateLimitExceeded(retryAfter: retryAfter)
            }
            throw NetworkError.rateLimitExceeded(retryAfter: 60)
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.invalidResponse
        }
    }
} 