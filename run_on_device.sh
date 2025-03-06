#!/bin/bash

# Script to build and run FOMO_PR app on a connected iOS device

echo "📱 Building and running FOMO_PR app on a connected iOS device..."

# Set environment variables for development
export ENABLE_PAYWALL=true
export ENABLE_DRINK_MENU=true
export ENABLE_CHECKOUT=true
export ENABLE_SEARCH=true
export ENABLE_PREMIUM_VENUES=true
export USE_MOCK_DATA=true
export PREVIEW_MODE=false

# Check if a device is connected
DEVICE_ID=$(xcrun xctrace list devices 2>&1 | grep -v "Simulator" | grep -v "^==" | grep -v "^--" | grep -v "Devices" | grep -v "^$" | head -1 | awk '{print $NF}' | tr -d '()')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ No iOS device connected. Please connect an iOS device and try again."
    exit 1
fi

DEVICE_NAME=$(xcrun xctrace list devices 2>&1 | grep -v "Simulator" | grep -v "^==" | grep -v "^--" | grep -v "Devices" | grep -v "^$" | head -1 | awk -F'[()]' '{print $1}' | xargs)

echo "🔍 Found device: $DEVICE_NAME ($DEVICE_ID)"

# Clean build directory
echo "🧹 Cleaning build directory..."
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR -destination "id=$DEVICE_ID"

# Build and run on device
echo "🔨 Building and running on device..."
xcodebuild build -project FOMO_PR.xcodeproj -scheme FOMO_PR -destination "id=$DEVICE_ID" -allowProvisioningUpdates

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful! Installing on device..."
    
    # Install and run on device
    xcrun simctl install "$DEVICE_ID" "$(find ~/Library/Developer/Xcode/DerivedData -name "FOMO_PR.app" -type d | grep -v "SourcePackages" | head -1)"
    
    if [ $? -eq 0 ]; then
        echo "📲 App installed successfully on $DEVICE_NAME!"
        echo "🚀 Launching app..."
        xcrun simctl launch "$DEVICE_ID" "com.fomoapp.fomopr"
    else
        echo "❌ Failed to install app on device. Please check the error messages above."
    fi
else
    echo "❌ Build failed. Please check the error messages above."
fi 