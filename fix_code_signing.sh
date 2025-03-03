#!/bin/bash

echo "===== FIXING CODE SIGNING AND REBUILDING APP ====="

# Define paths and identifiers
DEVICE_ID="00008140-001A08691AD0801C"
BUNDLE_ID="com.fomoapp.fomopr"
PROJECT_PATH="/Users/dom.khr/fomopr/FOMO_PR.xcodeproj"

echo "Device ID: $DEVICE_ID"
echo "Bundle ID: $BUNDLE_ID"
echo "Project Path: $PROJECT_PATH"

# First, update the project settings to fix code signing issues
echo "Updating project settings to enable code signing for all targets..."

# Create a temporary Ruby script to modify the Xcode project
cat > update_project_settings.rb << 'EOL'
#!/usr/bin/env ruby
require 'xcodeproj'

project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)

# Find the Core target
core_target = project.targets.find { |t| t.name == 'Core' }
if core_target
  core_target.build_configurations.each do |config|
    # Enable code signing for Core target
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
    
    # Remove the "Don't Code Sign" setting
    config.build_settings.delete('CODE_SIGN_IDENTITY[sdk=iphoneos*]')
    
    # Set proper bundle ID
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.fomoapp.fomopr.Core'
  end
  puts "Updated Core target settings"
end

# Find the Models target
models_target = project.targets.find { |t| t.name == 'Models' }
if models_target
  models_target.build_configurations.each do |config|
    # Enable code signing for Models target
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
    
    # Remove the "Don't Code Sign" setting
    config.build_settings.delete('CODE_SIGN_IDENTITY[sdk=iphoneos*]')
    
    # Set proper bundle ID
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.fomoapp.fomopr.Models'
  end
  puts "Updated Models target settings"
end

# Find the main app target
main_target = project.targets.find { |t| t.name == 'FOMO_PR' }
if main_target
  main_target.build_configurations.each do |config|
    # Ensure code signing is enabled
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
    
    # Set proper bundle ID
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.fomoapp.fomopr'
  end
  puts "Updated FOMO_PR target settings"
end

# Save the project
project.save
puts "Project settings updated successfully"
EOL

# Make the script executable
chmod +x update_project_settings.rb

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    echo "Ruby is required but not installed. Please install Ruby and try again."
    exit 1
fi

# Check if xcodeproj gem is installed
if ! gem list -i xcodeproj &> /dev/null; then
    echo "Installing xcodeproj gem..."
    gem install xcodeproj
fi

# Run the script to update project settings
echo "Applying project setting changes..."
ruby update_project_settings.rb "$PROJECT_PATH"

# Clean build artifacts
echo "Cleaning previous builds..."
xcodebuild clean -project "$PROJECT_PATH" -scheme FOMO_PR -configuration Debug

# Build with code signing enabled for all targets
echo "Building app with proper code signing..."
xcodebuild -project "$PROJECT_PATH" -scheme FOMO_PR -configuration Debug \
  CODE_SIGN_IDENTITY="Apple Development" \
  CODE_SIGNING_REQUIRED=YES \
  CODE_SIGNING_ALLOWED=YES \
  -destination "id=$DEVICE_ID" build

# Find the app
echo "Locating built app..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FOMO_PR.app" -path "*/Build/Products/Debug-iphoneos*" | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo "ERROR: Could not find built app"
    exit 1
fi
echo "Found app at: $APP_PATH"

# Fix frameworks bundle IDs if needed
echo "Checking and fixing frameworks bundle IDs..."
if [ -d "$APP_PATH/Frameworks" ]; then
    echo "Frameworks directory found"
    
    # Fix Models framework
    if [ -d "$APP_PATH/Frameworks/Models.framework" ]; then
        echo "Checking Models.framework..."
        MODELS_BUNDLE_ID=$(plutil -p "$APP_PATH/Frameworks/Models.framework/Info.plist" | grep CFBundleIdentifier | awk -F'"' '{print $4}')
        if [ -z "$MODELS_BUNDLE_ID" ]; then
            echo "Adding bundle ID to Models.framework..."
            /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID.Models" "$APP_PATH/Frameworks/Models.framework/Info.plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID.Models" "$APP_PATH/Frameworks/Models.framework/Info.plist"
        else
            echo "Models.framework bundle ID: $MODELS_BUNDLE_ID"
        fi
    fi
    
    # Fix Core framework
    if [ -d "$APP_PATH/Frameworks/Core.framework" ]; then
        echo "Checking Core.framework..."
        CORE_BUNDLE_ID=$(plutil -p "$APP_PATH/Frameworks/Core.framework/Info.plist" | grep CFBundleIdentifier | awk -F'"' '{print $4}')
        if [ -z "$CORE_BUNDLE_ID" ]; then
            echo "Adding bundle ID to Core.framework..."
            /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID.Core" "$APP_PATH/Frameworks/Core.framework/Info.plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID.Core" "$APP_PATH/Frameworks/Core.framework/Info.plist"
        else
            echo "Core.framework bundle ID: $CORE_BUNDLE_ID"
        fi
    fi
fi

# Re-sign everything with proper identity
echo "Re-signing frameworks and app..."
if [ -d "$APP_PATH/Frameworks/Models.framework" ]; then
    echo "Re-signing Models.framework..."
    codesign -f -s "Apple Development" --preserve-metadata=identifier,entitlements "$APP_PATH/Frameworks/Models.framework"
fi

if [ -d "$APP_PATH/Frameworks/Core.framework" ]; then
    echo "Re-signing Core.framework..."
    codesign -f -s "Apple Development" --preserve-metadata=identifier,entitlements "$APP_PATH/Frameworks/Core.framework"
fi

echo "Re-signing main app..."
codesign -f -s "Apple Development" --preserve-metadata=identifier,entitlements "$APP_PATH"

# Install the app with frameworks
echo "Installing app with frameworks..."
xcrun ios-deploy --id "$DEVICE_ID" --bundle "$APP_PATH" --no-wifi

echo "===== INSTALLATION PROCESS COMPLETED ====="
echo "If the app still crashes, please try running it directly from Xcode with the device connected." 