#!/bin/bash
set -e

# Define paths
APP_PATH="/Users/dom.khr/Library/Developer/Xcode/DerivedData/FOMO_PR-cuzpopjqrlgvlgfwfvbubforhssv/Build/Intermediates.noindex/ArchiveIntermediates/FOMO_PR/InstallationBuildProductsLocation/Applications/FOMO_PR.app"
DEVICE_ID="00008140-001A08691AD0801C"
TEMP_DIR="/tmp/no_frameworks_app"
FIXED_APP="$TEMP_DIR/FOMO_PR.app"

echo "Starting installation without frameworks..."

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH"
    exit 1
fi

echo "App found at: $APP_PATH"

# Create a temporary directory for the fixed app
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cp -R "$APP_PATH" "$FIXED_APP"

echo "Created temporary copy at: $FIXED_APP"

# Remove frameworks directory
if [ -d "$FIXED_APP/Frameworks" ]; then
    echo "Removing Frameworks directory..."
    rm -rf "$FIXED_APP/Frameworks"
fi

# Re-sign the app
echo "Re-signing main app..."
codesign -f -s "Apple Development" "$FIXED_APP"

# Verify code signature
echo "Verifying code signature..."
codesign -v "$FIXED_APP" || echo "App signature verification failed, but continuing..."

# Install app on device with no-wifi flag
echo "Installing app on device with no-wifi flag..."
xcrun ios-deploy --id "$DEVICE_ID" --bundle "$FIXED_APP" --no-wifi --debug --verbose

echo "Installation process completed." 