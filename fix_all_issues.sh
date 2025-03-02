#!/bin/bash

# Comprehensive script to fix all issues with FOMO_PR

echo "Applying all fixes for FOMO_PR..."

# 1. Fix system frameworks
if [ -f "./fix_system_frameworks.sh" ]; then
    echo "Running fix_system_frameworks.sh..."
    chmod +x ./fix_system_frameworks.sh
    ./fix_system_frameworks.sh
else
    echo "Warning: fix_system_frameworks.sh not found. Skipping this step."
fi

# 2. Fix embed frameworks
if [ -f "./fix_embed_frameworks.sh" ]; then
    echo "Running fix_embed_frameworks.sh..."
    chmod +x ./fix_embed_frameworks.sh
    ./fix_embed_frameworks.sh
else
    echo "Warning: fix_embed_frameworks.sh not found. Skipping this step."
fi

# 3. Fix code signing
if [ -f "./fix_code_signing.sh" ]; then
    echo "Running fix_code_signing.sh..."
    chmod +x ./fix_code_signing.sh
    ./fix_code_signing.sh
else
    echo "Warning: fix_code_signing.sh not found. Skipping this step."
fi

# 4. Fix Adobe issue
if [ -f "./fix_adobe_issue.sh" ]; then
    echo "Running fix_adobe_issue.sh..."
    chmod +x ./fix_adobe_issue.sh
    ./fix_adobe_issue.sh
else
    echo "Warning: fix_adobe_issue.sh not found. Skipping this step."
fi

# 5. Additional fixes for Info.plist
INFO_PLIST="FOMO_PR/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    echo "Applying additional fixes to Info.plist..."
    
    # Backup if not already backed up
    if [ ! -f "${INFO_PLIST}.all.backup" ]; then
        cp "$INFO_PLIST" "${INFO_PLIST}.all.backup"
    fi
    
    # Add privacy descriptions for any potential permissions
    # These are commonly required for device testing
    
    # Camera usage description
    if ! grep -q "<key>NSCameraUsageDescription</key>" "$INFO_PLIST"; then
        echo "Adding camera usage description..."
        sed -i '' 's/<\/dict>/\t<key>NSCameraUsageDescription<\/key>\n\t<string>This app needs access to the camera to scan QR codes.<\/string>\n<\/dict>/g' "$INFO_PLIST"
    fi
    
    # Photo library usage description
    if ! grep -q "<key>NSPhotoLibraryUsageDescription</key>" "$INFO_PLIST"; then
        echo "Adding photo library usage description..."
        sed -i '' 's/<\/dict>/\t<key>NSPhotoLibraryUsageDescription<\/key>\n\t<string>This app needs access to your photo library to save and upload images.<\/string>\n<\/dict>/g' "$INFO_PLIST"
    fi
    
    # Location usage description
    if ! grep -q "<key>NSLocationWhenInUseUsageDescription</key>" "$INFO_PLIST"; then
        echo "Adding location usage description..."
        sed -i '' 's/<\/dict>/\t<key>NSLocationWhenInUseUsageDescription<\/key>\n\t<string>This app needs access to your location to show nearby venues.<\/string>\n<\/dict>/g' "$INFO_PLIST"
    fi
    
    echo "Additional Info.plist fixes applied."
fi

echo "All fixes have been applied. Please open the project in Xcode, set your development team manually, and try building and running on your device again."
echo "If you still encounter issues, please check the Xcode logs for more details." 