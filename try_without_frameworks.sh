#!/bin/bash

set -e  # Exit on any error

echo "===== STARTING INSTALLATION WITHOUT FRAMEWORKS ====="

# Define paths
APP_PATH="/Users/dom.khr/Library/Developer/Xcode/DerivedData/FOMO_PR-cuzpopjqrlgvlgfwfvbubforhssv/Build/Products/Debug-iphoneos/FOMO_PR.app"
DEVICE_ID="00008140-001A08691AD0801C"
TEMP_APP_PATH="/tmp/FOMO_PR_no_frameworks.app"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH"
    exit 1
fi

echo "App found at: $APP_PATH"

# Create a temporary copy of the app without frameworks
echo "Creating a temporary copy of the app without frameworks..."
rm -rf "$TEMP_APP_PATH"
cp -R "$APP_PATH" "$TEMP_APP_PATH"

# Remove the Frameworks directory
echo "Removing Frameworks directory..."
rm -rf "$TEMP_APP_PATH/Frameworks"

# Re-sign the app
echo "Re-signing the app..."
codesign --force --sign "Apple Development" "$TEMP_APP_PATH"

echo "Verification of code signature..."
codesign -vv "$TEMP_APP_PATH"

# Install app on device with verbose output
echo "Installing app on device..."
xcrun ios-deploy --id "$DEVICE_ID" --bundle "$TEMP_APP_PATH" --no-wifi --debug --verbose

echo "===== INSTALLATION WITHOUT FRAMEWORKS COMPLETED =====" 