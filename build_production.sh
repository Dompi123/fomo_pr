#!/bin/bash

# Script to build FOMO_PR app in Release mode for production

echo "🚀 Building FOMO_PR app in Release mode for production..."

# Set environment variables for production
export ENABLE_PAYWALL=true
export ENABLE_DRINK_MENU=true
export ENABLE_CHECKOUT=true
export ENABLE_SEARCH=true
export ENABLE_PREMIUM_VENUES=true
export USE_MOCK_DATA=false
export PREVIEW_MODE=false

# Clean build directory
echo "🧹 Cleaning build directory..."
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Release

# Build for iOS device
echo "🔨 Building for iOS devices (Release mode)..."
xcodebuild build -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Release -sdk iphoneos

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Production build completed successfully!"
    echo "📱 The app is now ready for distribution."
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode and select the FOMO_PR project"
    echo "2. Select 'Archive' from the Product menu"
    echo "3. Follow the steps to distribute the app to TestFlight or App Store"
else
    echo "❌ Production build failed. Please check the error messages above."
fi 