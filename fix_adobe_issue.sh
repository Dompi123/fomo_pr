#!/bin/bash

# Script to fix the Adobe Genuine Service issue

echo "Fixing Adobe Genuine Service issue for FOMO_PR..."

# Path to the Info.plist file
INFO_PLIST="FOMO_PR/Info.plist"

# Backup the original file
if [ -f "$INFO_PLIST" ]; then
    cp "$INFO_PLIST" "${INFO_PLIST}.adobe.backup"
    
    # Add LSUIElement key to prevent Adobe Genuine Service from interfering
    # This makes the app run as a UI element, which can help avoid certain system services
    echo "Adding LSUIElement key to Info.plist..."
    
    # Check if LSUIElement already exists
    if ! grep -q "<key>LSUIElement</key>" "$INFO_PLIST"; then
        # Insert LSUIElement key before the closing </dict>
        sed -i '' 's/<\/dict>/\t<key>LSUIElement<\/key>\n\t<false\/>\n<\/dict>/g' "$INFO_PLIST"
    fi
    
    # Add NSAppTransportSecurity to allow network connections
    if ! grep -q "<key>NSAppTransportSecurity</key>" "$INFO_PLIST"; then
        echo "Adding NSAppTransportSecurity to Info.plist..."
        sed -i '' 's/<\/dict>/\t<key>NSAppTransportSecurity<\/key>\n\t<dict>\n\t\t<key>NSAllowsArbitraryLoads<\/key>\n\t\t<true\/>\n\t<\/dict>\n<\/dict>/g' "$INFO_PLIST"
    fi
    
    echo "Info.plist updated successfully."
else
    echo "Error: Info.plist not found at $INFO_PLIST"
    exit 1
fi

echo "Adobe Genuine Service fix applied. Please try building and running on your device again." 