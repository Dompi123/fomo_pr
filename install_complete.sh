#!/bin/bash
set -e

echo "===== COMPREHENSIVE APP INSTALLATION SCRIPT ====="

# Define paths and identifiers
DEVICE_ID="00008140-001A08691AD0801C"
BUNDLE_ID="com.fomoapp.fomopr"
TEAM_ID="6F7G7337CY"

echo "Device ID: $DEVICE_ID"
echo "Bundle ID: $BUNDLE_ID"
echo "Team ID: $TEAM_ID"

# Verify device connection
echo "Verifying device connection..."
if ! xcrun xctrace list devices | grep -q "$DEVICE_ID"; then
    echo "ERROR: Device not connected or not found"
    xcrun xctrace list devices
    exit 1
fi
echo "Device connected and found!"

# Clean build artifacts
echo "Cleaning previous builds..."
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Debug

# Build for device with verbose output
echo "Building app for device..."
xcodebuild -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Debug -destination "id=$DEVICE_ID" build -verbose

# Find the app
echo "Locating built app..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FOMO_PR.app" -path "*/Build/Products/Debug-iphoneos*" | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo "ERROR: Could not find built app"
    exit 1
fi
echo "Found app at: $APP_PATH"

# Check app bundle ID
echo "Checking app bundle ID..."
APP_BUNDLE_ID=$(plutil -p "$APP_PATH/Info.plist" | grep CFBundleIdentifier | awk -F'"' '{print $4}')
echo "App bundle ID: $APP_BUNDLE_ID"

# Fix frameworks
echo "Checking and fixing frameworks..."
if [ -d "$APP_PATH/Frameworks" ]; then
    echo "Frameworks directory found"
    
    # Fix Models framework
    if [ -d "$APP_PATH/Frameworks/Models.framework" ]; then
        echo "Fixing Models.framework..."
        /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID.Models" "$APP_PATH/Frameworks/Models.framework/Info.plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID.Models" "$APP_PATH/Frameworks/Models.framework/Info.plist"
        MODELS_BUNDLE_ID=$(plutil -p "$APP_PATH/Frameworks/Models.framework/Info.plist" | grep CFBundleIdentifier | awk -F'"' '{print $4}')
        echo "Models.framework bundle ID: $MODELS_BUNDLE_ID"
    fi
    
    # Fix Core framework
    if [ -d "$APP_PATH/Frameworks/Core.framework" ]; then
        echo "Fixing Core.framework..."
        /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID.Core" "$APP_PATH/Frameworks/Core.framework/Info.plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID.Core" "$APP_PATH/Frameworks/Core.framework/Info.plist"
        CORE_BUNDLE_ID=$(plutil -p "$APP_PATH/Frameworks/Core.framework/Info.plist" | grep CFBundleIdentifier | awk -F'"' '{print $4}')
        echo "Core.framework bundle ID: $CORE_BUNDLE_ID"
    fi
fi

# Check provisioning profile
echo "Checking provisioning profile..."
if [ -f "$APP_PATH/embedded.mobileprovision" ]; then
    echo "Provisioning profile found"
    security cms -D -i "$APP_PATH/embedded.mobileprovision" > /tmp/provision.plist
    
    # Check expiration
    EXPIRATION=$(grep -A2 ExpirationDate /tmp/provision.plist | grep date | cut -d'>' -f2 | cut -d'<' -f1)
    echo "Provisioning profile expires: $EXPIRATION"
    
    # Check device inclusion
    if grep -A50 ProvisionedDevices /tmp/provision.plist | grep -q "$DEVICE_ID"; then
        echo "Device ID found in provisioning profile"
    else
        echo "WARNING: Device ID not found in provisioning profile"
    fi
    
    # Check application identifier
    APP_ID=$(grep -A5 application-identifier /tmp/provision.plist | grep string | head -n 1 | cut -d'>' -f2 | cut -d'<' -f1)
    echo "Application identifier in profile: $APP_ID"
else
    echo "WARNING: No embedded.mobileprovision found"
fi

# Re-sign everything
echo "Re-signing frameworks and app..."
if [ -d "$APP_PATH/Frameworks/Models.framework" ]; then
    codesign -f -s "Apple Development" --preserve-metadata=identifier,entitlements "$APP_PATH/Frameworks/Models.framework"
fi

if [ -d "$APP_PATH/Frameworks/Core.framework" ]; then
    codesign -f -s "Apple Development" --preserve-metadata=identifier,entitlements "$APP_PATH/Frameworks/Core.framework"
fi

codesign -f -s "Apple Development" --preserve-metadata=identifier,entitlements "$APP_PATH"

# Verify signatures
echo "Verifying code signatures..."
if [ -d "$APP_PATH/Frameworks/Models.framework" ]; then
    codesign -v -vvv "$APP_PATH/Frameworks/Models.framework" || echo "Models.framework signature verification issue"
fi

if [ -d "$APP_PATH/Frameworks/Core.framework" ]; then
    codesign -v -vvv "$APP_PATH/Frameworks/Core.framework" || echo "Core.framework signature verification issue"
fi

codesign -v -vvv "$APP_PATH" || echo "App signature verification issue"

# Try multiple installation methods
echo "===== TRYING INSTALLATION METHODS ====="

# Method 1: xcodebuild install
echo "Method 1: Using xcodebuild install..."
xcodebuild -project FOMO_PR.xcodeproj -scheme FOMO_PR -destination "id=$DEVICE_ID" -configuration Debug install

# Check if app is installed
echo "Checking if app is installed after Method 1..."
if xcrun ios-deploy --id "$DEVICE_ID" --exists --bundle_id "$BUNDLE_ID"; then
    echo "SUCCESS: App installed using Method 1"
else
    echo "Method 1 did not install the app, trying Method 2..."
    
    # Method 2: ios-deploy with no-wifi
    echo "Method 2: Using ios-deploy with no-wifi..."
    xcrun ios-deploy --id "$DEVICE_ID" --bundle "$APP_PATH" --no-wifi --debug
    
    # Check again
    echo "Checking if app is installed after Method 2..."
    if xcrun ios-deploy --id "$DEVICE_ID" --exists --bundle_id "$BUNDLE_ID"; then
        echo "SUCCESS: App installed using Method 2"
    else
        echo "Method 2 did not install the app, trying Method 3..."
        
        # Method 3: Create a temporary copy without frameworks
        echo "Method 3: Installing without frameworks..."
        TEMP_APP="/tmp/FOMO_PR_no_frameworks.app"
        rm -rf "$TEMP_APP"
        cp -R "$APP_PATH" "$TEMP_APP"
        rm -rf "$TEMP_APP/Frameworks"
        codesign -f -s "Apple Development" "$TEMP_APP"
        xcrun ios-deploy --id "$DEVICE_ID" --bundle "$TEMP_APP" --no-wifi --debug
        
        # Final check
        echo "Checking if app is installed after Method 3..."
        if xcrun ios-deploy --id "$DEVICE_ID" --exists --bundle_id "$BUNDLE_ID"; then
            echo "SUCCESS: App installed using Method 3"
        else
            echo "All methods failed to install the app"
            
            # List all installed apps for reference
            echo "Listing all installed apps on device..."
            xcrun ios-deploy --id "$DEVICE_ID" --list_bundle_id
        fi
    fi
fi

echo "===== INSTALLATION PROCESS COMPLETED =====" 