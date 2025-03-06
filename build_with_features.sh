#!/bin/bash

# Script to build FOMO_PR with all features enabled

# Set environment variables
export ENABLE_PAYWALL=1
export ENABLE_DRINK_MENU=1
export ENABLE_CHECKOUT=1
export ENABLE_SEARCH=1
export ENABLE_PREMIUM_VENUES=1
export ENABLE_MOCK_DATA=1
export PREVIEW_MODE=1

# Clean the build directory
echo "Cleaning build directory..."
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR

# Build the app for the simulator
echo "Building FOMO_PR with all features enabled..."
xcodebuild build -project FOMO_PR.xcodeproj -scheme FOMO_PR -configuration Debug -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 15 Pro"

echo "Build completed. You can now run the app in the simulator with all features enabled." 