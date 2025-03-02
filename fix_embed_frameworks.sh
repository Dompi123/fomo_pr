#!/bin/bash

# Path to the project file
PROJECT_FILE="./FOMO_PR.xcodeproj/project.pbxproj"

# Create a backup of the original project file
cp "$PROJECT_FILE" "$PROJECT_FILE.embed.backup"

# Remove Network.framework and Security.framework from the Embed Frameworks build phase
# This uses sed to find the Embed Frameworks section and remove the lines containing these frameworks
sed -i '' '/Embed Frameworks/,/runOnlyForDeploymentPostprocessing = 0;/ {
    /9792DA2C2D74393600511100 \/\* Security.framework in Embed Frameworks \*\//d
    /9792DA2A2D74393500511100 \/\* Network.framework in Embed Frameworks \*\//d
}' "$PROJECT_FILE"

echo "Modified project file to remove Network.framework and Security.framework from Embed Frameworks build phase."
echo "A backup of the original file was saved as $PROJECT_FILE.embed.backup" 