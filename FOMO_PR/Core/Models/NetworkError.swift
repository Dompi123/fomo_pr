import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fomo", category: "Models.NetworkError")

// MARK: - API Error Type
public struct APIError: Codable {
    public let code: String
    public let type: String
    public let message: String?
    public let param: String?
    
    public init(code: String, type: String, message: String? = nil, param: String? = nil) {
        self.code = code
        self.type = type
        self.message = message
        self.param = param
    }
}

// MARK: - Network Error Types
public enum NetworkError: LocalizedError {
    private static let _setup: Void = {
        logger.debug("NetworkError.swift loading in Models module")
        logger.debug("Module name: \(String(reflecting: NetworkError.self))")
    }()
    
    case invalidURL
    case invalidResponse
    case rateLimitExceeded(retryAfter: TimeInterval)
    case tokenExpired
    case paymentError(code: String)
    case unhandledError(code: String)
    case wrapped(Error)
    case insecureConnection
    case unknown
    case serverError(statusCode: Int)
    case httpError(statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimitExceeded(let retryAfter):
            return "Rate limit exceeded. Please try again in \(Int(retryAfter)) seconds"
        case .tokenExpired:
            return "Session expired. Please log in again"
        case .paymentError(let code):
            return "Payment failed: \(code)"
        case .unhandledError(let code):
            return "An error occurred: \(code)"
        case .wrapped(let error):
            return error.localizedDescription
        case .insecureConnection:
            return "Insecure connection detected"
        case .unknown:
            return "An unknown error occurred"
        case .serverError(let statusCode), .httpError(let statusCode):
            return "Server error: \(statusCode)"
        }
    }
}

// MARK: - Error Mapping
extension NetworkError {
    public init(apiError: APIError) {
        switch apiError.code {
        case "rate_limit_exceeded":
            self = .rateLimitExceeded(retryAfter: 60)
        case "invalid_token":
            self = .tokenExpired
        case "payment_failed":
            logger.error("Payment error: \(apiError.type)")
            self = .paymentError(code: apiError.type)
        default:
            self = .unhandledError(code: apiError.code)
        }
    }
} 