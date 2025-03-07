# FOMO Design System

This document provides guidelines and usage information for the FOMO app design system. The design system ensures consistent styling and user experience across the entire app.

## Table of Contents

1. [Design Tokens](#design-tokens)
   - [Colors](#colors)
   - [Typography](#typography)
   - [Spacing](#spacing)
   - [Radius](#radius)
   - [Shadows](#shadows)
2. [Core Components](#core-components)
   - [Buttons](#buttons)
   - [Cards](#cards)
   - [List Rows](#list-rows)
3. [View Modifiers](#view-modifiers)
   - [Typography Modifiers](#typography-modifiers)
   - [Component Modifiers](#component-modifiers)
4. [Feature-Specific Modifiers](#feature-specific-modifiers)
   - [Venue Modifiers](#venue-modifiers)
   - [Drink Modifiers](#drink-modifiers)
5. [Best Practices](#best-practices)
6. [Dev Tools](#dev-tools)

## Design Tokens

Design tokens are the foundational visual properties used throughout the app. All tokens are defined in `FOMOTheme.swift`.

### Colors

```swift
// Usage:
Text("Hello, World")
    .foregroundColor(FOMOTheme.Colors.text)
```

| Token | Usage | Value |
|-------|-------|-------|
| `primary` | Main brand color | Deep Purple |
| `secondary` | Secondary brand color | Black |
| `background` | App background | Dark Gray |
| `surface` | Card and element backgrounds | Medium Gray |
| `text` | Primary text | White |
| `textSecondary` | Secondary text | Gray |
| `accent` | Highlight color | Purple |
| `success` | Positive actions/feedback | Green |
| `warning` | Caution indicators | Yellow |
| `error` | Error states | Red |

### Typography

```swift
// Usage:
Text("Headline")
    .font(FOMOTheme.Typography.headlineLarge)
```

| Token | Usage | Size |
|-------|-------|------|
| `display` | Hero sections | 34pt |
| `headlineLarge` | Major section headers | 28pt |
| `headlineMedium` | Section headers | 22pt |
| `headlineSmall` | Subsection headers | 20pt |
| `bodyLarge` | Emphasized body text | 18pt |
| `bodyRegular` | Standard body text | 16pt |
| `bodySmall` | De-emphasized body text | 14pt |
| `caption1` | Primary caption | 12pt |
| `caption2` | Secondary caption | 10pt |

### Spacing

```swift
// Usage:
Text("Padded content")
    .padding(FOMOTheme.Spacing.medium)
```

| Token | Value | Usage |
|-------|-------|------|
| `xxxSmall` | 2pt | Minimum spacing |
| `xxSmall` | 4pt | Tight spacing |
| `xSmall` | 8pt | Item spacing |
| `small` | 8pt | Standard spacing |
| `medium` | 16pt | Content padding |
| `large` | 24pt | Section spacing |
| `xLarge` | 32pt | Major section spacing |
| `xxLarge` | 40pt | Screen spacing |
| `xxxLarge` | 48pt | Largest spacing |

### Radius

```swift
// Usage:
RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
```

| Token | Value | Usage |
|-------|-------|------|
| `small` | 4pt | Subtle rounded corners |
| `medium` | 8pt | Standard rounded corners |
| `large` | 16pt | Prominent rounded corners |
| `circle` | Infinity | Circular shapes |

### Shadows

```swift
// Usage:
.shadow(color: FOMOTheme.Shadow.medium, radius: 4)
```

| Token | Value | Usage |
|-------|-------|------|
| `light` | Black at 10% opacity | Subtle elevation |
| `medium` | Black at 15% opacity | Standard elevation |
| `dark` | Black at 20% opacity | Prominent elevation |

## Core Components

### Buttons

Use `FOMOButton` for consistent button styling across the app.

```swift
// Primary button
FOMOButton("Sign Up", style: .primary) {
    // Action
}

// Secondary button
FOMOButton("Cancel", style: .secondary) {
    // Action
}

// Text button
FOMOButton("Learn More", style: .text) {
    // Action
}

// Disabled button
FOMOButton("Submit", style: .primary, isEnabled: false) {
    // Action
}
```

### Cards

Use `FOMOCard` for consistent card styling.

```swift
// Standard card
FOMOCard {
    VStack(alignment: .leading) {
        Text("Card Title")
            .font(FOMOTheme.Typography.headlineSmall)
        Text("Card content goes here")
            .font(FOMOTheme.Typography.bodyRegular)
    }
}

// Custom card
FOMOCard(
    padding: .large,
    backgroundColor: FOMOTheme.Colors.primary.opacity(0.1),
    cornerRadius: FOMOTheme.Radius.large
) {
    Text("Custom Card")
}

// Using view extension
VStack {
    // content
}
.asCard()
```

### List Rows

Use `FOMOListRow` for basic list row styling, or `FOMOTitleRow` for standard list items with title/subtitle.

```swift
// Basic list row
FOMOListRow {
    HStack {
        Text("Custom Row Content")
        Spacer()
        Image(systemName: "chevron.right")
    }
}

// Standard title row
FOMOTitleRow(
    title: "Settings",
    subtitle: "Configure your preferences"
)

// Title row with icon
FOMOTitleRow.withIcon(
    title: "Favorites",
    subtitle: "View your favorites",
    icon: "star.fill",
    iconColor: FOMOTheme.Colors.warning
)

// Title row with disclosure
FOMOTitleRow.withDisclosure(
    title: "Profile",
    action: {
        // Navigate to profile
    }
)
```

## View Modifiers

### Typography Modifiers

Use these modifiers for consistent text styling.

```swift
Text("Headline")
    .fomoHeadline()

Text("Title")
    .fomoTitle()

Text("Subtitle")
    .fomoSubtitle()

Text("Body text")
    .fomoBodyText()

Text("Caption")
    .fomoCaption()
```

### Component Modifiers

Use these modifiers for consistent component styling.

```swift
// Button styling
Button("Submit") { }
    .fomoPrimaryButton()

Button("Cancel") { }
    .fomoSecondaryButton()

// Card styling
VStack { /* Content */ }
    .fomoCard()

// List item styling
HStack { /* Content */ }
    .fomoListItem()

// Layout styling
VStack { /* Content */ }
    .fomoContentPadding()

VStack { /* Content */ }
    .fomoSectionStyle()
```

## Feature-Specific Modifiers

### Venue Modifiers

```swift
Text(venue.name)
    .venueNameStyle()

Text(venue.description)
    .venueDescriptionStyle()

VStack { /* Venue content */ }
    .venueListItemStyle()
```

### Drink Modifiers

```swift
Text(drink.name)
    .drinkNameStyle()

Text("$\(drink.price)")
    .priceStyle()

VStack { /* Drink content */ }
    .drinkListItemStyle()
```

## Best Practices

1. **Always use design tokens** - Never use hard-coded color values, font sizes, or spacing values.

2. **Use semantic tokens** - Choose tokens based on their meaning (e.g., `error` for error states) rather than appearance.

3. **Use component modifiers** - Prefer using modifiers like `.fomoHeadline()` over direct property styling.

4. **Maintain consistency** - Use the same styling patterns for similar UI elements.

5. **Follow the modifier order**:
   - Content/structure modifiers (e.g., `.frame()`)
   - Appearance modifiers (e.g., `.foregroundColor()`)
   - Layout modifiers (e.g., `.padding()`)
   - Background/border modifiers (e.g., `.background()`)
   - Effect modifiers (e.g., `.shadow()`)

## Dev Tools

### Theme Preview

Use `FOMOThemePreview` to visualize the design system components:

```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FOMOThemePreview()
    }
}
```

### Theme Migration Helper

Use `ThemeMigrationHelper` to help convert direct styling to use FOMOTheme:

```swift
// In a development helper
let fileContents = "..."
let processedContents = ThemeMigrationHelper.processSwiftFile(fileContents: fileContents)
```

Or use the command-line script:

```bash
./scripts/migrate_theme.swift
``` 