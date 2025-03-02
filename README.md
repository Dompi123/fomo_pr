# FOMO_PR App

## Crash Fix Instructions

The app was crashing at launch due to missing frameworks. The error message was:

```
dyld: Library not loaded: @rpath/Models.framework/Models
```

This indicates that the app was trying to load the Models framework at runtime, but it couldn't find it.

### Fix Applied

We've modified the `Package.swift` file to use static libraries instead of dynamic frameworks. This avoids the need for embedding frameworks at runtime.

### Steps to Build and Run the App

1. Open the Xcode project:
   ```
   open FOMO_PR.xcodeproj
   ```

2. Select the FOMO_PR target in Xcode

3. Build the app (⌘+B)

4. Run the app on the "Journey iPhone" simulator (⌘+R)

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

This will ensure the frameworks are embedded in the app bundle and available at runtime.

## Project Structure

The FOMO_PR app is structured as follows:

- **FOMO_PR**: Main app target
- **Models**: Framework for data models
- **Network**: Framework for networking code
- **Core**: Framework for core functionality

## Troubleshooting

If you encounter any issues, please check the following:

1. Make sure all dependencies are properly linked
2. Check that the frameworks are either statically linked or properly embedded
3. Verify that all required files are included in the app bundle

For more detailed debugging, you can run the app with console output:

```
xcrun simctl launch --console 58C8D7C8-CCFF-4669-8DF7-7F29F3447CC4 com.fomoapp.fomopr
```
