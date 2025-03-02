#!/bin/bash

# Script to fix simulator-specific crash issues

echo "Fixing simulator crash issues for FOMO_PR..."

# Path to the Info.plist file
INFO_PLIST="FOMO_PR/Info.plist"

# Backup the original file
if [ -f "$INFO_PLIST" ]; then
    cp "$INFO_PLIST" "${INFO_PLIST}.simulator.backup"
    
    # Remove LSUIElement as it might be causing issues on simulator
    if grep -q "<key>LSUIElement</key>" "$INFO_PLIST"; then
        echo "Removing LSUIElement from Info.plist..."
        sed -i '' '/<key>LSUIElement<\/key>/,/<false\/>/d' "$INFO_PLIST"
    fi
    
    # Fix UIApplicationSceneManifest for SwiftUI lifecycle
    if grep -q "<key>UIApplicationSceneManifest</key>" "$INFO_PLIST"; then
        echo "Fixing UIApplicationSceneManifest in Info.plist..."
        # Remove the entire UIApplicationSceneManifest section and replace with a simpler version
        sed -i '' '/<key>UIApplicationSceneManifest<\/key>/,/<\/dict>/d' "$INFO_PLIST"
        
        # Add a simplified UIApplicationSceneManifest
        sed -i '' 's/<\/dict>/\t<key>UIApplicationSceneManifest<\/key>\n\t<dict>\n\t\t<key>UIApplicationSupportsMultipleScenes<\/key>\n\t\t<false\/>\n\t<\/dict>\n<\/dict>/g' "$INFO_PLIST"
    fi
    
    # Add UILaunchScreen dictionary
    if ! grep -q "<key>UILaunchScreen</key>" "$INFO_PLIST"; then
        echo "Adding UILaunchScreen to Info.plist..."
        sed -i '' 's/<\/dict>/\t<key>UILaunchScreen<\/key>\n\t<dict\/>\n<\/dict>/g' "$INFO_PLIST"
    fi
    
    echo "Info.plist updated for simulator compatibility."
else
    echo "Error: Info.plist not found at $INFO_PLIST"
    exit 1
fi

# Fix project settings for simulator
PROJECT_FILE="FOMO_PR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    cp "$PROJECT_FILE" "${PROJECT_FILE}.simulator.backup"
    
    # Revert code signing to Automatic for simulator builds
    echo "Reverting code signing to Automatic for simulator builds..."
    sed -i '' 's/CODE_SIGN_STYLE = Manual;/CODE_SIGN_STYLE = Automatic;/g' "$PROJECT_FILE"
    
    echo "Project file updated for simulator compatibility."
else
    echo "Error: Project file not found at $PROJECT_FILE"
    exit 1
fi

# Clean derived data to ensure a fresh build
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/FOMO_PR-*

echo "Simulator crash fixes applied. Please try building and running on the simulator again."
echo "If you need to run on a device later, you may need to reapply the device-specific fixes." 