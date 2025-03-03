#!/bin/bash

echo "=== Verifying Framework Fixes ==="

# Check Models framework
echo "Checking Models framework..."
if [ -f "FOMO_PR/Frameworks/Models.framework/Models" ]; then
    echo "✅ Models framework binary exists"
    
    # Check if it's executable
    if [ -x "FOMO_PR/Frameworks/Models.framework/Models" ]; then
        echo "✅ Models framework binary is executable"
    else
        echo "❌ Models framework binary is not executable"
        chmod +x "FOMO_PR/Frameworks/Models.framework/Models"
        echo "   Fixed: Made Models framework binary executable"
    fi
    
    # Check if the framework structure is correct
    if [ -d "FOMO_PR/Frameworks/Models.framework/Headers" ] && \
       [ -d "FOMO_PR/Frameworks/Models.framework/Modules" ] && \
       [ -d "FOMO_PR/Frameworks/Models.framework/Versions" ]; then
        echo "✅ Models framework structure is correct"
    else
        echo "❌ Models framework structure is incomplete"
    fi
else
    echo "❌ Models framework binary not found"
fi

# Check Core framework
echo "Checking Core framework..."
if [ -f "FOMO_PR/Frameworks/Core.framework/Core" ]; then
    echo "✅ Core framework binary exists"
    
    # Check if it's executable
    if [ -x "FOMO_PR/Frameworks/Core.framework/Core" ]; then
        echo "✅ Core framework binary is executable"
    else
        echo "❌ Core framework binary is not executable"
        chmod +x "FOMO_PR/Frameworks/Core.framework/Core"
        echo "   Fixed: Made Core framework binary executable"
    fi
    
    # Check if the framework structure is correct
    if [ -d "FOMO_PR/Frameworks/Core.framework/Headers" ] && \
       [ -d "FOMO_PR/Frameworks/Core.framework/Modules" ] && \
       [ -d "FOMO_PR/Frameworks/Core.framework/Versions" ]; then
        echo "✅ Core framework structure is correct"
    else
        echo "❌ Core framework structure is incomplete"
    fi
else
    echo "❌ Core framework binary not found"
fi

# Check project file references
echo "Checking project file references..."
if grep -q "path = FOMO_PR/Frameworks/Models.framework;" FOMO_PR.xcodeproj/project.pbxproj; then
    echo "✅ Project file references Models framework correctly"
else
    echo "❌ Project file does not reference Models framework correctly"
fi

if grep -q "path = FOMO_PR/Frameworks/Core.framework;" FOMO_PR.xcodeproj/project.pbxproj; then
    echo "✅ Project file references Core framework correctly"
else
    echo "❌ Project file does not reference Core framework correctly"
fi

# Check Info.plist
echo "Checking Info.plist..."
if grep -q "LSApplicationCategoryType" FOMO_PR/Info.plist; then
    echo "✅ Info.plist contains LSApplicationCategoryType"
else
    echo "❌ Info.plist does not contain LSApplicationCategoryType"
    sed -i '' '/<dict>/a\
    <key>LSApplicationCategoryType</key>\
    <string>public.app-category.lifestyle</string>' FOMO_PR/Info.plist
    echo "   Fixed: Added LSApplicationCategoryType to Info.plist"
fi

echo "=== Verification Complete ==="
echo "All framework issues should be fixed. Try building and running the app now." 