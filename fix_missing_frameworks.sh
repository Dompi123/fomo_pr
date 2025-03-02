#!/bin/bash

# Script to fix missing frameworks by building the Swift package

echo "Fixing missing frameworks for FOMO_PR..."

# Build the Swift package to generate the frameworks
echo "Building Swift package..."
swift build

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Swift package built successfully."
else
    echo "Failed to build Swift package. Please check for errors."
    exit 1
fi

# Create Frameworks directory if it doesn't exist
mkdir -p FOMO_PR/Frameworks

# Copy the frameworks from .build/debug to FOMO_PR/Frameworks
echo "Copying frameworks to FOMO_PR/Frameworks..."

# Copy Core.framework
if [ -d ".build/debug/Core.framework" ]; then
    cp -R .build/debug/Core.framework FOMO_PR/Frameworks/
    echo "✅ Core.framework copied successfully"
else
    echo "❌ Core.framework not found in .build/debug/"
fi

# Copy Models.framework
if [ -d ".build/debug/Models.framework" ]; then
    cp -R .build/debug/Models.framework FOMO_PR/Frameworks/
    echo "✅ Models.framework copied successfully"
else
    echo "❌ Models.framework not found in .build/debug/"
fi

# Copy Network.framework (if it exists and is needed)
if [ -d ".build/debug/Network.framework" ]; then
    cp -R .build/debug/Network.framework FOMO_PR/Frameworks/
    echo "✅ Network.framework copied successfully"
else
    echo "ℹ️ Network.framework not found in .build/debug/ (this might be expected)"
fi

# Fix the Info.plist bundle identifier
INFO_PLIST="FOMO_PR/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    echo "Fixing bundle identifier in Info.plist..."
    
    # Backup the file
    cp "$INFO_PLIST" "${INFO_PLIST}.bundle.backup"
    
    # Replace the bundle identifier placeholder with an explicit value
    sed -i '' 's/<string>$(PRODUCT_BUNDLE_IDENTIFIER)<\/string>/<string>com.fomo.FOMO-PR<\/string>/g' "$INFO_PLIST"
    
    echo "Bundle identifier fixed in Info.plist"
else
    echo "❌ Info.plist not found at $INFO_PLIST"
fi

# Update the project file to reference the correct framework paths
PROJECT_FILE="FOMO_PR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    echo "Updating framework references in project file..."
    
    # Backup the file
    cp "$PROJECT_FILE" "${PROJECT_FILE}.frameworks.backup"
    
    # Update Core.framework reference
    sed -i '' 's|path = Core.framework;|path = FOMO_PR/Frameworks/Core.framework;|g' "$PROJECT_FILE"
    
    # Update Models.framework reference
    sed -i '' 's|path = Models.framework;|path = FOMO_PR/Frameworks/Models.framework;|g' "$PROJECT_FILE"
    
    echo "Framework references updated in project file"
else
    echo "❌ Project file not found at $PROJECT_FILE"
fi

echo "Missing frameworks fix completed. Please try building and running the app again." 