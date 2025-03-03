#!/bin/bash

set -e  # Exit on any error

echo "===== STARTING FIX AND INSTALL PROCESS ====="

# Define paths
APP_PATH="/Users/dom.khr/Library/Developer/Xcode/DerivedData/FOMO_PR-cuzpopjqrlgvlgfwfvbubforhssv/Build/Products/Debug-iphoneos/FOMO_PR.app"
DEVICE_ID="00008140-001A08691AD0801C"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH"
    exit 1
fi

echo "App found at: $APP_PATH"

# Check frameworks directory
FRAMEWORKS_DIR="$APP_PATH/Frameworks"
if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo "Error: Frameworks directory not found at $FRAMEWORKS_DIR"
    exit 1
fi

echo "Frameworks directory found at: $FRAMEWORKS_DIR"

# Check for Models framework
MODELS_FRAMEWORK="$FRAMEWORKS_DIR/Models.framework"
if [ ! -d "$MODELS_FRAMEWORK" ]; then
    echo "Error: Models framework not found at $MODELS_FRAMEWORK"
    exit 1
fi

echo "Models framework found at: $MODELS_FRAMEWORK"

# Check for Core framework
CORE_FRAMEWORK="$FRAMEWORKS_DIR/Core.framework"
if [ ! -d "$CORE_FRAMEWORK" ]; then
    echo "Error: Core framework not found at $CORE_FRAMEWORK"
    exit 1
fi

echo "Core framework found at: $CORE_FRAMEWORK"

# Fix Models framework Info.plist
echo "Fixing Models framework Info.plist..."
plutil -insert CFBundleIdentifier -string "com.fomoapp.fomopr.Models" "$MODELS_FRAMEWORK/Info.plist" 2>/dev/null || echo "CFBundleIdentifier already exists in Models.framework"

# Fix Core framework Info.plist
echo "Fixing Core framework Info.plist..."
plutil -insert CFBundleIdentifier -string "com.fomoapp.fomopr.Core" "$CORE_FRAMEWORK/Info.plist" 2>/dev/null || echo "CFBundleIdentifier already exists in Core.framework"

# Verify Info.plist changes
echo "Verifying Info.plist changes..."
MODELS_BUNDLE_ID=$(plutil -p "$MODELS_FRAMEWORK/Info.plist" | grep CFBundleIdentifier | awk -F'"' '{print $4}')
CORE_BUNDLE_ID=$(plutil -p "$CORE_FRAMEWORK/Info.plist" | grep CFBundleIdentifier | awk -F'"' '{print $4}')

echo "Models framework bundle ID: $MODELS_BUNDLE_ID"
echo "Core framework bundle ID: $CORE_BUNDLE_ID"

# Check app Info.plist
echo "Checking app Info.plist..."
APP_BUNDLE_ID=$(plutil -p "$APP_PATH/Info.plist" | grep CFBundleIdentifier | awk -F'"' '{print $4}')
echo "App bundle ID: $APP_BUNDLE_ID"

# Check embedded.mobileprovision
echo "Checking embedded.mobileprovision..."
security cms -D -i "$APP_PATH/embedded.mobileprovision" > /tmp/provision.plist
PROVISION_BUNDLE_ID=$(grep -A 5 application-identifier /tmp/provision.plist | grep string | head -n 1 | awk -F'>' '{print $2}' | awk -F'<' '{print $1}' | awk -F'.' '{print $2"."$3"."$4}')
echo "Provisioning profile bundle ID: $PROVISION_BUNDLE_ID"

# Check if device is in provisioning profile
DEVICE_IN_PROFILE=$(grep -A 50 ProvisionedDevices /tmp/provision.plist | grep -c "$DEVICE_ID" || true)
if [ "$DEVICE_IN_PROFILE" -eq 0 ]; then
    echo "Warning: Device $DEVICE_ID not found in provisioning profile"
else
    echo "Device $DEVICE_ID found in provisioning profile"
fi

# Re-sign frameworks and app
echo "Re-signing frameworks and app..."
codesign --force --sign "Apple Development" "$MODELS_FRAMEWORK"
codesign --force --sign "Apple Development" "$CORE_FRAMEWORK"
codesign --force --sign "Apple Development" "$APP_PATH"

echo "Verification of code signatures..."
codesign -vv "$MODELS_FRAMEWORK"
codesign -vv "$CORE_FRAMEWORK"
codesign -vv "$APP_PATH"

# Install app on device
echo "Installing app on device..."
xcrun ios-deploy --id "$DEVICE_ID" --bundle "$APP_PATH" --no-wifi --debug

echo "===== FIX AND INSTALL PROCESS COMPLETED =====" 