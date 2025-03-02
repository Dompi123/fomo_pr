#!/bin/bash

# Script to check for missing frameworks or dependencies

echo "Checking for missing frameworks or dependencies..."

# Check if Core.framework exists
if [ -d "FOMO_PR/Frameworks/Core.framework" ]; then
    echo "✅ Core.framework found"
else
    echo "❌ Core.framework not found in FOMO_PR/Frameworks/"
    
    # Check if it exists in .build directory
    if [ -d ".build/debug/Core.framework" ]; then
        echo "   Found Core.framework in .build/debug/"
        echo "   Copying to FOMO_PR/Frameworks/"
        mkdir -p FOMO_PR/Frameworks
        cp -R .build/debug/Core.framework FOMO_PR/Frameworks/
        echo "   Core.framework copied successfully"
    else
        echo "   Core.framework not found in .build/debug/ either"
        echo "   You may need to build the Swift package first"
    fi
fi

# Check if Models.framework exists
if [ -d "FOMO_PR/Frameworks/Models.framework" ]; then
    echo "✅ Models.framework found"
else
    echo "❌ Models.framework not found in FOMO_PR/Frameworks/"
    
    # Check if it exists in .build directory
    if [ -d ".build/debug/Models.framework" ]; then
        echo "   Found Models.framework in .build/debug/"
        echo "   Copying to FOMO_PR/Frameworks/"
        mkdir -p FOMO_PR/Frameworks
        cp -R .build/debug/Models.framework FOMO_PR/Frameworks/
        echo "   Models.framework copied successfully"
    else
        echo "   Models.framework not found in .build/debug/ either"
        echo "   You may need to build the Swift package first"
    fi
fi

# Check if the app is using the correct Swift version
echo "Checking Swift version compatibility..."
SWIFT_VERSION=$(swift --version | head -n 1)
echo "Current Swift version: $SWIFT_VERSION"

# Check if the Info.plist has the correct bundle identifier
INFO_PLIST="FOMO_PR/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    BUNDLE_ID=$(grep -A 1 "CFBundleIdentifier" "$INFO_PLIST" | grep -v "CFBundleIdentifier" | sed -e 's/<[^>]*>//g' | tr -d '\t')
    echo "Bundle identifier: $BUNDLE_ID"
    
    # Check if the bundle identifier matches the expected format
    if [[ "$BUNDLE_ID" == *"$(PRODUCT_BUNDLE_IDENTIFIER)"* ]]; then
        echo "⚠️ Bundle identifier contains a build variable that might not be resolved correctly"
        echo "   Consider setting an explicit bundle identifier"
    fi
else
    echo "❌ Info.plist not found at $INFO_PLIST"
fi

# Check for any potential conflicts in the project file
PROJECT_FILE="FOMO_PR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    # Check for duplicate framework references
    DUPLICATE_FRAMEWORKS=$(grep -o "path = [^;]*\.framework" "$PROJECT_FILE" | sort | uniq -d)
    if [ -n "$DUPLICATE_FRAMEWORKS" ]; then
        echo "⚠️ Found duplicate framework references:"
        echo "$DUPLICATE_FRAMEWORKS"
    else
        echo "✅ No duplicate framework references found"
    fi
    
    # Check for missing file references
    MISSING_FILES=$(grep -o "path = [^;]*\.swift" "$PROJECT_FILE" | sed 's/path = //' | while read -r file; do
        if [ ! -f "$file" ]; then
            echo "   $file"
        fi
    done)
    
    if [ -n "$MISSING_FILES" ]; then
        echo "⚠️ Found references to missing Swift files:"
        echo "$MISSING_FILES"
    else
        echo "✅ All referenced Swift files exist"
    fi
else
    echo "❌ Project file not found at $PROJECT_FILE"
fi

echo "Dependency check completed." 