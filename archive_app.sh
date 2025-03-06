#!/bin/bash

# Script to archive FOMO_PR app for distribution

echo "📦 Archiving FOMO_PR app for distribution..."

# Set environment variables for production
export ENABLE_PAYWALL=true
export ENABLE_DRINK_MENU=true
export ENABLE_CHECKOUT=true
export ENABLE_SEARCH=true
export ENABLE_PREMIUM_VENUES=true
export USE_MOCK_DATA=false
export PREVIEW_MODE=false

# Clean build directory
echo "🧹 Cleaning build directory..."
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Release

# Archive the app
echo "🗄️ Creating archive..."
ARCHIVE_PATH="./build/FOMO_PR.xcarchive"
xcodebuild archive -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Release -archivePath "$ARCHIVE_PATH"

# Check if archive was successful
if [ $? -eq 0 ]; then
    echo "✅ Archive created successfully at: $ARCHIVE_PATH"
    echo ""
    echo "To export the archive for distribution:"
    echo "1. Open Xcode"
    echo "2. Go to Window > Organizer"
    echo "3. Find the FOMO_PR archive"
    echo "4. Click 'Distribute App' and follow the steps"
    echo ""
    echo "Alternatively, you can export the archive using the command line:"
    echo "xcodebuild -exportArchive -archivePath \"$ARCHIVE_PATH\" -exportPath \"./build/export\" -exportOptionsPlist \"ExportOptions.plist\""
    echo ""
    echo "Note: You'll need to create an ExportOptions.plist file with your distribution settings."
else
    echo "❌ Archive creation failed. Please check the error messages above."
fi 