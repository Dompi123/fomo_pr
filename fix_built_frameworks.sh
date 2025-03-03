#!/bin/bash

echo "===== STARTING BUILT FRAMEWORKS FIX PROCESS ====="
echo "Script path: $0"
echo "Current directory: $(pwd)"

# Set the path to the DerivedData directory
DERIVED_DATA_DIR="/Users/dom.khr/Library/Developer/Xcode/DerivedData"
echo "DerivedData directory: $DERIVED_DATA_DIR"

# Find the FOMO_PR project directory
PROJECT_DIR=$(find "$DERIVED_DATA_DIR" -name "FOMO_PR-*" -type d | head -n 1)
echo "Project directory: $PROJECT_DIR"

# Try to find the app in different possible locations
# First, try the InstallationBuildProductsLocation path (most likely location based on logs)
APP_DIR=$(find "$PROJECT_DIR" -path "*InstallationBuildProductsLocation*" -name "FOMO_PR.app" -type d | head -n 1)

# If not found, try the ArchiveIntermediates path
if [ -z "$APP_DIR" ]; then
    APP_DIR=$(find "$PROJECT_DIR" -path "*ArchiveIntermediates*" -name "FOMO_PR.app" -type d | head -n 1)
fi

# If still not found, try the Index.noindex path
if [ -z "$APP_DIR" ]; then
    APP_DIR=$(find "$PROJECT_DIR" -path "*Index.noindex*" -name "FOMO_PR.app" -type d | head -n 1)
fi

# If still not found, try any path
if [ -z "$APP_DIR" ]; then
    APP_DIR=$(find "$PROJECT_DIR" -name "FOMO_PR.app" -type d | head -n 1)
fi

if [ -z "$APP_DIR" ]; then
    echo "Error: Could not find FOMO_PR.app directory"
    echo "===== BUILT FRAMEWORKS FIX PROCESS COMPLETED ====="
    exit 1
fi

echo "Found app directory: $APP_DIR"

# Fix Models.framework
MODELS_FRAMEWORK_PATH="$APP_DIR/Frameworks/Models.framework"
echo "Models framework path: $MODELS_FRAMEWORK_PATH"

MODELS_INFO_PLIST="$MODELS_FRAMEWORK_PATH/Info.plist"
echo "Models Info.plist path: $MODELS_INFO_PLIST"

if [ -f "$MODELS_INFO_PLIST" ]; then
    # Convert binary plist to XML
    plutil -convert xml1 "$MODELS_INFO_PLIST"
    
    # Check if CFBundleIdentifier key exists
    if grep -q "<key>CFBundleIdentifier</key>" "$MODELS_INFO_PLIST"; then
        echo "CFBundleIdentifier key already exists in Models Info.plist"
    else
        # Add CFBundleIdentifier key
        echo "Adding CFBundleIdentifier key to Models Info.plist"
        sed -i '' 's/<dict>/<dict>\
    <key>CFBundleIdentifier<\/key>\
    <string>com.fomoapp.fomopr.Models<\/string>/' "$MODELS_INFO_PLIST"
    fi
    
    # Convert back to binary plist
    plutil -convert binary1 "$MODELS_INFO_PLIST"
    echo "Models Info.plist fixed and converted back to binary format"
else
    echo "Error: Models Info.plist not found at $MODELS_INFO_PLIST"
fi

# Fix Core.framework
CORE_FRAMEWORK_PATH="$APP_DIR/Frameworks/Core.framework"
echo "Core framework path: $CORE_FRAMEWORK_PATH"

CORE_INFO_PLIST="$CORE_FRAMEWORK_PATH/Info.plist"
echo "Core Info.plist path: $CORE_INFO_PLIST"

if [ -f "$CORE_INFO_PLIST" ]; then
    # Convert binary plist to XML
    plutil -convert xml1 "$CORE_INFO_PLIST"
    
    # Check if CFBundleIdentifier key exists
    if grep -q "<key>CFBundleIdentifier</key>" "$CORE_INFO_PLIST"; then
        echo "CFBundleIdentifier key already exists in Core Info.plist"
    else
        # Add CFBundleIdentifier key
        echo "Adding CFBundleIdentifier key to Core Info.plist"
        sed -i '' 's/<dict>/<dict>\
    <key>CFBundleIdentifier<\/key>\
    <string>com.fomoapp.fomopr.Core<\/string>/' "$CORE_INFO_PLIST"
    fi
    
    # Convert back to binary plist
    plutil -convert binary1 "$CORE_INFO_PLIST"
    echo "Core Info.plist fixed and converted back to binary format"
else
    echo "Error: Core Info.plist not found at $CORE_INFO_PLIST"
fi

echo "===== BUILT FRAMEWORKS FIX PROCESS COMPLETED =====" 