#!/bin/bash

# Navigate to the project directory
cd /Users/dom.khr/fomopr

# Create a backup of the original Package.swift
cp Package.swift Package.swift.bak

# Modify the Package.swift file to use static libraries
cat > Package.swift << 'EOF'
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FOMO_PR",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FOMO_PR",
            type: .static,
            targets: ["FOMO_PR"]),
        .library(
            name: "Models",
            type: .static,
            targets: ["Models"]),
        .library(
            name: "Network",
            type: .static,
            targets: ["Network"]),
        .library(
            name: "Core",
            type: .static,
            targets: ["Core"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Models",
            dependencies: [],
            path: "Models/Sources/Models"),
        .target(
            name: "Network",
            dependencies: ["Models"],
            path: "Network/Sources/Network"),
        .target(
            name: "Core",
            dependencies: ["Models", "Network"],
            path: "Core/Sources/Core"),
        .target(
            name: "FOMO_PR",
            dependencies: ["Models", "Network", "Core"],
            path: "FOMO_PR",
            exclude: [
                // Feature modules
                "Features/Profile/ViewModels/ProfileViewModel.swift",
                "Features/Passes/ViewModels/PassesViewModel.swift",
                "Features/Drinks/ViewModels/CheckoutViewModel.swift",
                "Features/Venues/Views/VenueMenuView.swift",
                "Features/Venues/Views/VenueDetailView.swift",
                "Features/Venues/Views/VenuePreviewView.swift",
                "Features/Venues/Views/VenueListView.swift",
                "Features/Venues/ViewModels/VenueListViewModel.swift",
                "Features/Venues/ViewModels/VenueMenuViewModel.swift",
                "Features/Venues/ViewModels/VenuePreviewViewModel.swift",
                "Features/Venues/ViewModels/PaywallViewModel.swift",
                "Features/Passes/Views/PassPurchaseView.swift",
                "Features/Venues/Views/AgentTestView.swift",
                
                // Core modules
                "Core/Core.swift",
                "Core/Design/FOMOAnimations.swift",
                "Core/Payment/PaymentResult.swift",
                "Core/Payment/PaymentManager.swift",
                "Core/Storage/KeychainManager.swift",
                "Core/Utilities/ErrorHandler.swift",
                "Core/Payment/Tokenization/APIEndpoint.swift",
                "Core/Design/Design.swift",
                "Core/Design/Typography.swift",
                "Core/Design/Colors.swift",
                "Core/Core/FOMOTheme.swift",
                "Core/Core/View+FOMOStyle.swift",
                "Core/Models/Drink.swift",
                "Core/Models/NetworkError.swift",
                "Core/Extensions/String+Localized.swift",
                "Core/Network/Network.swift",
                "Core/Design/Colors.xcassets",
                "Core/BaseViewModel.swift",
                "Core/ViewModels/BaseViewModel.swift",
                "Core/Core/BaseViewModel.swift",
                "Core/Models/BaseViewModel.swift",
                
                // Payment and tokenization files - these are now defined in SecurityTypes.swift
                "Core/Payment/TokenizationService.swift",
                "Core/Payment/Tokenization/TokenizationService.swift",
                "Core/Payment/Tokenization/LiveTokenizationService.swift",
                "Core/Payment/Tokenization/MockTokenizationService.swift",
                "Core/Payment/LiveTokenizationService.swift",
                "Core/Payment/MockTokenizationService.swift",
                "Core/Network/TokenizationService.swift",
                "Core/Payment/PaymentServiceProtocol.swift",
                "Core/Payment/PaymentState.swift",
                
                // Model files
                "Core/Models/Pass.swift",
                "Core/Models/PricingTier.swift",
                "Core/Models/AppModels.swift",
                "Core/Models/Models.swift",
                "Core/Models/StringExtensions.swift",
                "SharedTypes.swift",
                
                // Preview content
                "Preview Content/PreviewVenues.swift",
                
                // Project files
                "Info.plist",
                
                // Helper files
                "FOMO_PR-Bridging-Header.h",
                "XcodeTypeHelper.swift",
                "FOMO_PR.modulemap",
                "SecurityTypes.swift",
                "PaymentManager.swift",
                
                // Documentation files
                "MODULE_FIX_GUIDE.md",
                "BUILD_FIX_README.md",
                "INTEGRATION_GUIDE.md",
                "XCODE_FIX_INSTRUCTIONS.md",
                "FINAL_FIX_GUIDE.md"
            ]),
    ]
)
EOF

echo "Package.swift modified to use static libraries."
echo "Now open the project in Xcode and rebuild it."
echo "This should fix the framework loading issue at runtime." 