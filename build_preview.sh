#!/bin/bash

# Enable all core preview features
export ENABLE_PAYWALL=1
export ENABLE_DRINK_MENU=1
export ENABLE_CHECKOUT=1
export ENABLE_SEARCH=1
export ENABLE_PREMIUM_VENUES=1
export ENABLE_MOCK_DATA=1
export PREVIEW_MODE=1

# Print setup
echo "🚀 Setting up FOMO_PR Preview Environment"
echo "----------------------------------------"
echo "🔑 Environment Configuration:"
echo "  ✓ Paywall enabled: $ENABLE_PAYWALL"
echo "  ✓ Drink Menu enabled: $ENABLE_DRINK_MENU" 
echo "  ✓ Checkout enabled: $ENABLE_CHECKOUT"
echo "  ✓ Search enabled: $ENABLE_SEARCH"
echo "  ✓ Premium Venues enabled: $ENABLE_PREMIUM_VENUES"
echo "  ✓ Mock Data enabled: $ENABLE_MOCK_DATA"
echo "  ✓ Preview Mode enabled: $PREVIEW_MODE"
echo "----------------------------------------"

# Define simulator
SIMULATOR_NAME="iPhone 16"
SIMULATOR_ID="CC00CCA5-1AD0-44BE-9820-D0F2DC2B93D5"

# Clean build directory
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR -destination "platform=iOS Simulator,name=$SIMULATOR_NAME"

# Create a temporary directory to hold modified source files
TEMP_DIR="temp_build_files"
mkdir -p $TEMP_DIR

# Copy CoreModels.swift to the temporary directory
cp FOMO_PR/Models/CoreModels.swift $TEMP_DIR/

# Copy SecurityTypes.swift to the temporary directory
cp FOMO_PR/Models/SecurityTypes.swift $TEMP_DIR/

# Copy FOMOImports.swift to the temporary directory
cp FOMOImports.swift $TEMP_DIR/

# Create a simplified SecurityTypes.swift file if it doesn't exist
if [ ! -f "FOMO_PR/Models/SecurityTypes.swift" ]; then
  echo "Creating SecurityTypes.swift file..."
  mkdir -p FOMO_PR/Models
  cat > FOMO_PR/Models/SecurityTypes.swift << 'EOF'
import Foundation
import SwiftUI

// MARK: - Card Model
public struct Card: Identifiable, Hashable, Codable {
    public let id: String
    public let lastFour: String
    public let expiryMonth: Int
    public let expiryYear: Int
    public let cardholderName: String
    public let brand: String
    
    public init(
        id: String = UUID().uuidString,
        lastFour: String,
        expiryMonth: Int,
        expiryYear: Int,
        cardholderName: String,
        brand: String
    ) {
        self.id = id
        self.lastFour = lastFour
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cardholderName = cardholderName
        self.brand = brand
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Payment Status
public enum PaymentStatus: String, Codable {
    case pending
    case processing
    case success
    case failed
    case refunded
    case cancelled
}

// MARK: - Payment Result
public struct PaymentResult: Identifiable, Codable {
    public let id: String
    public let transactionId: String
    public let amount: Decimal
    public let status: PaymentStatus
    public let timestamp: Date
    public let errorMessage: String?
    
    public init(
        id: String = UUID().uuidString,
        transactionId: String,
        amount: Decimal,
        status: PaymentStatus,
        timestamp: Date = Date(),
        errorMessage: String? = nil
    ) {
        self.id = id
        self.transactionId = transactionId
        self.amount = amount
        self.status = status
        self.timestamp = timestamp
        self.errorMessage = errorMessage
    }
}

// MARK: - Security Namespace
public enum FOMOSecurity {
    // Tokenization Service
    public class LiveTokenizationService {
        public static let shared = LiveTokenizationService()
        
        public init() {}
        
        public func tokenize(card: Card) -> String {
            // In a real implementation, this would call a payment processor API
            // For preview/mock purposes, we just return a fake token
            return "tok_\(card.brand.lowercased())_\(card.lastFour)"
        }
    }
}

// MARK: - API Client
public class APIClient {
    public static let shared = APIClient()
    
    private init() {}
    
    public func request<T: Decodable>(endpoint: String, method: String = "GET", body: Encodable? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        // Mock implementation for preview mode
        // In a real implementation, this would make actual network requests
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(EmptyResponse() as! T))
        }
    }
    
    // Empty response for when we don't care about the response body
    private struct EmptyResponse: Decodable {}
}

// Verify that security types are available
func verifySecurityTypes() {
    #if PREVIEW_MODE
    print("FOMOSecurity namespace is available in preview mode")
    print("LiveTokenizationService is available: \(FOMOSecurity.LiveTokenizationService.shared)")
    print("Card is available: \(Card(lastFour: "1234", expiryMonth: 12, expiryYear: 2025, cardholderName: "Test User", brand: "visa"))")
    print("PaymentResult is available: \(PaymentResult(transactionId: "test", amount: 10.0, status: .success))")
    print("APIClient is available: \(APIClient.shared)")
    #else
    print("Using production Security module")
    #endif
}
EOF
fi

# Run the build with all feature flags
xcodebuild build \
  -project FOMO_PR.xcodeproj \
  -scheme FOMO_PR \
  -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
  -configuration Debug \
  EXCLUDED_SOURCE_FILE_NAMES="PaymentManager.swift" \
  OTHER_SWIFT_FLAGS="-DPREVIEW_MODE -DENABLE_MOCK_DATA -DENABLE_PAYWALL -DENABLE_DRINK_MENU -DENABLE_CHECKOUT -DENABLE_SEARCH -DENABLE_PREMIUM_VENUES" \
  | tee build_log_preview.txt

# Check if the build was successful
if [ $? -eq 0 ]; then
  echo "✅ Build successful!"
  
  # Start the simulator
  echo "Starting simulator..."
  xcrun simctl boot "$SIMULATOR_NAME" || true
  
  # Install the app on the simulator
  echo "Installing app on simulator..."
  xcrun simctl install "$SIMULATOR_NAME" "$(xcodebuild -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Debug -showBuildSettings | grep -m 1 "BUILT_PRODUCTS_DIR" | grep -oEi "\/.*")/FOMO_PR.app"
  
  # Launch the app
  echo "Launching app..."
  xcrun simctl launch "$SIMULATOR_NAME" "com.fomoapp.fomopr"
  
  echo "✅ App is now available on the simulator with all preview features enabled!"
else
  echo "❌ Build failed!"
  
  # Check for common errors
  if grep -q "cannot find type 'Venue'" build_log_preview.txt; then
    echo "Error: Cannot find type 'Venue'. Make sure CoreModels.swift is properly included."
  fi
  
  if grep -q "cannot find type 'DrinkItem'" build_log_preview.txt; then
    echo "Error: Cannot find type 'DrinkItem'. Make sure CoreModels.swift is properly included."
  fi
  
  if grep -q "cannot find type 'PreviewNavigationCoordinator'" build_log_preview.txt; then
    echo "Error: Cannot find type 'PreviewNavigationCoordinator'. Make sure FOMOImports.swift is properly included."
  fi
  
  if grep -q "cannot find type 'Card'" build_log_preview.txt; then
    echo "Error: Cannot find type 'Card'. Make sure SecurityTypes.swift is properly included."
  fi
fi

# Clean up temporary files
echo "Cleaning up temporary files..."
# Uncomment the line below to remove temporary files after build
# rm -rf $TEMP_DIR