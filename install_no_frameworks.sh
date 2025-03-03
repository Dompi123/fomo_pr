#!/bin/bash

# Set variables
DEVICE_ID="00008140-001A08691AD0801C"
APP_PATH="/Users/dom.khr/Library/Developer/Xcode/DerivedData/FOMO_PR-cuzpopjqrlgvlgfwfvbubforhssv/Build/Products/Debug-iphoneos/FOMO_PR.app"
TEMP_DIR="/tmp/fomo_pr_app_$(date +%s)"

echo "Creating temporary app copy without frameworks..."
mkdir -p "$TEMP_DIR"
cp -R "$APP_PATH" "$TEMP_DIR/"
TEMP_APP="$TEMP_DIR/$(basename "$APP_PATH")"

# Remove the Frameworks directory
echo "Removing Frameworks directory..."
rm -rf "$TEMP_APP/Frameworks"

# Install the app without frameworks
echo "Installing app without frameworks..."
xcrun ios-deploy --id "$DEVICE_ID" --bundle "$TEMP_APP" --no-wifi

echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Done!" 