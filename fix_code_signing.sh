#!/bin/bash

# Script to fix code signing issues for running on a real device

echo "Fixing code signing issues for FOMO_PR..."

# Path to the project.pbxproj file
PROJECT_FILE="FOMO_PR.xcodeproj/project.pbxproj"

# Backup the original file
cp "$PROJECT_FILE" "${PROJECT_FILE}.codesign.backup"

# Update the code signing settings
# 1. Set CODE_SIGN_STYLE to Manual
# 2. Set DEVELOPMENT_TEAM to your team ID
# 3. Set PROVISIONING_PROFILE_SPECIFIER to a valid profile

# Replace "Apple Development" with "iPhone Developer" for device builds
sed -i '' 's/CODE_SIGN_IDENTITY = "Apple Development";/CODE_SIGN_IDENTITY = "iPhone Developer";/g' "$PROJECT_FILE"

# Set CODE_SIGN_STYLE to Manual
sed -i '' 's/CODE_SIGN_STYLE = Automatic;/CODE_SIGN_STYLE = Manual;/g' "$PROJECT_FILE"

# Add a placeholder for DEVELOPMENT_TEAM - you'll need to replace this with your actual team ID
# This is just a placeholder - you'll need to open Xcode and set your team manually
echo "NOTE: You will need to open Xcode and set your development team manually in the project settings."

# Fix UISceneDelegateClassName in Info.plist
INFO_PLIST="FOMO_PR/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    # Backup the original file
    cp "$INFO_PLIST" "${INFO_PLIST}.backup"
    
    # Check if UISceneDelegateClassName exists and fix it if needed
    if grep -q "UISceneDelegateClassName" "$INFO_PLIST"; then
        echo "Fixing UISceneDelegateClassName in Info.plist..."
        # Remove the UISceneDelegateClassName entry since we're using SwiftUI App lifecycle
        sed -i '' '/<key>UISceneDelegateClassName<\/key>/,/<\/string>/d' "$INFO_PLIST"
    fi
fi

echo "Code signing fixes applied. Please open the project in Xcode and set your development team manually."
echo "Then try building and running on your device again." 