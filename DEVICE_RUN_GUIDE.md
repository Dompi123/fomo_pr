# Guide for Running FOMO_PR on a Real Device

This guide provides instructions for fixing issues when running the FOMO_PR app on a real iOS device.

## Issues Fixed

The scripts in this repository fix the following issues:

1. **Framework Issues**: Corrects the references to system frameworks (Network.framework and Security.framework) and removes them from the "Embed Frameworks" build phase.

2. **Code Signing Issues**: Updates the code signing settings to work better with real devices.

3. **Adobe Genuine Service Interference**: Prevents the Adobe Genuine Service from interfering with the app by adding necessary entries to Info.plist.

4. **Missing Privacy Descriptions**: Adds required privacy descriptions to Info.plist for common device permissions.

## How to Fix the Issues

### Option 1: Run the Comprehensive Fix Script

The easiest way to apply all fixes is to run the comprehensive fix script:

```bash
chmod +x fix_all_issues.sh
./fix_all_issues.sh
```

This script will:
- Fix system framework references
- Remove system frameworks from the "Embed Frameworks" build phase
- Update code signing settings
- Add necessary entries to Info.plist to prevent Adobe Genuine Service interference
- Add privacy descriptions to Info.plist

### Option 2: Run Individual Fix Scripts

If you prefer to apply fixes selectively, you can run the individual scripts:

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

3. **Fix Code Signing**:
   ```bash
   chmod +x fix_code_signing.sh
   ./fix_code_signing.sh
   ```

4. **Fix Adobe Genuine Service Issue**:
   ```bash
   chmod +x fix_adobe_issue.sh
   ./fix_adobe_issue.sh
   ```

## After Running the Scripts

After running the scripts, you need to:

1. Open the project in Xcode
2. Set your development team manually in the project settings:
   - Select the FOMO_PR project in the Project Navigator
   - Select the FOMO_PR target
   - Go to the "Signing & Capabilities" tab
   - Select your team from the "Team" dropdown menu

3. Build and run the app on your device

## Troubleshooting

If you still encounter issues after applying the fixes:

1. Check the Xcode logs for more detailed error messages
2. Make sure your device is properly connected and trusted
3. Verify that your Apple Developer account has the necessary provisioning profiles
4. Try cleaning the build folder (Product > Clean Build Folder) and rebuilding

## Reverting Changes

If you need to revert the changes made by the scripts, you can use the backup files:

- Original project file: `FOMO_PR.xcodeproj/project.pbxproj.backup`
- Project file after framework fixes: `FOMO_PR.xcodeproj/project.pbxproj.embed.backup`
- Project file after code signing fixes: `FOMO_PR.xcodeproj/project.pbxproj.codesign.backup`
- Original Info.plist: `FOMO_PR/Info.plist.backup`
- Info.plist after Adobe fixes: `FOMO_PR/Info.plist.adobe.backup`
- Info.plist after all fixes: `FOMO_PR/Info.plist.all.backup` 