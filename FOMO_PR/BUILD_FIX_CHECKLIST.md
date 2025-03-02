# Build Fix Checklist

Use this checklist to track your progress in fixing the build issues:

## Step 1: Add New Files to Xcode Project

- [ ] Add `FOMO_PR/SecurityTypes.swift` to the project
- [ ] Add `FOMO_PR/FOMO_PR.modulemap` to the project
- [ ] Add `FOMO_PR/PaymentManager.swift` to the project
- [ ] Add updated `FOMO_PR/XcodeTypeHelper.swift` to the project

## Step 2: Update Xcode Project Settings

- [ ] Set "Objective-C Bridging Header" to `FOMO_PR/FOMO_PR-Bridging-Header.h`
- [ ] Set "Module Map File" to `FOMO_PR/FOMO_PR.modulemap`
- [ ] Set "Defines Module" to "Yes"
- [ ] Set "Product Module Name" to "FOMO_PR"

## Step 3: Remove Conflicting Files from Xcode Project

- [ ] Remove `Core/Payment/TokenizationService.swift`
- [ ] Remove `Core/Payment/Tokenization/TokenizationService.swift`
- [ ] Remove `Core/Payment/Tokenization/LiveTokenizationService.swift`
- [ ] Remove `Core/Payment/Tokenization/MockTokenizationService.swift`
- [ ] Remove `Core/Payment/LiveTokenizationService.swift`
- [ ] Remove `Core/Payment/MockTokenizationService.swift`
- [ ] Remove `Core/Network/TokenizationService.swift`
- [ ] Remove `Core/Payment/PaymentServiceProtocol.swift`
- [ ] Remove `Core/Payment/PaymentState.swift`
- [ ] Remove `Core/Payment/PaymentManager.swift`

## Step 4: Clean and Rebuild

- [ ] Clean build folder (Product > Clean Build Folder)
- [ ] Close Xcode completely
- [ ] Reopen Xcode and the project
- [ ] Build the project (Command+B)

## Step 5: Verify Success

- [ ] No more "No type named 'TokenizationService' in module 'Security'" errors
- [ ] No more "Module 'Security' has no member named 'LiveTokenizationService'" errors
- [ ] No more "Module 'Security' has no member named 'MockTokenizationService'" errors
- [ ] Build succeeds without errors 