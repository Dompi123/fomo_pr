import Foundation
import Security
import OSLog
import Core

enum APIConstants {
    private static let logger = Logger(subsystem: "com.fomo", category: "APIConstants")
    
    static var baseURL: URL {
        get throws {
            guard let urlString = try? KeychainManager.shared.get(.baseURL),
                  let url = URL(string: urlString) else {
                throw NetworkError.invalidURL
            }
            return url
        }
    }
    
    static var apiKey: String {
        get throws {
            guard let key = try? KeychainManager.shared.get(.apiKey) else {
                throw NetworkError.unauthorized
            }
            return key
        }
    }
    
    static var environment: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}

extension APIConstants {
    enum Environment {
        case development
        case staging
        case production
        
        var baseURLString: String {
            switch self {
            case .development:
                return "https://api.dev.fomo.com/v1"
            case .staging:
                return "https://api.staging.fomo.com/v1"
            case .production:
                return "https://api.fomo.com/v1"
            }
        }
    }
} 