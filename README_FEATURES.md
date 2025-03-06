# FOMO_PR App with All Features Enabled

This README provides instructions on how to build and run the FOMO_PR app with all features enabled for UI/UX development and testing.

## Features Enabled

When using the provided scripts, the following features will be enabled:

- Venue listing and details
- Paywall/Pass purchase functionality
- Drink menu
- Checkout process
- Search functionality
- Premium venues

## Quick Start

For the fastest way to get started, use the combined build and run script:

```
./build_and_run.sh
```

This script will:
1. Clean the project
2. Build the app with all features enabled
3. Launch the simulator
4. Install and run the app

## Building the App (Manual)

To build the app with all features enabled:

1. Open Terminal
2. Navigate to the project directory: `cd /path/to/fomo_pr`
3. Run the build script: `./build_with_features.sh`

This will build the app for the iOS simulator with all features enabled.

## Running the App (Manual)

After building, you can run the app in the simulator:

1. Open Xcode
2. Select the FOMO_PR scheme
3. Choose an iOS simulator (iPhone 15 Pro recommended)
4. Click the Run button

Alternatively, you can use the provided run script:

```
./run_with_features.sh
```

## UI/UX Development

With all features enabled, you can now work on:

- Changing colors and fonts
- Adding micro-animations
- Improving layout and spacing
- Enhancing user interactions

## Troubleshooting

If you encounter any issues:

1. Make sure all scripts are executable (`chmod +x script_name.sh`)
2. Verify that the simulator is running before using the run script
3. Check the Xcode console for any error messages
4. If the navigation doesn't work, make sure you've rebuilt the app with the latest changes

## Notes

- This is a development build with mock data
- The app is configured to run in Debug mode
- All navigation between screens should now work correctly 