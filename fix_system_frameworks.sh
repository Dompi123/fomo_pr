#!/bin/bash

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