#!/bin/bash

# Navigate to the project directory
cd /Users/dom.khr/fomopr

# Build the Swift packages to ensure the frameworks are generated
swift build

# Create a new directory for frameworks if it doesn't exist
mkdir -p FOMO_PR/Frameworks

# Copy the frameworks from the .build directory to the Frameworks directory
cp -R .build/debug/Models.framework FOMO_PR/Frameworks/
cp -R .build/debug/Network.framework FOMO_PR/Frameworks/
cp -R .build/debug/Core.framework FOMO_PR/Frameworks/

# Make the script executable
chmod +x FOMO_PR/fix_build_issues.sh

echo "Frameworks copied to FOMO_PR/Frameworks/"
echo "Now open the project in Xcode and add an 'Embed Frameworks' build phase"
echo "Then add the frameworks from FOMO_PR/Frameworks/ to this build phase"

# Path to the project.pbxproj file
PROJECT_FILE="./FOMO_PR.xcodeproj/project.pbxproj"

# Backup the original file
cp "$PROJECT_FILE" "${PROJECT_FILE}.backup"

# For Network.framework: Change from local path to system framework
# 1. Change the PBXFileReference entry
sed -i '' 's|lastKnownFileType = wrapper.framework; path = Network.framework;|lastKnownFileType = wrapper.framework; name = Network.framework; path = System/Library/Frameworks/Network.framework;|g' "$PROJECT_FILE"

# 2. Change the PBXFileReference entry for Security.framework
sed -i '' 's|lastKnownFileType = wrapper.framework; path = Security.framework;|lastKnownFileType = wrapper.framework; name = Security.framework; path = System/Library/Frameworks/Security.framework;|g' "$PROJECT_FILE"

echo "Project file has been modified to use system frameworks."
echo "A backup of the original file has been saved as ${PROJECT_FILE}.backup" 