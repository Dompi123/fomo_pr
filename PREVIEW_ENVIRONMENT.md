# FOMO_PR Preview Environment

This document explains how to use the preview environment for UI/UX development in the FOMO_PR app.

## Overview

The preview environment provides a complete UI experience with mock data, allowing designers and developers to:

- View and test all UI components with realistic data
- Modify colors, layouts, animations, and other visual elements
- Test different user flows and navigation paths
- Work without requiring a connection to backend services

## Running the Preview Build

To launch the app in preview mode with all features enabled:

```bash
./build_and_run.sh
```

This script will:
1. Set all feature flags to enabled
2. Build the app in debug configuration
3. Launch the app on the Journey iPhone simulator
4. Configure mock data for all screens

## Available Features in Preview Mode

The preview environment enables the following features:

- **Venues List**: Complete list of mock venues with details
- **Venue Details**: Full venue information with all tabs
- **Drink Menu**: Complete menu with categorized drinks
- **Checkout**: Complete checkout flow with mock order processing
- **Paywall**: All pricing tiers and mock payment processing
- **Search**: Functional search with mock results
- **Premium Venues**: Special designation for premium venues

## Development Workflow

When working on UI/UX improvements:

1. Run the preview build using `./build_and_run.sh`
2. Make changes to the relevant UI components
3. Rebuild and run to see your changes
4. Iterate until you're satisfied with the visual design

## Mock Data

The preview environment uses a centralized `MockDataProvider` class that supplies consistent data across the app. Key data includes:

- **Venues**: Various venue types with names, descriptions, and addresses
- **Drinks**: Multiple drink categories with prices and descriptions
- **Pricing Tiers**: Different pass options with pricing
- **Orders**: Simulated order processing and history

## Customizing the Preview Environment

If you need to modify the mock data:

1. Edit the `MockDataProvider` class in `FOMOApp.swift`
2. Add or modify the mock data collections as needed
3. Rebuild the app to see your changes

## Feature Flags

The preview environment uses the following feature flags:

- `ENABLE_PAYWALL`: Enables the venue pass purchase feature
- `ENABLE_DRINK_MENU`: Enables the drink menu and ordering feature
- `ENABLE_CHECKOUT`: Enables the checkout process
- `ENABLE_SEARCH`: Enables search functionality
- `ENABLE_PREMIUM_VENUES`: Enables premium venue designation
- `ENABLE_MOCK_DATA`: Uses mock data instead of API calls
- `PREVIEW_MODE`: Configures the app for preview/development

These flags are set in the build script and can be individually toggled if needed.

## Troubleshooting

If you encounter issues with the preview environment:

- Check that all environment variables are correctly set in `build_and_run.sh`
- Verify that the simulator is correctly configured
- Ensure all UI components are correctly loading mock data from `MockDataProvider`
- Check the console logs for any error messages

## UI States

The preview environment supports various UI states:

- **Loading**: Simulated loading states for network operations
- **Error**: Simulated error states with appropriate messages
- **Empty**: Empty state displays when applicable
- **Success**: Success states for completed operations

These states can be tested by modifying the view model logic or waiting for the simulated network delays.

## Contributing

When adding new UI features:

1. Ensure they work correctly in the preview environment
2. Add appropriate mock data to `MockDataProvider` if needed
3. Document any special setup requirements

## Questions?

If you have questions about the preview environment, please contact the development team. 