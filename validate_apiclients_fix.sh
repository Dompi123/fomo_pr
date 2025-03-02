#!/bin/bash

echo "Validating fixes for duplicate APIClient and KeychainManager issues..."

# 1. Check if our duplicate APIClient implementation was removed
echo "Checking if duplicate APIClient implementation was removed..."
if [ -f "FOMO_PR/Networking/APIClient.swift" ]; then
    echo "❌ Duplicate APIClient.swift still exists"
else
    echo "✅ Duplicate APIClient.swift was removed"
fi

# 2. Check if ProfileViewModel no longer references APIClient.shared
echo "Checking if ProfileViewModel no longer references APIClient.shared..."
if grep -q "private let apiClient = APIClient.shared" "FOMO_PR/Features/Profile/ViewModels/ProfileViewModel.swift"; then
    echo "❌ ProfileViewModel.swift still references APIClient.shared"
else
    echo "✅ ProfileViewModel.swift no longer references APIClient.shared"
fi

# 3. Check if KeychainManager has been updated with Sendable conformance
echo "Checking if KeychainManager has been updated with Sendable conformance..."
if grep -q "Sendable" "FOMO_PR/Core/Storage/KeychainManager.swift"; then
    echo "✅ KeychainManager.swift has been updated with Sendable conformance"
else
    echo "❌ KeychainManager.swift has not been updated with Sendable conformance"
fi

# 4. Check if project file no longer references our APIClient.swift
echo "Checking if project file no longer references our APIClient.swift..."
if grep -q "ABCDEF1234567890" "FOMO_PR.xcodeproj/project.pbxproj" || grep -q "ABCDEF0987654321" "FOMO_PR.xcodeproj/project.pbxproj"; then
    echo "❌ Project file still references our APIClient.swift"
else
    echo "✅ Project file no longer references our APIClient.swift"
fi

echo "Validation complete. If all checks passed, try building the app again." 