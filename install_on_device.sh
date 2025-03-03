#!/bin/bash

echo "===== INSTALLING FOMO_PR ON PHYSICAL DEVICE ====="

# Device ID for Domenico's iPhone
DEVICE_ID="00008140-001A08691AD0801C"
TEAM_ID="6F7G7337CY"
BUNDLE_ID="com.fomoapp.fomopr"

echo "Device ID: $DEVICE_ID"
echo "Team ID: $TEAM_ID"
echo "Bundle ID: $BUNDLE_ID"

# Check if device is connected
echo "Checking for connected device..."
xcrun xctrace list devices | grep -w "$DEVICE_ID" || { echo "Device not found. Make sure it's connected."; exit 1; }
echo "Device found!"

# Clean and build
echo "Cleaning previous builds..."
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Debug || { echo "Clean failed"; exit 1; }
echo "Clean successful"

echo "Building app..."
xcodebuild -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Debug -destination "id=$DEVICE_ID" build || { echo "Build failed"; exit 1; }
echo "Build successful"

# Run fix script
echo "Running fix script..."
./fix_built_frameworks.sh
FIX_EXIT_CODE=$?
echo "Fix script completed with exit code: $FIX_EXIT_CODE"

# Find the app
echo "Finding built app..."
APP_PATH=""

# Try multiple locations
echo "Searching in InstallationBuildProductsLocation..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*InstallationBuildProductsLocation*" -name "FOMO_PR.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo "Searching in ArchiveIntermediates..."
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*ArchiveIntermediates*" -name "FOMO_PR.app" -type d | head -n 1)
fi

if [ -z "$APP_PATH" ]; then
    echo "Searching in Debug-iphoneos..."
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FOMO_PR.app" -type d -path "*/Build/Products/Debug-iphoneos*" | head -n 1)
fi

if [ -z "$APP_PATH" ]; then
    echo "Searching anywhere..."
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FOMO_PR.app" -type d | head -n 1)
fi

if [ -z "$APP_PATH" ]; then
    echo "Could not find built app"
    exit 1
fi

echo "Found app at: $APP_PATH"

# Check Info.plist
echo "Checking Info.plist..."
PLIST_BUNDLE_ID=$(plutil -p "$APP_PATH/Info.plist" | grep CFBundleIdentifier | awk -F'"' '{print $4}')
echo "Bundle ID in Info.plist: $PLIST_BUNDLE_ID"

if [ "$PLIST_BUNDLE_ID" != "$BUNDLE_ID" ]; then
    echo "Bundle ID mismatch: $PLIST_BUNDLE_ID != $BUNDLE_ID"
    exit 1
fi

# Check frameworks
echo "Checking frameworks..."
if [ -d "$APP_PATH/Frameworks" ]; then
    echo "Frameworks directory exists"
    ls -la "$APP_PATH/Frameworks"
    
    # Check Models framework
    if [ -d "$APP_PATH/Frameworks/Models.framework" ]; then
        echo "Models framework exists"
        MODELS_BUNDLE_ID=$(plutil -p "$APP_PATH/Frameworks/Models.framework/Info.plist" | grep CFBundleIdentifier || echo "No CFBundleIdentifier found")
        echo "Models framework bundle ID: $MODELS_BUNDLE_ID"
    else
        echo "Models framework not found"
    fi
    
    # Check Core framework
    if [ -d "$APP_PATH/Frameworks/Core.framework" ]; then
        echo "Core framework exists"
        CORE_BUNDLE_ID=$(plutil -p "$APP_PATH/Frameworks/Core.framework/Info.plist" | grep CFBundleIdentifier || echo "No CFBundleIdentifier found")
        echo "Core framework bundle ID: $CORE_BUNDLE_ID"
    else
        echo "Core framework not found"
    fi
else
    echo "Frameworks directory not found"
fi

# Try installing with xcodebuild first
echo "Installing app using xcodebuild..."
xcodebuild -project FOMO_PR.xcodeproj -scheme FOMO_PR -destination "id=$DEVICE_ID" -configuration Debug install

# Check if installation was successful
if xcrun ios-deploy --id "$DEVICE_ID" --list_bundle_id | grep -q "$BUNDLE_ID"; then
    echo "===== INSTALL SUCCEEDED ====="
    echo "App is installed on the device. Please check your device."
    exit 0
else
    echo "App not found on device after xcodebuild install, trying ios-deploy..."
    
    # Try installing with ios-deploy
    echo "Installing app using ios-deploy..."
    xcrun ios-deploy --id "$DEVICE_ID" --bundle "$APP_PATH" --no-wifi
    
    # Check again if installation was successful
    if xcrun ios-deploy --id "$DEVICE_ID" --list_bundle_id | grep -q "$BUNDLE_ID"; then
        echo "===== INSTALL SUCCEEDED ====="
        echo "App is installed on the device. Please check your device."
        exit 0
    else
        echo "===== INSTALL FAILED ====="
        echo "App could not be installed on the device."
        exit 1
    fi
fi 