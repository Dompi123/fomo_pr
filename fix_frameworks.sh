#!/bin/bash

# Set variables
DEVICE_ID="00008140-001A08691AD0801C"
APP_PATH="/Users/dom.khr/Library/Developer/Xcode/DerivedData/FOMO_PR-cuzpopjqrlgvlgfwfvbubforhssv/Build/Products/Debug-iphoneos/FOMO_PR.app"
TEAM_ID="6F7G7337CY"
BUNDLE_ID="com.fomoapp.fomopr"

echo "Fixing framework bundle identifiers..."

# Fix Models framework
MODELS_INFO_PLIST="$APP_PATH/Frameworks/Models.framework/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.fomoapp.fomopr.Models" "$MODELS_INFO_PLIST"
echo "Added bundle identifier to Models framework"

# Fix Core framework
CORE_INFO_PLIST="$APP_PATH/Frameworks/Core.framework/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.fomoapp.fomopr.Core" "$CORE_INFO_PLIST"
echo "Added bundle identifier to Core framework"

# Re-sign the frameworks
echo "Re-signing frameworks..."
codesign --force --sign "iPhone Developer: $TEAM_ID" "$APP_PATH/Frameworks/Models.framework"
codesign --force --sign "iPhone Developer: $TEAM_ID" "$APP_PATH/Frameworks/Core.framework"

# Re-sign the main app
echo "Re-signing main app..."
codesign --force --sign "iPhone Developer: $TEAM_ID" "$APP_PATH"

# Install the app
echo "Installing app..."
xcrun ios-deploy --id "$DEVICE_ID" --bundle "$APP_PATH" --debug

echo "Done!" 