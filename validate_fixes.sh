#!/bin/bash

echo "Validating fixes for FOMO_PR app..."

# 1. Check if Info.plist is valid
echo "Checking if Info.plist is valid..."
if plutil -lint FOMO_PR/Info.plist; then
    echo "✅ Info.plist is valid"
else
    echo "❌ Info.plist is invalid"
fi

# 2. Check if APIClient.swift exists
echo "Checking if APIClient.swift exists..."
if [ -f "FOMO_PR/Networking/APIClient.swift" ]; then
    echo "✅ APIClient.swift exists"
else
    echo "❌ APIClient.swift does not exist"
fi

# 3. Check if ProfileViewModel.swift has been updated
echo "Checking if ProfileViewModel.swift has been updated..."
if grep -q "private let apiClient = APIClient.shared" "FOMO_PR/Features/Profile/ViewModels/ProfileViewModel.swift"; then
    echo "❌ ProfileViewModel.swift still references APIClient.shared"
else
    echo "✅ ProfileViewModel.swift has been updated"
fi

# 4. Check if project file includes APIClient.swift
echo "Checking if project file includes APIClient.swift..."
if grep -q "APIClient.swift" "FOMO_PR.xcodeproj/project.pbxproj"; then
    echo "✅ Project file includes APIClient.swift"
else
    echo "❌ Project file does not include APIClient.swift"
fi

echo "Validation complete. If all checks passed, try building the app again." 