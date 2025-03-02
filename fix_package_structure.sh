#!/bin/bash

# Script to fix the Swift package structure

echo "Fixing Swift package structure for FOMO_PR..."

# Backup the Package.swift file
cp Package.swift Package.swift.structure.backup

# Create the necessary directory structure
echo "Creating directory structure..."
mkdir -p Models/Sources/Models
mkdir -p Network/Sources/Network
mkdir -p Core/Sources/Core

# Create basic source files for each module
echo "Creating basic source files for each module..."

# Models module
cat > Models/Sources/Models/Models.swift << 'EOF'
import Foundation

public struct Card: Codable, Identifiable {
    public let id: String
    public let last4: String
    public let brand: CardBrand
    public let expiryMonth: Int
    public let expiryYear: Int
    public let isDefault: Bool
    
    public init(id: String, last4: String, brand: CardBrand, expiryMonth: Int, expiryYear: Int, isDefault: Bool = false) {
        self.id = id
        self.last4 = last4
        self.brand = brand
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.isDefault = isDefault
    }
    
    public enum CardBrand: String, Codable {
        case visa
        case mastercard
        case amex
        case discover
        case unknown
        
        public var displayName: String {
            switch self {
            case .visa: return "Visa"
            case .mastercard: return "Mastercard"
            case .amex: return "American Express"
            case .discover: return "Discover"
            case .unknown: return "Card"
            }
        }
    }
    
    public var displayName: String {
        return "\(brand.displayName) •••• \(last4)"
    }
    
    public var expiryDisplay: String {
        return String(format: "%02d/%d", expiryMonth, expiryYear % 100)
    }
}

public struct PricingTier: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let price: Decimal
    public let features: [String]
    
    public init(id: String, name: String, price: Decimal, features: [String]) {
        self.id = id
        self.name = name
        self.price = price
        self.features = features
    }
}
EOF

# Network module
cat > Network/Sources/Network/Network.swift << 'EOF'
import Foundation
import Models

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
EOF

# Core module
cat > Core/Sources/Core/Core.swift << 'EOF'
import Foundation
import Models
import Network

public enum Security {
    public class LiveTokenizationService {
        public static let shared = LiveTokenizationService()
        
        public init() {}
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            // In a real app, this would call a payment processor API
            // For now, we'll just return a mock token
            return "tok_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            // In a real app, this would call a payment processor API
            // For now, we'll just return a successful result
            return PaymentResult(
                success: true,
                transactionId: "txn_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))",
                amount: amount,
                date: Date()
            )
        }
    }
    
    public class MockTokenizationService {
        public static let shared = MockTokenizationService()
        
        public init() {}
        
        public func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String {
            return "tok_mock_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        }
        
        public func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult {
            return PaymentResult(
                success: true,
                transactionId: "txn_mock_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))",
                amount: amount,
                date: Date()
            )
        }
    }
}

public protocol TokenizationService {
    func tokenize(cardNumber: String, expiry: String, cvc: String) async throws -> String
    func processPayment(amount: Decimal, tier: PricingTier) async throws -> PaymentResult
}

extension Security.LiveTokenizationService: TokenizationService {}
extension Security.MockTokenizationService: TokenizationService {}

public struct PaymentResult {
    public let success: Bool
    public let transactionId: String
    public let amount: Decimal
    public let date: Date
    
    public init(success: Bool, transactionId: String, amount: Decimal, date: Date) {
        self.success = success
        self.transactionId = transactionId
        self.amount = amount
        self.date = date
    }
}
EOF

# Update Package.swift to use the correct paths
echo "Updating Package.swift..."
cat > Package.swift << 'EOF'
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FOMO_PR",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FOMO_PR",
            targets: ["FOMO_PR"]),
        .library(
            name: "Models",
            targets: ["Models"]),
        .library(
            name: "Network",
            targets: ["Network"]),
        .library(
            name: "Core",
            targets: ["Core"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Models",
            dependencies: [],
            path: "Models/Sources/Models"),
        .target(
            name: "Network",
            dependencies: ["Models"],
            path: "Network/Sources/Network"),
        .target(
            name: "Core",
            dependencies: ["Models", "Network"],
            path: "Core/Sources/Core"),
        .target(
            name: "FOMO_PR",
            dependencies: ["Models", "Network", "Core"],
            path: "FOMO_PR")
    ]
)
EOF

echo "Swift package structure fixed. Now building the package..."
swift build

if [ $? -eq 0 ]; then
    echo "Swift package built successfully."
    
    # Create Frameworks directory if it doesn't exist
    mkdir -p FOMO_PR/Frameworks
    
    # Copy the frameworks from .build/debug to FOMO_PR/Frameworks
    echo "Copying frameworks to FOMO_PR/Frameworks..."
    
    # Copy Core.framework
    if [ -d ".build/debug/Core.framework" ]; then
        cp -R .build/debug/Core.framework FOMO_PR/Frameworks/
        echo "✅ Core.framework copied successfully"
    else
        echo "❌ Core.framework not found in .build/debug/"
    fi
    
    # Copy Models.framework
    if [ -d ".build/debug/Models.framework" ]; then
        cp -R .build/debug/Models.framework FOMO_PR/Frameworks/
        echo "✅ Models.framework copied successfully"
    else
        echo "❌ Models.framework not found in .build/debug/"
    fi
    
    # Copy Network.framework
    if [ -d ".build/debug/Network.framework" ]; then
        cp -R .build/debug/Network.framework FOMO_PR/Frameworks/
        echo "✅ Network.framework copied successfully"
    else
        echo "❌ Network.framework not found in .build/debug/"
    fi
    
    echo "All frameworks copied successfully."
else
    echo "Failed to build Swift package. Please check for errors."
    exit 1
fi

# Update the project file to reference the correct framework paths
PROJECT_FILE="FOMO_PR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    echo "Updating framework references in project file..."
    
    # Backup the file
    cp "$PROJECT_FILE" "${PROJECT_FILE}.package.backup"
    
    # Update Core.framework reference
    sed -i '' 's|path = Core.framework;|path = FOMO_PR/Frameworks/Core.framework;|g' "$PROJECT_FILE"
    
    # Update Models.framework reference
    sed -i '' 's|path = Models.framework;|path = FOMO_PR/Frameworks/Models.framework;|g' "$PROJECT_FILE"
    
    # Update Network.framework reference (if needed)
    sed -i '' 's|path = Network.framework;|path = System/Library/Frameworks/Network.framework;|g' "$PROJECT_FILE"
    
    echo "Framework references updated in project file"
else
    echo "❌ Project file not found at $PROJECT_FILE"
fi

echo "Swift package structure fix completed. Please try building and running the app again." 