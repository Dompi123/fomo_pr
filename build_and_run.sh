#!/bin/bash

# Script to build and run FOMO_PR with all features enabled

# Set environment variables
export ENABLE_PAYWALL=1
export ENABLE_DRINK_MENU=1
export ENABLE_CHECKOUT=1
export ENABLE_SEARCH=1
export ENABLE_PREMIUM_VENUES=1
export ENABLE_MOCK_DATA=1
export PREVIEW_MODE=1

# Print setup information
echo "🚀 Setting up FOMO_PR Preview Environment"
echo "----------------------------------------"
echo "🔑 Environment Configuration:"
echo "  ✓ Paywall enabled"
echo "  ✓ Drink Menu enabled"
echo "  ✓ Checkout enabled"
echo "  ✓ Search enabled" 
echo "  ✓ Premium Venues enabled"
echo "  ✓ Mock Data enabled"
echo "  ✓ Preview Mode enabled"
echo "----------------------------------------"

# Define Journey iPhone simulator
SIMULATOR_NAME="iPhone 16"
SIMULATOR_ID="CC00CCA5-1AD0-44BE-9820-D0F2DC2B93D5"

# Clean the build directory
echo "🧹 Cleaning build directory..."
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR

# Build the app for the simulator
echo "🔨 Building FOMO_PR with all features enabled..."
xcodebuild build -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Debug -sdk iphonesimulator -destination "platform=iOS Simulator,id=$SIMULATOR_ID"

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful. Preparing to launch on Journey iPhone simulator..."
    
    # Make sure the simulator is booted
    echo "🚀 Ensuring simulator is running..."
    xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
    
    # Install the app
    echo "📲 Installing app on simulator..."
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FOMO_PR.app" -type d | grep -v "SourcePackages" | head -n 1)
    echo "   App path: $APP_PATH"
    xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
    
    # Launch the app
    echo "🎮 Launching app..."
    xcrun simctl launch "$SIMULATOR_ID" com.fomoapp.fomopr
    
    echo "✨ App launched in Journey iPhone simulator with all features enabled."
    echo "   ✓ You can now see all UI elements with mock data"
    echo "   ✓ Paywall, Drink Menu, and Checkout will display complete interfaces"
    echo "   ✓ All navigation should work properly"
else
    echo "❌ Build failed. Please check the error messages above."
    exit 1
fi 