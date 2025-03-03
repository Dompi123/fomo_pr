import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fomo", category: "PaymentState")

// Add String extension for localization
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

public enum PaymentState: Equatable {
    case ready
    case processing
    case completed
    case failed(String)
    
    public var buttonTitle: String {
        // Debug logging to trace localization issues
        logger.debug("Attempting to localize button title for state: \(String(describing: self))")
        
        let key: String
        switch self {
        case .ready:
            key = "payment.button.ready"
        case .processing:
            key = "payment.button.processing"
        case .completed:
            key = "payment.button.completed"
        case .failed:
            key = "payment.button.retry"
        }
        
        // Log the localization key being used
        logger.debug("Using localization key: \(key)")
        
        // Temporary fallback while we debug
        #if DEBUG
        return NSLocalizedString(key, comment: "Payment button title")
        #else
        return key.localized
        #endif
    }
    
    public var isEnabled: Bool {
        switch self {
        case .ready, .failed:
            return true
        case .processing, .completed:
            return false
        }
    }
    
    public static func == (lhs: PaymentState, rhs: PaymentState) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready),
             (.processing, .processing),
             (.completed, .completed):
            return true
        case let (.failed(error1), .failed(error2)):
            return error1 == error2
        default:
            return false
        }
    }
} 