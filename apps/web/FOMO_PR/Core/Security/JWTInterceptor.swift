import Foundation
import Core

class JWTInterceptor {
    func intercept(_ request: URLRequest) -> URLRequest {
        var request = request
        
        if let token = try? KeychainManager.shared.get(.apiToken) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    static func handleAuthError(_ error: Error) -> Bool {
        // Return true if error was handled (e.g., refreshed token)
        guard let networkError = error as? NetworkError,
              case .serverError(let statusCode) = networkError,
              statusCode == 401 else {
            return false
        }
        
        // Trigger auth refresh flow
        Task {
            await AuthManager.shared.refreshToken()
        }
        
        return true
    }
} 