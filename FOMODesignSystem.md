# FOMO Design System

This document outlines the design system for the FOMO mobile app, including all components, modifiers, and patterns for consistent UI development.

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing](#spacing)
5. [Components](#components)
6. [Screen-Specific Extensions](#screen-specific-extensions)
7. [Usage Guidelines](#usage-guidelines)
8. [Testing Across Devices](#testing-across-devices)

## Core Concepts

The FOMO design system is built on the following principles:

- **Consistency**: Use consistent styling throughout the app
- **Semantic Styling**: Use modifiers that describe the purpose rather than appearance
- **Reusability**: Reuse styling components across the app
- **Maintainability**: Centralized styling makes updates easier

All styling should utilize design tokens from `FOMOTheme` instead of raw values.

## Color System

### Base Colors

```swift
FOMOTheme.Colors.primary      // Primary brand color
FOMOTheme.Colors.secondary    // Secondary brand color
FOMOTheme.Colors.accent       // Accent color for highlights
FOMOTheme.Colors.background   // Main app background
FOMOTheme.Colors.surface      // Surface elements (cards, etc.)
```

### Text Colors

```swift
FOMOTheme.Colors.text          // Primary text color
FOMOTheme.Colors.textSecondary // Secondary text color
```

### Semantic Colors

```swift
FOMOTheme.Colors.error         // Error states
FOMOTheme.Colors.success       // Success states
FOMOTheme.Colors.warning       // Warning states
```

## Typography

### Text Styles

```swift
// Base typography tokens
FOMOTheme.Typography.largeTitle   // 34pt bold
FOMOTheme.Typography.title1       // 24pt bold
FOMOTheme.Typography.title2       // 22pt semibold
FOMOTheme.Typography.title3       // 20pt semibold
FOMOTheme.Typography.headline     // 17pt semibold
FOMOTheme.Typography.body         // 16pt regular
FOMOTheme.Typography.callout      // 16pt regular
FOMOTheme.Typography.subheadline  // 15pt regular
FOMOTheme.Typography.footnote     // 13pt regular
FOMOTheme.Typography.caption1     // 12pt medium
FOMOTheme.Typography.caption2     // 11pt regular
```

### Text Modifiers

```swift
// General text modifiers
.fomoTextStyle(FOMOTheme.Typography.headline)  // Apply any typography token
.fomoHeadlineStyle()    // Standard headline style
.fomoTitle1Style()      // Title 1 style
.fomoTitle2Style()      // Title 2 style
.fomoBodyStyle()        // Body text style
.fomoSubheadlineStyle() // Subheadline with secondary color
.fomoCaptionStyle()     // Caption style
```

## Spacing

The spacing system ensures consistent layout throughout the app:

```swift
FOMOTheme.Spacing.xxxSmall // 2pt
FOMOTheme.Spacing.xxSmall  // 4pt 
FOMOTheme.Spacing.xSmall   // 8pt
FOMOTheme.Spacing.small    // 8pt
FOMOTheme.Spacing.medium   // 16pt
FOMOTheme.Spacing.large    // 24pt
FOMOTheme.Spacing.xLarge   // 32pt
FOMOTheme.Spacing.xxLarge  // 40pt
FOMOTheme.Spacing.xxxLarge // 48pt
```

## Corner Radius

The corner radius system ensures consistent rounding:

```swift
FOMOTheme.Radius.small   // 4pt
FOMOTheme.Radius.medium  // 8pt
FOMOTheme.Radius.large   // 16pt
FOMOTheme.Radius.circle  // Infinity (circular)
```

Use the modifier to apply corner radius:

```swift
.fomoCornerRadius(FOMOTheme.Radius.medium)  // With specific radius
.fomoCornerRadius()  // With default medium radius
```

## Components

### Buttons

```swift
.fomoPrimaryButtonStyle()    // Primary action button
.fomoSecondaryButtonStyle()  // Secondary action button
```

### Cards

```swift
.fomoCardStyle()  // Standard card style with shadow
```

### Tags

```swift
.fomoTagStyle()  // Standard tag style
```

## Screen-Specific Extensions

### Venue Screens

```swift
// Venue list
.venueListItemStyle()  // Venue list item
.venueNameStyle()      // Venue name
.venueDescriptionStyle() // Venue description
.venueRatingStyle()    // Venue rating
.venueAddressStyle()   // Venue address

// Venue detail
.venueTitleStyle()     // Venue title
.venueSubtitleStyle()  // Venue subtitle
.venueBodyStyle()      // Venue body text
.venueCaptionStyle()   // Venue caption
.venueActionButtonStyle() // Venue action button
.venueTagStyle()       // Venue tag
```

### Paywall Screen

```swift
.paywallHeadingStyle() // Paywall section heading
.paywallButtonStyle()  // Paywall button
```

### Profile Screen

```swift
.profileHeadingStyle()   // Profile heading
.profileSubheadingStyle() // Profile subheading
.profileAvatarStyle()    // Profile avatar
.profileSectionStyle()   // Profile section header
.profileRowStyle()       // Profile row
```

### Passes Screen

```swift
.passesHeadingStyle()    // Passes heading
.passesSubheadingStyle() // Passes subheading
.passesIconStyle()       // Passes icon
.passCardStyle()         // Pass card
```

### Drink Menu Screen

```swift
.drinkTitleStyle()       // Drink title
.drinkDescriptionStyle() // Drink description
.drinkPriceStyle()       // Drink price
.drinkQuantityStyle()    // Drink quantity
.drinkImageStyle()       // Drink image
.drinkPlaceholderStyle() // Drink placeholder
.drinkIconStyle()        // Drink icon
.drinkErrorIconStyle()   // Drink error icon
.drinkEmptyIconStyle()   // Drink empty state icon
.drinkButtonStyle()      // Drink button
```

## Usage Guidelines

### Before and After Example

Before (direct styling):
```swift
Text("Hello World")
    .font(.headline)
    .foregroundColor(.primary)
    .padding()
    .background(Color.blue.opacity(0.1))
    .cornerRadius(8)
```

After (using design system):
```swift
Text("Hello World")
    .fomoHeadlineStyle()
    .padding(FOMOTheme.Spacing.medium)
    .background(FOMOTheme.Colors.primary.opacity(0.1))
    .fomoCornerRadius(FOMOTheme.Radius.medium)
```

## Testing Across Devices

The design system has been tested on the following devices:
- iPhone SE (smallest supported device)
- iPhone 14 Pro
- iPhone 14 Pro Max

All components scale appropriately based on the device size.

## Tools and Resources

- **Visual Library**: A comprehensive library of all UI components is available in the `ViewLibrary` view.
- **Design System Demo App**: Run the `DesignSystemDemoApp` to see all components in action.
- **Before/After Examples**: Compare refactored screens in the "Compare" tab of the Design System Demo App. 