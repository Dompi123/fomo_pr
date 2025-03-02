# Comprehensive Guide for Fixing FOMO_PR App

This guide provides a complete overview of the issues that were fixed to make the FOMO_PR app run successfully on both simulators and real devices.

## Issues Fixed

1. **Framework References**: Fixed references to system frameworks (Network.framework and Security.framework) and created local frameworks (Core.framework and Models.framework).

2. **Code Signing Issues**: Updated code signing settings for device deployment.

3. **Adobe Genuine Service Interference**: Added necessary entries to Info.plist to prevent Adobe Genuine Service from interfering with the app.

4. **Info.plist Configuration**: Fixed various issues in the Info.plist file, including:
   - Removed UISceneDelegateClassName (not needed for SwiftUI App lifecycle)
   - Fixed UIApplicationSceneManifest
   - Added UILaunchScreen
   - Added UIApplicationSupportsIndirectInputEvents
   - Fixed bundle identifier

5. **Missing Source Files**: Created necessary Swift files that were missing:
   - TypesTest.swift
   - TypesTestEntry.swift
   - FOMOApp.swift

6. **Project Settings**: Updated project settings:
   - Set ENABLE_PREVIEWS to YES
   - Set SWIFT_VERSION to 5.0

## Scripts Created

The following scripts were created to fix the issues:

1. **fix_system_frameworks.sh**: Fixed references to system frameworks.
2. **fix_embed_frameworks.sh**: Removed system frameworks from the "Embed Frameworks" build phase.
3. **fix_code_signing.sh**: Updated code signing settings for device deployment.
4. **fix_adobe_issue.sh**: Added entries to Info.plist to prevent Adobe Genuine Service interference.
5. **fix_simulator_crash.sh**: Fixed issues specific to simulator crashes.
6. **check_dependencies.sh**: Checked for missing frameworks and dependencies.
7. **create_frameworks_manually.sh**: Created Core.framework and Models.framework manually.
8. **final_fix.sh**: Applied final fixes to make the app run.
9. **fix_all_issues.sh**: Comprehensive script that runs all the other scripts.

## How to Fix the App

### Option 1: Run the Comprehensive Fix Script

The easiest way to apply all fixes is to run the comprehensive fix script:

```bash
chmod +x fix_all_issues.sh
./fix_all_issues.sh
```

### Option 2: Run Individual Fix Scripts

If you prefer to apply fixes selectively, you can run the individual scripts in the following order:

1. **Fix System Frameworks**:
   ```bash
   chmod +x fix_system_frameworks.sh
   ./fix_system_frameworks.sh
   ```

2. **Fix Embed Frameworks**:
   ```bash
   chmod +x fix_embed_frameworks.sh
   ./fix_embed_frameworks.sh
   ```

3. **Create Frameworks Manually**:
   ```bash
   chmod +x create_frameworks_manually.sh
   ./create_frameworks_manually.sh
   ```

4. **Fix Code Signing** (for device deployment):
   ```bash
   chmod +x fix_code_signing.sh
   ./fix_code_signing.sh
   ```

5. **Fix Adobe Issue** (for device deployment):
   ```bash
   chmod +x fix_adobe_issue.sh
   ./fix_adobe_issue.sh
   ```

6. **Apply Final Fixes**:
   ```bash
   chmod +x final_fix.sh
   ./final_fix.sh
   ```

## After Running the Scripts

After running the scripts, you need to:

1. Open the project in Xcode
2. Clean the build folder (Product > Clean Build Folder)
3. Build and run the app

## Troubleshooting

If you still encounter issues:

1. **For Simulator Issues**:
   - Run the simulator-specific fix script:
     ```bash
     chmod +x fix_simulator_crash.sh
     ./fix_simulator_crash.sh
     ```
   - Make sure you're using the latest version of Xcode
   - Try different simulator devices

2. **For Device Issues**:
   - Make sure your development team is set correctly in Xcode
   - Check that your device is properly connected and trusted
   - Verify that your Apple Developer account has the necessary provisioning profiles

3. **For Framework Issues**:
   - Check that the frameworks are correctly referenced in the project
   - Make sure the frameworks are included in the "Embed Frameworks" build phase
   - Verify that the framework binaries are valid

## Reverting Changes

If you need to revert the changes made by the scripts, you can use the backup files:

- Original project file: `FOMO_PR.xcodeproj/project.pbxproj.backup`
- Project file after various fixes: `FOMO_PR.xcodeproj/project.pbxproj.*.backup`
- Original Info.plist: `FOMO_PR/Info.plist.backup`
- Info.plist after various fixes: `FOMO_PR/Info.plist.*.backup`

## Understanding the Fixes

### Framework References

The app was originally configured to use local copies of Network.framework and Security.framework, but these should be system frameworks. We fixed this by:

1. Changing the framework references to point to the system frameworks
2. Removing them from the "Embed Frameworks" build phase

### Code Signing

For device deployment, we updated the code signing settings:

1. Changed CODE_SIGN_IDENTITY from "Apple Development" to "iPhone Developer"
2. Changed CODE_SIGN_STYLE from Automatic to Manual for device builds

### Info.plist Configuration

We fixed several issues in the Info.plist file:

1. Removed UISceneDelegateClassName (not needed for SwiftUI App lifecycle)
2. Fixed UIApplicationSceneManifest
3. Added UILaunchScreen
4. Added UIApplicationSupportsIndirectInputEvents
5. Fixed bundle identifier

### Missing Source Files

We created necessary Swift files that were missing:

1. TypesTest.swift: Contains the TypesTestView
2. TypesTestEntry.swift: Contains the TypesTestEntry view
3. FOMOApp.swift: Contains the main app structure

### Project Settings

We updated project settings:

1. Set ENABLE_PREVIEWS to YES
2. Set SWIFT_VERSION to 5.0 