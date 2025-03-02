# Xcode Fix Instructions

Follow these steps to fix the remaining errors in your Xcode project:

## 1. Add the New Files to Your Xcode Project

1. In Xcode, go to File > Add Files to "FOMO_PR"...
2. Navigate to the following files and add them to your project:
   - `FOMO_PR/FOMO_PR-Bridging-Header.h`
   - `FOMO_PR/XcodeTypeHelper.swift`
   - `FOMO_PR/ModuleDefinition.swift`
   - `FOMO_PR/DirectImports.swift`
   - `FOMO_PR/ModuleTest.swift`
3. Make sure "Copy items if needed" is checked
4. Add to target: "FOMO_PR"
5. Click "Add"

## 2. Update Your Xcode Project Settings

1. Select your project in the Project Navigator
2. Select the "FOMO_PR" target
3. Go to the "Build Settings" tab
4. Search for "bridging header"
5. Set "Objective-C Bridging Header" to `FOMO_PR/FOMO_PR-Bridging-Header.h`
6. Search for "module"
7. Set "Defines Module" to "Yes"
8. Set "Product Module Name" to "FOMO_PR"

## 3. Fix the ErrorHandler.swift File

The ErrorHandler.swift file has been fixed in the Swift Package Manager build, but you may need to update it in your Xcode project as well. Make sure it has the correct syntax with:
- The `switch` keyword in the `errorDescription` property of `AppError`
- All closing braces and parentheses

## 4. Clean and Rebuild

1. In Xcode, go to Product > Clean Build Folder
2. Close Xcode completely
3. Reopen Xcode and your project
4. Build the project (Command+B)

## 5. If You Still Have Issues

If you're still seeing the "Expected ')' at end of enum" error:
1. Open the ErrorHandler.swift file in Xcode
2. Make sure it matches the fixed version we created
3. If not, manually fix the syntax errors

If you're still seeing the "Command SwiftEmitModule failed" error:
1. Try removing the Models target from your Xcode project
2. Add the Models files directly to your FOMO_PR target
3. Update any import statements to use direct imports instead of module imports

## 6. Additional Troubleshooting

If you continue to have issues:
1. Check for circular dependencies in your project
2. Make sure there are no conflicting type definitions
3. Consider creating a new Xcode project and adding all your source files to it
4. Use direct imports (import Foundation, import SwiftUI) instead of module imports

The Swift Package Manager build is now working correctly, so the issues are likely specific to your Xcode project configuration. 