#!/bin/bash
set -e

# Define paths
APP_PATH="/Users/dom.khr/Library/Developer/Xcode/DerivedData/FOMO_PR-cuzpopjqrlgvlgfwfvbubforhssv/Build/Intermediates.noindex/ArchiveIntermediates/FOMO_PR/InstallationBuildProductsLocation/Applications/FOMO_PR.app"
DEVICE_ID="00008140-001A08691AD0801C"
TEMP_DIR="/tmp/fixed_app"
FIXED_APP="$TEMP_DIR/FOMO_PR.app"

echo "Starting fix and install process..."

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

# Check and fix Info.plist files
echo "Checking app Info.plist..."
plutil -p "$FIXED_APP/Info.plist" | grep CFBundleIdentifier

# Check frameworks
if [ -d "$FIXED_APP/Frameworks" ]; then
    echo "Checking frameworks..."
    
    # Check Models framework
    if [ -d "$FIXED_APP/Frameworks/Models.framework" ]; then
        echo "Checking Models.framework Info.plist..."
        
        # Add CFBundleIdentifier to Models.framework
        echo "Adding CFBundleIdentifier to Models.framework Info.plist..."
        /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.fomoapp.fomopr.Models" "$FIXED_APP/Frameworks/Models.framework/Info.plist" || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.fomoapp.fomopr.Models" "$FIXED_APP/Frameworks/Models.framework/Info.plist"
        
        # Verify the change
        echo "Verifying Models.framework Info.plist..."
        plutil -p "$FIXED_APP/Frameworks/Models.framework/Info.plist" | grep CFBundleIdentifier
    fi
    
    # Check Core framework
    if [ -d "$FIXED_APP/Frameworks/Core.framework" ]; then
        echo "Checking Core.framework Info.plist..."
        
        # Add CFBundleIdentifier to Core.framework
        echo "Adding CFBundleIdentifier to Core.framework Info.plist..."
        /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.fomoapp.fomopr.Core" "$FIXED_APP/Frameworks/Core.framework/Info.plist" || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.fomoapp.fomopr.Core" "$FIXED_APP/Frameworks/Core.framework/Info.plist"
        
        # Verify the change
        echo "Verifying Core.framework Info.plist..."
        plutil -p "$FIXED_APP/Frameworks/Core.framework/Info.plist" | grep CFBundleIdentifier
    fi
fi

# Check embedded provisioning profile
echo "Checking embedded provisioning profile..."
if [ -f "$FIXED_APP/embedded.mobileprovision" ]; then
    echo "Provisioning profile found. Checking device inclusion..."
    security cms -D -i "$FIXED_APP/embedded.mobileprovision" | grep -A 50 ProvisionedDevices | grep -B 5 -A 5 "$DEVICE_ID" || echo "Device not found in provisioning profile, but continuing anyway..."
else
    echo "Warning: No embedded.mobileprovision found!"
fi

# Re-sign frameworks and app
echo "Re-signing frameworks and app..."
if [ -d "$FIXED_APP/Frameworks/Models.framework" ]; then
    echo "Re-signing Models.framework..."
    codesign -f -s "Apple Development" "$FIXED_APP/Frameworks/Models.framework"
fi

if [ -d "$FIXED_APP/Frameworks/Core.framework" ]; then
    echo "Re-signing Core.framework..."
    codesign -f -s "Apple Development" "$FIXED_APP/Frameworks/Core.framework"
fi

echo "Re-signing main app..."
codesign -f -s "Apple Development" "$FIXED_APP"

# Verify code signatures
echo "Verifying code signatures..."
if [ -d "$FIXED_APP/Frameworks/Models.framework" ]; then
    codesign -v "$FIXED_APP/Frameworks/Models.framework" || echo "Models.framework signature verification failed, but continuing..."
fi

if [ -d "$FIXED_APP/Frameworks/Core.framework" ]; then
    codesign -v "$FIXED_APP/Frameworks/Core.framework" || echo "Core.framework signature verification failed, but continuing..."
fi

codesign -v "$FIXED_APP" || echo "App signature verification failed, but continuing..."

# Install app on device
echo "Installing app on device..."
xcrun ios-deploy --id "$DEVICE_ID" --bundle "$FIXED_APP" --debug --verbose

echo "Installation process completed." 