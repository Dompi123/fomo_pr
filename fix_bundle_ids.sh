#!/bin/bash

# Define variables
DEVICE_ID="00008140-001A08691AD0801C"
BUNDLE_ID="com.fomoapp.fomopr"
PROJECT_PATH="/Users/dom.khr/fomopr/FOMO_PR.xcodeproj"
BUILD_DIR="/Users/dom.khr/Library/Developer/Xcode/DerivedData/FOMO_PR-cuzpopjqrlgvlgfwfvbubforhssv/Build/Products/Debug-iphoneos"
APP_PATH="$BUILD_DIR/FOMO_PR.app"

echo "Device ID: $DEVICE_ID"
echo "Bundle ID: $BUNDLE_ID"
echo "Project Path: $PROJECT_PATH"
echo "App Path: $APP_PATH"

# Create a Ruby script to update the project settings
cat > update_bundle_ids.rb << 'EOL'
#!/usr/bin/env ruby
require 'xcodeproj'

# Open the Xcode project
project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)

# Update settings for each target
project.targets.each do |target|
  target_name = target.name
  
  # Set appropriate bundle ID based on target name
  if target_name == "FOMO_PR"
    bundle_id = "com.fomoapp.fomopr"
  elsif target_name == "Core"
    bundle_id = "com.fomoapp.fomopr.Core"
  elsif target_name == "Models"
    bundle_id = "com.fomoapp.fomopr.Models"
  else
    next
  end
  
  # Update build settings for all configurations
  target.build_configurations.each do |config|
    # Enable code signing
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
    
    # Remove any settings that prevent code signing
    config.build_settings.delete('CODE_SIGNING_ALLOWED[sdk=iphonesimulator*]')
    config.build_settings.delete('CODE_SIGNING_REQUIRED[sdk=iphonesimulator*]')
  end
end

# Save the project
project.save
EOL

# Make the Ruby script executable
chmod +x update_bundle_ids.rb

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
  echo "Ruby is not installed. Please install Ruby and try again."
  exit 1
fi

# Check if xcodeproj gem is installed
if ! gem list -i xcodeproj &> /dev/null; then
  echo "Installing xcodeproj gem..."
  gem install xcodeproj
fi

# Run the Ruby script to update project settings
ruby update_bundle_ids.rb "$PROJECT_PATH"
echo "Project settings updated successfully."

# Clean previous builds
echo "Cleaning previous builds..."
xcodebuild -project "$PROJECT_PATH" -scheme FOMO_PR -configuration Debug clean

# Build the app with code signing enabled
echo "Building app with code signing enabled..."
xcodebuild -project "$PROJECT_PATH" -scheme FOMO_PR -configuration Debug \
  CODE_SIGN_IDENTITY="Apple Development" \
  CODE_SIGNING_REQUIRED=YES \
  CODE_SIGNING_ALLOWED=YES \
  build

# Check if the app was built successfully
if [ ! -d "$APP_PATH" ]; then
  echo "App build failed. Check the build logs for errors."
  exit 1
fi

# Fix framework bundle IDs
echo "Fixing framework bundle IDs..."

# Fix Core framework bundle ID
CORE_INFO_PLIST="$APP_PATH/Frameworks/Core.framework/Info.plist"
if [ -f "$CORE_INFO_PLIST" ]; then
  /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.fomoapp.fomopr.Core" "$CORE_INFO_PLIST" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.fomoapp.fomopr.Core" "$CORE_INFO_PLIST"
  echo "Core framework bundle ID set to com.fomoapp.fomopr.Core"
fi

# Fix Models framework bundle ID
MODELS_INFO_PLIST="$APP_PATH/Frameworks/Models.framework/Info.plist"
if [ -f "$MODELS_INFO_PLIST" ]; then
  /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.fomoapp.fomopr.Models" "$MODELS_INFO_PLIST" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.fomoapp.fomopr.Models" "$MODELS_INFO_PLIST"
  echo "Models framework bundle ID set to com.fomoapp.fomopr.Models"
fi

# Re-sign the frameworks
echo "Re-signing frameworks..."
IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Development" | head -n 1 | awk '{print $2}')

if [ -z "$IDENTITY" ]; then
  echo "No valid code signing identity found."
  exit 1
fi

echo "Using code signing identity: $IDENTITY"

# Re-sign Core framework
if [ -d "$APP_PATH/Frameworks/Core.framework" ]; then
  codesign --force --sign "$IDENTITY" "$APP_PATH/Frameworks/Core.framework"
  echo "Core framework re-signed."
fi

# Re-sign Models framework
if [ -d "$APP_PATH/Frameworks/Models.framework" ]; then
  codesign --force --sign "$IDENTITY" "$APP_PATH/Frameworks/Models.framework"
  echo "Models framework re-signed."
fi

# Re-sign the main app
codesign --force --sign "$IDENTITY" "$APP_PATH"
echo "Main app re-signed."

# Install the app on the device
echo "Installing app on device..."
xcrun ios-deploy -i "$DEVICE_ID" -b "$APP_PATH" --debug

echo "Installation process completed." 