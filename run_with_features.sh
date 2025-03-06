#!/bin/bash

# Script to run FOMO_PR with all features enabled

# Set environment variables
export ENABLE_PAYWALL=1
export ENABLE_DRINK_MENU=1
export ENABLE_CHECKOUT=1
export ENABLE_SEARCH=1
export ENABLE_PREMIUM_VENUES=1
export ENABLE_MOCK_DATA=1
export PREVIEW_MODE=1

# Run the app in the simulator
echo "Running FOMO_PR with all features enabled..."
xcrun simctl launch booted com.fomoapp.fomopr

echo "App launched in simulator with all features enabled." 