#!/bin/bash

echo "=== Building and Running FOMO_PR ==="

# Get available simulators
echo "Finding available simulators..."
SIMULATORS=$(xcrun simctl list devices available -j | grep -o '"name" : "[^"]*"' | cut -d '"' -f 4)

if [ -z "$SIMULATORS" ]; then
    echo "❌ No available simulators found"
    echo "Please create a simulator in Xcode and try again"
    exit 1
fi

# Use the first available simulator
SIMULATOR=$(echo "$SIMULATORS" | head -n 1)
echo "Using simulator: $SIMULATOR"

# Clean the build directory
echo "Cleaning build directory..."
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR

# Build the app
echo "Building app..."
xcodebuild build -project FOMO_PR.xcodeproj -scheme FOMO_PR -destination "platform=iOS Simulator,name=$SIMULATOR" -configuration Debug

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"

# Get the app bundle ID
BUNDLE_ID=$(defaults read $(pwd)/FOMO_PR/Info.plist CFBundleIdentifier)
if [ -z "$BUNDLE_ID" ]; then
    # Try to extract it from the Info.plist file
    BUNDLE_ID=$(grep -A1 "CFBundleIdentifier" FOMO_PR/Info.plist | grep string | sed -E 's/.*<string>(.*)<\/string>.*/\1/')
fi

if [ -z "$BUNDLE_ID" ]; then
    echo "❌ Could not determine bundle ID"
    echo "Using default bundle ID: com.fomopr.app"
    BUNDLE_ID="com.fomopr.app"
fi

echo "Bundle ID: $BUNDLE_ID"

# Launch the app
echo "Launching app on simulator..."
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
xcrun simctl launch "$SIMULATOR" "$BUNDLE_ID"

echo "=== App Launched ==="
echo "Check the simulator to see if the app is running correctly" 