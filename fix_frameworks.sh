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