# FOMO_PR App

FOMO_PR is an iOS application that allows users to explore venues, view drink menus, and complete checkout processes. This README provides comprehensive instructions for building, running, and developing the app.

## Features

The app includes the following features:

- Venue listing and detailed venue information
- Paywall/Pass purchase functionality
- Drink menu browsing
- Checkout process
- Search functionality
- Premium venues

## Quick Start

For the fastest way to get started with all features enabled, use the combined build and run script:

```
./build_and_run.sh
```

This script will:
1. Clean the project
2. Build the app with all features enabled
3. Launch the simulator (iPhone 15 Pro)
4. Install and run the app

## Manual Build and Run

### Building the App

To build the app with all features enabled:

1. Open Terminal
2. Navigate to the project directory
3. Run the build script: `./build_with_features.sh`

### Running the App

After building, you can run the app in the simulator:

1. Open Xcode
2. Select the FOMO_PR scheme
3. Choose an iOS simulator (iPhone 15 Pro recommended)
4. Click the Run button

Alternatively, use the provided run script:

```
./run_with_features.sh
```

### Running on a Physical Device

To build and run the app on a connected iOS device:

```
./run_on_device.sh
```

This script will:
1. Detect a connected iOS device
2. Clean the project
3. Build the app with all features enabled
4. Install and launch the app on the device

Note: Your device must be set up for development, and you must have the appropriate provisioning profiles.

## Production Build and Distribution

### Building for Production

To create a production build for distribution to TestFlight or the App Store:

```
./build_production.sh
```

This script will:
1. Clean the project
2. Build the app in Release mode with production settings
3. Prepare it for archiving and distribution

### Archiving for Distribution

To archive the app for distribution:

```
./archive_app.sh
```

This script will:
1. Clean the project
2. Create an archive of the app in Release mode
3. Provide instructions for distributing the archive

### Export Options

The repository includes an `ExportOptions.plist` file for distribution. Before using it:

1. Open the file in a text editor
2. Replace `YOUR_TEAM_ID` with your actual Apple Developer Team ID
3. Update the provisioning profile name if necessary

You can then export the archive using:

```
xcodebuild -exportArchive -archivePath "./build/FOMO_PR.xcarchive" -exportPath "./build/export" -exportOptionsPlist "ExportOptions.plist"
```

## Crash Fix Instructions

If the app crashes at launch with the error message:

```
dyld: Library not loaded: @rpath/Models.framework/Models
```

This indicates that the app was trying to load the Models framework at runtime, but couldn't find it.

### Fix Applied

We've modified the `Package.swift` file to use static libraries instead of dynamic frameworks. This avoids the need for embedding frameworks at runtime.

### Steps to Build and Run the App (Standard)

1. Open the Xcode project:
   ```
   open FOMO_PR.xcodeproj
   ```

2. Select the FOMO_PR target in Xcode

3. Build the app (⌘+B)

4. Run the app on the simulator (⌘+R)

### Alternative Fix

If the static library approach doesn't work, you can try the following:

1. Open the Xcode project
2. Select the FOMO_PR target
3. Go to the "Build Phases" tab
4. Click the "+" button at the top left and select "New Copy Files Phase"
5. Change the "Destination" dropdown to "Frameworks"
6. Click the "+" button in the phase and add:
   - Models.framework
   - Network.framework
   - Core.framework
7. Build and run the app

## Project Structure

The FOMO_PR app is structured as follows:

- **FOMO_PR**: Main app target
- **Models**: Framework for data models
- **Network**: Framework for networking code
- **Core**: Framework for core functionality

## UI/UX Development

With all features enabled, you can work on:

- Changing colors and fonts
- Adding micro-animations
- Improving layout and spacing
- Enhancing user interactions

## Troubleshooting

If you encounter any issues:

1. Make sure all scripts are executable (`chmod +x script_name.sh`)
2. Verify that the simulator is running before using the run script
3. Check the Xcode console for any error messages
4. If navigation doesn't work, make sure you've rebuilt the app with the latest changes
5. Make sure all dependencies are properly linked
6. Check that the frameworks are either statically linked or properly embedded
7. Verify that all required files are included in the app bundle

For more detailed debugging, you can run the app with console output:

```
xcrun simctl launch --console <SIMULATOR_ID> com.fomoapp.fomopr
```

## Build Configurations

The app supports different build configurations:

- **Debug with Features**: Use `./build_with_features.sh` or `./build_and_run.sh` for development with all features enabled and mock data
- **Physical Device**: Use `./run_on_device.sh` to build and run on a connected iOS device
- **Production**: Use `./build_production.sh` for release builds with real data and all features enabled
- **Archive**: Use `./archive_app.sh` to create an archive for distribution

## Notes

- When using the feature scripts, the app runs with mock data
- The app is configured to run in Debug mode when using development scripts
- All navigation between screens should work correctly when using the feature scripts
- Production builds use real data sources and are optimized for distribution
