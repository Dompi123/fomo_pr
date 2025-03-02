#!/bin/bash

# Navigate to the project directory
cd /Users/dom.khr/fomopr

# Open the Xcode project
open FOMO_PR.xcodeproj

echo "Xcode project opened."
echo "Please follow these steps to fix the framework embedding issue:"
echo ""
echo "1. In Xcode, select the FOMO_PR target"
echo "2. Go to the 'Build Phases' tab"
echo "3. Click the '+' button at the top left and select 'New Copy Files Phase'"
echo "4. Change the 'Destination' dropdown to 'Frameworks'"
echo "5. Click the '+' button in the phase and add:"
echo "   - Models.framework"
echo "   - Network.framework"
echo "   - Core.framework"
echo ""
echo "6. Build and run the app"
echo ""
echo "This will ensure the frameworks are embedded in the app bundle and available at runtime." 