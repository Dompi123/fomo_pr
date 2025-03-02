#!/bin/bash

# Script to create frameworks manually

echo "Creating frameworks manually for FOMO_PR..."

# Create Frameworks directory if it doesn't exist
mkdir -p FOMO_PR/Frameworks

# Create Core.framework
echo "Creating Core.framework..."
mkdir -p FOMO_PR/Frameworks/Core.framework/Versions/A
mkdir -p FOMO_PR/Frameworks/Core.framework/Headers

# Create a simple Core framework header
cat > FOMO_PR/Frameworks/Core.framework/Headers/Core.h << 'EOF'
#import <Foundation/Foundation.h>

//! Project version number for Core.
FOUNDATION_EXPORT double CoreVersionNumber;

//! Project version string for Core.
FOUNDATION_EXPORT const unsigned char CoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Core/PublicHeader.h>
EOF

# Create a simple Core framework module map
mkdir -p FOMO_PR/Frameworks/Core.framework/Modules
cat > FOMO_PR/Frameworks/Core.framework/Modules/module.modulemap << 'EOF'
framework module Core {
  umbrella header "Core.h"

  export *
  module * { export * }
}
EOF

# Create symbolic links for the framework structure
ln -sf Versions/A/Core FOMO_PR/Frameworks/Core.framework/Core
ln -sf A FOMO_PR/Frameworks/Core.framework/Versions/Current
ln -sf Versions/Current/Headers FOMO_PR/Frameworks/Core.framework/Headers

# Create Models.framework
echo "Creating Models.framework..."
mkdir -p FOMO_PR/Frameworks/Models.framework/Versions/A
mkdir -p FOMO_PR/Frameworks/Models.framework/Headers

# Create a simple Models framework header
cat > FOMO_PR/Frameworks/Models.framework/Headers/Models.h << 'EOF'
#import <Foundation/Foundation.h>

//! Project version number for Models.
FOUNDATION_EXPORT double ModelsVersionNumber;

//! Project version string for Models.
FOUNDATION_EXPORT const unsigned char ModelsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Models/PublicHeader.h>
EOF

# Create a simple Models framework module map
mkdir -p FOMO_PR/Frameworks/Models.framework/Modules
cat > FOMO_PR/Frameworks/Models.framework/Modules/module.modulemap << 'EOF'
framework module Models {
  umbrella header "Models.h"

  export *
  module * { export * }
}
EOF

# Create symbolic links for the framework structure
ln -sf Versions/A/Models FOMO_PR/Frameworks/Models.framework/Models
ln -sf A FOMO_PR/Frameworks/Models.framework/Versions/Current
ln -sf Versions/Current/Headers FOMO_PR/Frameworks/Models.framework/Headers

# Create Info.plist files for the frameworks
cat > FOMO_PR/Frameworks/Core.framework/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Core</string>
    <key>CFBundleIdentifier</key>
    <string>com.fomo.Core</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Core</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSPrincipalClass</key>
    <string></string>
</dict>
</plist>
EOF

cat > FOMO_PR/Frameworks/Models.framework/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Models</string>
    <key>CFBundleIdentifier</key>
    <string>com.fomo.Models</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Models</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSPrincipalClass</key>
    <string></string>
</dict>
</plist>
EOF

# Create dummy binary files for the frameworks
echo "Creating dummy binary files for the frameworks..."
echo "This is a dummy Core framework binary" > FOMO_PR/Frameworks/Core.framework/Versions/A/Core
echo "This is a dummy Models framework binary" > FOMO_PR/Frameworks/Models.framework/Versions/A/Models

# Make the binaries executable
chmod +x FOMO_PR/Frameworks/Core.framework/Versions/A/Core
chmod +x FOMO_PR/Frameworks/Models.framework/Versions/A/Models

# Update the project file to reference the correct framework paths
PROJECT_FILE="FOMO_PR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    echo "Updating framework references in project file..."
    
    # Backup the file
    cp "$PROJECT_FILE" "${PROJECT_FILE}.manual.backup"
    
    # Update Core.framework reference
    sed -i '' 's|path = Core.framework;|path = FOMO_PR/Frameworks/Core.framework;|g' "$PROJECT_FILE"
    
    # Update Models.framework reference
    sed -i '' 's|path = Models.framework;|path = FOMO_PR/Frameworks/Models.framework;|g' "$PROJECT_FILE"
    
    echo "Framework references updated in project file"
else
    echo "❌ Project file not found at $PROJECT_FILE"
fi

# Fix the Info.plist bundle identifier
INFO_PLIST="FOMO_PR/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    echo "Fixing bundle identifier in Info.plist..."
    
    # Backup the file
    cp "$INFO_PLIST" "${INFO_PLIST}.manual.backup"
    
    # Replace the bundle identifier placeholder with an explicit value
    sed -i '' 's/<string>$(PRODUCT_BUNDLE_IDENTIFIER)<\/string>/<string>com.fomo.FOMO-PR<\/string>/g' "$INFO_PLIST"
    
    echo "Bundle identifier fixed in Info.plist"
else
    echo "❌ Info.plist not found at $INFO_PLIST"
fi

echo "Frameworks created manually. Please try building and running the app again." 