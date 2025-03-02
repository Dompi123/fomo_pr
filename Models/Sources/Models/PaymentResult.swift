import Foundation

// Define a unified PaymentResult type in the Models module
public struct PaymentResult: Equatable, Codable {
    public let id: String
    public let transactionId: String
    public let amount: Decimal
    public let timestamp: Date
    public let status: PaymentStatus
    
    public init(id: String = UUID().uuidString,
                transactionId: String,
                amount: Decimal,
                timestamp: Date = Date(),
                status: PaymentStatus) {
        self.id = id
        self.transactionId = transactionId
        self.amount = amount
        self.timestamp = timestamp
        self.status = status
    }
    
    public static func == (lhs: PaymentResult, rhs: PaymentResult) -> Bool {
        lhs.id == rhs.id
    }
}

public enum PaymentStatus: Equatable, Codable {
    case success
    case failure(String)
    case pending
    
    // Custom coding keys for encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case status
        case errorMessage
    }
    
    // Custom encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .success:
            try container.encode("success", forKey: .status)
        case .failure(let message):
            try container.encode("failure", forKey: .status)
            try container.encode(message, forKey: .errorMessage)
        case .pending:
            try container.encode("pending", forKey: .status)
        }
    }
    
    // Custom decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(String.self, forKey: .status)
        
        switch status {
        case "success":
            self = .success
        case "failure":
            let message = try container.decodeIfPresent(String.self, forKey: .errorMessage) ?? "Unknown error"
            self = .failure(message)
        case "pending":
            self = .pending
        default:
            self = .failure("Unknown status: \(status)")
        }
    }
    
    public static func == (lhs: PaymentStatus, rhs: PaymentStatus) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success),
             (.pending, .pending):
            return true
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

// Log function to help with debugging
public func logPaymentResultAvailability() {
    print("PaymentResult type is available in Models module: \(PaymentResult.self)")
    print("PaymentStatus type is available in Models module: \(PaymentStatus.self)")
} 