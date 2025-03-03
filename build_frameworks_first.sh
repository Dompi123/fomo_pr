#!/bin/bash

# Get the device ID
DEVICE_ID=$(xcrun xctrace list devices | grep -v 'Simulator' | grep -v 'Mac' | grep -v '=' | head -1 | awk '{print $NF}' | tr -d '()')
echo "Using device ID: $DEVICE_ID"

# Set the bundle ID
BUNDLE_ID="com.fomoapp.fomopr"
echo "Using bundle ID: $BUNDLE_ID"

# Set the team ID
TEAM_ID="6F7G7337CY"

# Set the project path and build directory
PROJECT_PATH="$(pwd)"
BUILD_DIR="${PROJECT_PATH}/build/Debug-iphoneos"

# Clean build directory if it exists
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"

# Build Models framework
echo "Building Models framework..."
xcodebuild -project FOMO_PR.xcodeproj -target Models -configuration Debug -sdk iphoneos "CODE_SIGN_IDENTITY=Apple Development" CODE_SIGNING_REQUIRED=YES CODE_SIGNING_ALLOWED=YES build

# Build Core framework
echo "Building Core framework..."
xcodebuild -project FOMO_PR.xcodeproj -target Core -configuration Debug -sdk iphoneos "CODE_SIGN_IDENTITY=Apple Development" CODE_SIGNING_REQUIRED=YES CODE_SIGNING_ALLOWED=YES build

# Build main app
echo "Building main app..."
xcodebuild -project FOMO_PR.xcodeproj -target FOMO_PR -configuration Debug -sdk iphoneos "CODE_SIGN_IDENTITY=Apple Development" CODE_SIGNING_REQUIRED=YES CODE_SIGNING_ALLOWED=YES build

# Fixing bundle IDs in Info.plist files
echo "Fixing bundle IDs in Info.plist files..."

# Fix Models framework bundle ID
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $TEAM_ID.com.fomoapp.fomopr.models" "$BUILD_DIR/Models.framework/Info.plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $TEAM_ID.com.fomoapp.fomopr.models" "$BUILD_DIR/Models.framework/Info.plist"
echo "Fixed Models framework bundle ID"

# Fix Core framework bundle ID
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $TEAM_ID.com.fomoapp.fomopr.core" "$BUILD_DIR/Core.framework/Info.plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $TEAM_ID.com.fomoapp.fomopr.core" "$BUILD_DIR/Core.framework/Info.plist"
echo "Fixed Core framework bundle ID"

# Fix main app bundle ID
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$BUILD_DIR/FOMO_PR.app/Info.plist"
echo "Fixed main app bundle ID"

# Re-signing frameworks and app
echo "Re-signing frameworks and app..."

# Find the code signing identity
CODE_SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Development" | head -1 | awk '{print $2}')
echo "Using code signing identity: $CODE_SIGN_IDENTITY"

# Find the provisioning profile
PROVISIONING_PROFILE_PATH="/Users/dom.khr/Library/Developer/Xcode/UserData/Provisioning Profiles/b05efd31-e5dd-4c0e-9183-4139ed85e957.mobileprovision"
echo "Using provisioning profile: $PROVISIONING_PROFILE_PATH"

# Copy the provisioning profile to the app
cp "$PROVISIONING_PROFILE_PATH" "$BUILD_DIR/FOMO_PR.app/embedded.mobileprovision"

# Re-sign the frameworks
codesign --force --sign "$CODE_SIGN_IDENTITY" --timestamp=none "$BUILD_DIR/Core.framework"
echo "Core framework re-signed"

codesign --force --sign "$CODE_SIGN_IDENTITY" --timestamp=none "$BUILD_DIR/Models.framework"
echo "Models framework re-signed"

# Copy frameworks to app bundle
mkdir -p "$BUILD_DIR/FOMO_PR.app/Frameworks"
cp -R "$BUILD_DIR/Core.framework" "$BUILD_DIR/FOMO_PR.app/Frameworks/"
cp -R "$BUILD_DIR/Models.framework" "$BUILD_DIR/FOMO_PR.app/Frameworks/"

# Re-sign the frameworks in the app bundle
codesign --force --sign "$CODE_SIGN_IDENTITY" --timestamp=none --preserve-metadata=identifier,entitlements,flags "$BUILD_DIR/FOMO_PR.app/Frameworks/Core.framework"
codesign --force --sign "$CODE_SIGN_IDENTITY" --timestamp=none --preserve-metadata=identifier,entitlements,flags "$BUILD_DIR/FOMO_PR.app/Frameworks/Models.framework"

# Re-sign the main app
codesign --force --sign "$CODE_SIGN_IDENTITY" --timestamp=none --entitlements "$PROJECT_PATH/build/FOMO_PR.build/Debug-iphoneos/FOMO_PR.build/FOMO_PR.app.xcent" "$BUILD_DIR/FOMO_PR.app"
echo "Main app re-signed"

# Verify the app
codesign --verify --verbose "$BUILD_DIR/FOMO_PR.app"
echo "App verification complete"

# Install the app on the device
echo "Installing app on device..."
xcrun ios-deploy --debug --id "$DEVICE_ID" --bundle "$BUILD_DIR/FOMO_PR.app" --no-wifi 