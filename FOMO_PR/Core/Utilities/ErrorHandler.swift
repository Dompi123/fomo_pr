import Foundation
import SwiftUI
import OSLog

// Define NetworkError here since Models module doesn't exist
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case invalidResponse
    case decodingFailed
    case serverError(Int)
    case noConnection
    case timeout
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed:
            return "Request failed"
        case .invalidResponse:
            return "Invalid response"
        case .decodingFailed:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        }
    }
}

enum AppError: LocalizedError {
    case network(NetworkError)
    case validation(String)
    case authentication
    case authorization
    case notFound
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .network(let networkError):
            return networkError.localizedDescription
        case .validation(let message):
            return message
        case .authentication:
            return "Authentication required"
        case .authorization:
            return "Not authorized"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        case .unknown:
            return "Unknown error"
        }
    }
}

final class ErrorHandler {
    static func handle(_ error: Error) {
        let appError: AppError
        
        if let networkError = error as? NetworkError {
            appError = .network(networkError)
        } else {
            appError = error as? AppError ?? .unknown
        }
        
        #if DEBUG
        print("🚨 Error: \(appError.localizedDescription)")
        if case .network(let networkError) = appError {
            print("Network Error Details: \(networkError)")
        }
        #endif
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .errorOccurred,
                object: nil,
                userInfo: ["error": appError]
            )
        }
    }
}

extension Notification.Name {
    static let errorOccurred = Notification.Name("FOMOErrorOccurred")
}

struct ErrorAlert: ViewModifier {
    @State private var showingError = false
    @State private var error: AppError?
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .errorOccurred)) { notification in
                if let error = notification.userInfo?["error"] as? AppError {
                    self.error = error
                    self.showingError = true
                }
            }
            .alert("Error", isPresented: $showingError, presenting: error) { _ in
                Button("OK") {
                    showingError = false
                }
            } message: { error in
                Text(error.localizedDescription)
            }
    }
}

extension View {
    func handleErrors() -> some View {
        modifier(ErrorAlert())
    }
} 
